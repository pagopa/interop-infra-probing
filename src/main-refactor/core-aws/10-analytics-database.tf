resource "aws_security_group" "probing_analytics" {
  name        = format("timestream/%s-analytics-%s", local.project, var.env)
  description = "SG for Timestream for InfluxDB instances"

  vpc_id = data.aws_vpc.probing.id

  ingress {
    description = "Clients inside VPC"
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    security_groups = [
      module.eks.cluster_primary_security_group_id,
      data.aws_security_group.vpn_clients.id
    ]
  }
}

locals {
  timestream_instance_name = format("%s-analytics-%s", local.project, var.env)
  timestream_organization  = local.timestream_instance_name #TOCHECK
  bucket_prefix_name       = "probing-telemetry"
}

resource "random_password" "probing_analytics_admin" {
  length  = 16
  special = false
  upper   = true
  lower   = true
  numeric = true
}

resource "aws_secretsmanager_secret" "probing_analytics_admin" {
  name                    = "timestream/${local.timestream_instance_name}/users/admin"
  recovery_window_in_days = 0
}

resource "aws_secretsmanager_secret_version" "probing_analytics_admin" {
  secret_id = aws_secretsmanager_secret.probing_analytics_admin.id

  secret_string = jsonencode({
    timestream_instance     = local.timestream_instance_name
    timestream_organization = local.timestream_organization
    username                = "admin"
    password                = random_password.probing_analytics_admin.result
    token                   = "" # Must be generated via Influx UI from AWS console or via influx CLI
  })
}

resource "aws_timestreaminfluxdb_db_instance" "probing_analytics" {
  name         = local.timestream_instance_name
  organization = local.timestream_organization

  bucket = format("%s-%s", local.bucket_prefix_name, var.env)

  allocated_storage = 20
  db_instance_type  = "db.influx.medium"
  deployment_type   = "WITH_MULTIAZ_STANDBY"

  username = jsondecode(aws_secretsmanager_secret_version.probing_analytics_admin.secret_string)["username"]
  password = jsondecode(aws_secretsmanager_secret_version.probing_analytics_admin.secret_string)["password"]

  vpc_subnet_ids         = data.aws_subnets.timestream_probing_analytics_store.ids
  vpc_security_group_ids = [aws_security_group.probing_analytics.id]
}

# Generate a token for the admin user in the InfluxDB instance and stores it in the relative SecretsManager secret
resource "terraform_data" "probing_analytics_generate_admin_token" {
  depends_on = [aws_timestreaminfluxdb_db_instance.probing_analytics, aws_secretsmanager_secret_version.probing_analytics_admin]

  triggers_replace = [
    aws_timestreaminfluxdb_db_instance.probing_analytics,
    aws_secretsmanager_secret.probing_analytics_admin
  ]

  provisioner "local-exec" {
    environment = {
      INSTANCE_ENDPOINT            = format("https://%s:8086", aws_timestreaminfluxdb_db_instance.probing_analytics.endpoint)
      ORGANIZATION                 = aws_timestreaminfluxdb_db_instance.probing_analytics.organization
      ADMIN_CREDENTIALS_SECRET_ARN = aws_secretsmanager_secret.probing_analytics_admin.arn
    }

    command = <<EOT
      #!/bin/bash
      set -euo pipefail

      secret_json=$(aws secretsmanager get-secret-value --secret-id "$ADMIN_CREDENTIALS_SECRET_ARN" --query SecretString --output text)
      
      ADMIN_USERNAME=$(echo "$secret_json" | jq -r '.username')
      ADMIN_PASSWORD=$(echo "$secret_json" | jq -r '.password')

      influx config create --config-name admin-config --host-url "$INSTANCE_ENDPOINT" --org "$ORGANIZATION" -p "$ADMIN_USERNAME":"$ADMIN_PASSWORD" --active

      echo "Creating an all-access token for the admin user..."
      TOKEN_JSON=$(influx auth create --org "$ORGANIZATION" --user "$ADMIN_USERNAME" --all-access --json)
      ADMIN_TOKEN=$(echo "$TOKEN_JSON" | jq -r '.token')

      echo "Saving token into Secrets Manager..."
      aws secretsmanager put-secret-value --secret-id "$ADMIN_CREDENTIALS_SECRET_ARN" \
        --secret-string "$(echo "$secret_json" | jq --arg token "$ADMIN_TOKEN" '. + {token: $token}')"
    EOT
  }
}

locals {
  influxdb_buckets_to_create = [
    for stage in var.stages_to_provision : format("%s-%s", local.bucket_prefix_name, stage) if stage != var.env # Exclude the current environment from the list of buckets to create
  ]
}

# Create a bucket in the InfluxDB instance for each stage (excluding the one equals to the var.env value because it is already created by the aws_timestreaminfluxdb_db_instance.probing_analytics resource)
resource "terraform_data" "probing_analytics_create_bucket" {
  depends_on = [aws_timestreaminfluxdb_db_instance.probing_analytics, aws_secretsmanager_secret_version.probing_analytics_admin, terraform_data.probing_analytics_generate_admin_token]

  for_each = toset(local.influxdb_buckets_to_create)

  triggers_replace = [
    aws_timestreaminfluxdb_db_instance.probing_analytics,
    aws_secretsmanager_secret.probing_analytics_admin,
    local.influxdb_buckets_to_create
  ]

  provisioner "local-exec" {
    environment = {
      INSTANCE_ENDPOINT            = format("https://%s:8086", aws_timestreaminfluxdb_db_instance.probing_analytics.endpoint)
      ORGANIZATION                 = aws_timestreaminfluxdb_db_instance.probing_analytics.organization
      BUCKET_TO_CREATE             = each.key
      ADMIN_CREDENTIALS_SECRET_ARN = aws_secretsmanager_secret.probing_analytics_admin.arn
    }

    command = <<EOT
      #!/bin/bash
      set -euo pipefail
      
      secret_json=$(aws secretsmanager get-secret-value --secret-id $ADMIN_CREDENTIALS_SECRET_ARN --query SecretString --output text)

      ADMIN_TOKEN=$(echo $secret_json | jq -r '.token')
      if [ -z "$ADMIN_TOKEN" ]; then
        echo "The admin token has not been set in the secret. The InfluxDB buckets creation will be skipped."
        exit 0
      fi

      echo "Checking if bucket '$BUCKET_TO_CREATE' exists..."
      BUCKET_EXISTS=$(influx bucket list --host "$INSTANCE_ENDPOINT" --org "$ORGANIZATION" --token "$ADMIN_TOKEN" --json | jq -r --arg name "$BUCKET_TO_CREATE" '.[] | select(.name == $name) | .id')

      if [ -z "$BUCKET_EXISTS" ]; then
        echo "Creating bucket '$BUCKET_TO_CREATE' in organization '$ORGANIZATION'..."
        influx bucket create --host "$INSTANCE_ENDPOINT" --org "$ORGANIZATION" --name "$BUCKET_TO_CREATE" --token "$ADMIN_TOKEN" --retention 0
      else
        echo "Bucket '$BUCKET_TO_CREATE' already exists."
      fi
    EOT
  }
}
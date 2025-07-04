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
  bucket_prefix_name       = "probing-telemetry"
}

resource "random_password" "probing_analytics_admin" {
  length  = 16
  special = true
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
    timestream_instance = local.timestream_instance_name
    username            = "admin"
    password            = random_password.probing_analytics_admin.result
    token               = "" # Must be generated via InfluxUI from AWS console and then manually set in the secret
  })
}

resource "aws_timestreaminfluxdb_db_instance" "probing_analytics" {
  name         = local.timestream_instance_name
  organization = local.timestream_instance_name #TOCHECK

  bucket = format("%s-%s", local.bucket_prefix_name, var.env)

  allocated_storage = 20
  db_instance_type  = "db.influx.medium"
  deployment_type   = "WITH_MULTIAZ_STANDBY"

  username = jsondecode(aws_secretsmanager_secret_version.probing_analytics_admin.secret_string)["username"]
  password = jsondecode(aws_secretsmanager_secret_version.probing_analytics_admin.secret_string)["password"]

  vpc_subnet_ids         = data.aws_subnets.timestream_probing_analytics_store.ids
  vpc_security_group_ids = [aws_security_group.probing_analytics.id]
}

locals {
  influxdb_buckets_to_create = [
    for stage in var.stages_to_provision : format("%s-%s", local.bucket_prefix_name, stage) if stage != var.env # Exclude the current environment from the list of buckets to create
  ]
}

# Create a bucket in the InfluxDB instance for each stage (excluding the one equals to the var.env value because it is already created by the aws_timestreaminfluxdb_db_instance.probing_analytics resource)
resource "null_resource" "probing_analytics_create_bucket" {
  depends_on = [aws_timestreaminfluxdb_db_instance.probing_analytics]

  for_each = jsondecode(aws_secretsmanager_secret_version.probing_analytics_admin.secret_string)["token"] != "" ? toset(local.influxdb_buckets_to_create) : toset([])

  provisioner "local-exec" {
    environment = {
      INSTANCE_ENDPOINT            = aws_timestreaminfluxdb_db_instance.probing_analytics.endpoint
      ORGANIZATION                 = aws_timestreaminfluxdb_db_instance.probing_analytics.organization
      BUCKET_TO_CREATE             = each.key
      ADMIN_CREDENTIALS_SECRET_ARN = aws_secretsmanager_secret.probing_analytics_admin.arn
    }

    command = <<EOT
      #!/bin/bash
      set -euo pipefail
      
      secret_json=$(aws secretsmanager get-secret-value --secret-id $ADMIN_CREDENTIALS_SECRET_ARN --query SecretString --output text)

      ADMIN_TOKEN=$(echo $secret_json | jq -r '.token')

      influx config create config-name admin-config host-url "$INSTANCE_ENDPOINT" --org "$ORGANIZATION" --token "$ADMIN_TOKEN" --active

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
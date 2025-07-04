locals {
  be_app_influx_users = {
    telemetry_writer_user = {
      username        = "probing_telemetry_writer_user_${var.stage}",
      k8s_secret_name = "probing-analytics-db-telemetry-writer-user-${var.stage}"
    },
    statistics_api_user = {
      username        = "probing_statistics_api_user_${var.stage}",
      k8s_secret_name = "probing-analytics-db-statistics-api-user-${var.stage}"
    }
  }
}

resource "random_password" "probing_analytics_users" {
  for_each = local.be_app_influx_users

  length  = 16
  special = true
  upper   = true
  lower   = true
  numeric = true
}

resource "aws_secretsmanager_secret" "probing_analytics_users" {
  for_each = local.be_app_influx_users

  name                    = "timestream/${var.timestream_instance_name}/users/${each.value.username}"
  recovery_window_in_days = 0

  tags = merge(local.eks_secret_default_tags,
    {
      EKSReplicaSecretName = each.value.k8s_secret_name
    }
  )
}

data "aws_secretsmanager_secret" "probing_analytics_admin" {
  name = var.probing_analytics_admin_secret_name
}

# Create a user and a related token in the InfluxDB instance for each entry in local.be_app_influx_users
resource "null_resource" "probing_analytics_create_users_tokens" {
  for_each = local.be_app_influx_users

  provisioner "local-exec" {
    environment = {
      INSTANCE_ENDPOINT            = aws_timestreaminfluxdb_db_instance.probing_analytics.endpoint     #TOCHECK: need a data source but current version of aws provider does not support it
      ORGANIZATION                 = aws_timestreaminfluxdb_db_instance.probing_analytics.organization #TOCHECK: need a data source but current version of aws provider does not support it
      USERNAME                     = each.value.username
      PASSWORD                     = random_password.probing_analytics_users[each.key].result
      ADMIN_CREDENTIALS_SECRET_ARN = data.aws_secretsmanager_secret.probing_analytics_admin.arn
      SECRET_NAME                  = aws_secretsmanager_secret.probing_analytics_users[each.key].name
    }

    command = <<EOT
      #!/bin/bash
      set -euo pipefail
      
      secret_json=$(aws secretsmanager get-secret-value --secret-id $ADMIN_CREDENTIALS_SECRET_ARN --query SecretString --output text)

      ADMIN_TOKEN=$(echo $secret_json | jq -r '.token')

      influx config create config-name admin-config host-url "$INSTANCE_ENDPOINT" --org "$ORGANIZATION" --token "$ADMIN_TOKEN" --active

      echo "Checking if user '$USER_TO_CREATE' exists..."
      USER_EXISTS=$(influx user list --host "$INSTANCE_ENDPOINT" --org "$ORGANIZATION" --token "$ADMIN_TOKEN" --json | jq -r --arg name "$USER_TO_CREATE" '.[] | select(.name == $name) | .id')

      if [ -z "$USER_EXISTS" ]; then
        echo "Creating user '$USERNAME'..."
        influx user create --name "$USERNAME"
      else
        echo "User '$USERNAME' already exists."
      fi

      echo "Creating token for user '$USERNAME'..."
      TOKEN_JSON=$(influx auth create --user "$USERNAME" --org "$ORGANIZATION" --write-buckets --read-buckets --json)
      USER_TOKEN=$(echo "$TOKEN_JSON" | jq -r '.token')

      echo "Saving secret to AWS Secrets Manager..."
      aws secretsmanager put-secret-value --secret-id "$SECRET_NAME" \
        --secret-string "$(jq -n \
          --arg timestream_instance "${var.timestream_instance_name}" \
          --arg username "$USERNAME" \
          --arg password "$PASSWORD" \
          --arg token "$USER_TOKEN" \
          '{timestream_instance: $timestream_instance, username: $username, password: $password, token: $token}'
        )"
    EOT
  }
}

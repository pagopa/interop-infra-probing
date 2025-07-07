locals {
  be_app_influx_users = {
    telemetry_writer_user = {
      username        = "probing_telemetry_writer_user_${var.stage}",
      k8s_secret_name = "probing-analytics-db-telemetry-writer-user-${var.stage}"
      permission_flag = "--write-bucket ${var.timestream_instance_bucket_name}"
    },
    statistics_api_user = {
      username        = "probing_statistics_api_user_${var.stage}",
      k8s_secret_name = "probing-analytics-db-statistics-api-user-${var.stage}"
      permission_flag = "--read-bucket ${var.timestream_instance_bucket_name}"
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
      INSTANCE_ENDPOINT            = var.timestream_instance_endpoint     #TO CHECK: we should use a data source but the current version of aws provider does not support it, so we've created a variable
      ORGANIZATION                 = var.timestream_instance_organization #TO CHECK: we should use a data source but the current version of aws provider does not support it, so we've created a variable
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

      echo "Checking if user '$USERNAME' exists..."
      USER_EXISTS=$(influx user list --host "$INSTANCE_ENDPOINT" --org "$ORGANIZATION" --token "$ADMIN_TOKEN" --json | jq -r --arg name "$USERNAME" '.[] | select(.name == $name) | .id')

      if [ -z "$USER_EXISTS" ]; then
        echo "Creating user '$USERNAME'..."
        influx user create --host "$INSTANCE_ENDPOINT" --org "$ORGANIZATION" --name "$USERNAME" --password "$PASSWORD" --token "$ADMIN_TOKEN"
      else
        echo "User '$USERNAME' already exists."
      fi

      echo "Creating token for user '$USERNAME'..."
      TOKEN_JSON=$(influx auth create --host "$INSTANCE_ENDPOINT" --org "$ORGANIZATION" --user "$USERNAME" ${each.value.permission_flag} --token "$ADMIN_TOKEN" --json)
      USER_TOKEN=$(echo "$TOKEN_JSON" | jq -r '.token')

      echo "Saving secret to AWS Secrets Manager..."
      aws secretsmanager put-secret-value --secret-id "$SECRET_NAME" \
        --secret-string "$(jq -n \
          --arg timestream_instance "${var.timestream_instance_name}" \
          --arg timestream_organization "${var.timestream_instance_organization}" \
          --arg username "$USERNAME" \
          --arg password "$PASSWORD" \
          --arg token "$USER_TOKEN" \
          '{timestream_instance: $timestream_instance, timestream_organization: $timestream_organization, username: $username, password: $password, token: $token}'
        )"
    EOT
  }
}

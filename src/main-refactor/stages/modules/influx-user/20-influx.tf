# Create an influx user and a related token in the InfluxDB instance, and stores it in the relative SecretsManager secret
resource "terraform_data" "manage_user_token" {
  depends_on = [aws_secretsmanager_secret.this]

  triggers_replace = [
    var.timestream_influxdb_instance_endpoint,
    var.timestream_influxdb_organization,
    var.username
  ]

  provisioner "local-exec" {
    environment = {
      INSTANCE_ENDPOINT            = var.timestream_influxdb_instance_endpoint
      INSTANCE_HOST                = format("https://%s:%s", var.timestream_influxdb_instance_endpoint, var.timestream_influxdb_instance_port)
      ORGANIZATION                 = var.timestream_influxdb_organization
      USERNAME                     = var.username
      PASSWORD                     = data.aws_secretsmanager_random_password.this.random_password
      ADMIN_CREDENTIALS_SECRET_ARN = data.aws_secretsmanager_secret.timestream_influxdb_admin.arn
      SECRET_NAME                  = aws_secretsmanager_secret.this.name
      PERMISSION_FLAGS             = join(" ", var.permission_flags)
      GRANT_READ_ON_BUCKETS        = join(" ", var.grant_read_on_buckets)
      GRANT_WRITE_ON_BUCKETS       = join(" ", var.grant_write_on_buckets)
    }

    command = <<EOT
      #!/bin/bash
      set -euo pipefail

      chmod +x "${path.module}/scripts/manage_user_token.sh"
      bash "${path.module}/scripts/manage_user_token.sh"
    EOT
  }
}

# Not needed since when the username changes, the relative aws_secretsmanager_secret resource is replaced, which triggers the terraform_data.delete_user to run. 
# So, the influx user is deleted before the new one is created.
# resource "terraform_data" "delete_previous_user" {
#   depends_on = [aws_secretsmanager_secret.this]

#   input = {
#     instance_host                = format("https://%s:%s", var.timestream_influxdb_instance_endpoint, var.timestream_influxdb_instance_port)
#     organization                 = var.timestream_influxdb_organization
#     username                     = var.username
#     admin_credentials_secret_arn = data.aws_secretsmanager_secret.timestream_influxdb_admin.arn
#     secret_name                  = aws_secretsmanager_secret.this.name
#   }

#   triggers_replace = [
#     var.username
#   ]

#   provisioner "local-exec" {
#     environment = {
#       INSTANCE_HOST                = self.input.instance_host
#       ORGANIZATION                 = self.input.organization
#       USERNAME                     = self.triggers_replace[0]
#       CURRENT_USERNAME             = self.input.username
#       ADMIN_CREDENTIALS_SECRET_ARN = self.input.admin_credentials_secret_arn
#       SECRET_NAME                  = aws_secretsmanager_secret.this.name
#     }

#     command = <<EOT
#       #!/bin/bash
#       set -euo pipefail

#       if [[ "$USERNAME" != "$CURRENT_USERNAME" ]]; then
#         secret_json=$(aws secretsmanager get-secret-value --secret-id $ADMIN_CREDENTIALS_SECRET_ARN --query SecretString --output text)

#         ADMIN_TOKEN=$(echo $secret_json | jq -r '.token')
#         if [ -z "$ADMIN_TOKEN" ]; then
#           echo "The admin token has not been set in the secret. The InfluxDB user update will be skipped."
#           exit 0
#         fi

#         echo "Checking if user '$USERNAME' exists..."

#         set +e
#         USER_ID=$(influx user list --host "$INSTANCE_HOST" --token="$ADMIN_TOKEN" --name "$USERNAME" | awk 'NR>1 {print $1}')
#         USER_LIST_EXIT_CODE=$?
#         set -e

#         if [ $USER_LIST_EXIT_CODE -ne 0 ] && [ -z "$USER_ID" ]; then
#           echo "User '$USERNAME' does not exist"
#           exit 1
#         else
#           echo "Updating user '$USERNAME'..."
#           influx user update --host "$INSTANCE_HOST" --org "$ORGANIZATION" --id "$USERNAME" --name "$CURRENT_USERNAME" --token="$ADMIN_TOKEN"
#         fi

#         echo "Saving updated username into Secrets Manager..."
#         aws secretsmanager put-secret-value --secret-id "$SECRET_NAME" \
#           --secret-string "$(echo "$secret_json" | jq --arg username "$CURRENT_USERNAME" '. + {username: $username}')"
#       fi
#     EOT
#   }
# }

resource "terraform_data" "delete_user" {
  depends_on = [aws_secretsmanager_secret.this]

  input = {
    instance_host                = format("https://%s:%s", var.timestream_influxdb_instance_endpoint, var.timestream_influxdb_instance_port)
    organization                 = var.timestream_influxdb_organization
    username                     = var.username
    admin_credentials_secret_arn = data.aws_secretsmanager_secret.timestream_influxdb_admin.arn
  }

  triggers_replace = [
    aws_secretsmanager_secret.this.id
  ]

  provisioner "local-exec" {
    when = destroy

    environment = {
      INSTANCE_HOST                = self.input.instance_host
      ORGANIZATION                 = self.input.organization
      USERNAME                     = self.input.username
      ADMIN_CREDENTIALS_SECRET_ARN = self.input.admin_credentials_secret_arn
    }

    command = <<EOT
      #!/bin/bash
      set -euo pipefail
      
      secret_json=$(aws secretsmanager get-secret-value --secret-id $ADMIN_CREDENTIALS_SECRET_ARN --query SecretString --output text)

      ADMIN_TOKEN=$(echo $secret_json | jq -r '.token')
      if [ -z "$ADMIN_TOKEN" ]; then
        echo "The admin token has not been set in the secret. The InfluxDB user update will be skipped."
        exit 0
      fi

      echo "Checking if user '$USERNAME' exists..."

      set +e
        USER_ID=$(influx user list --host "$INSTANCE_HOST" --token="$ADMIN_TOKEN" --name "$USERNAME" | awk 'NR>1 {print $1}')
        USER_LIST_EXIT_CODE=$?
      set -e

      if [ $USER_LIST_EXIT_CODE -ne 0 ] && [ -z "$USER_ID" ]; then
        echo "User '$USERNAME' does not exist"
        exit 1
      else
        echo "Deleting user '$USERNAME'..."
        influx user delete --host "$INSTANCE_HOST" --id "$USER_ID" --token="$ADMIN_TOKEN"
      fi
    EOT
  }
}
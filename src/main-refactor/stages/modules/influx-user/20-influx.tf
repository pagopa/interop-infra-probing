resource "terraform_data" "create_user_token" {

  triggers_replace = [
    var.timestream_influxdb_instance_endpoint,
    var.timestream_influxdb_organization,
    var.username,
    random_password.this,
    var.permission_flags,
    aws_secretsmanager_secret.this,
  ]

  provisioner "local-exec" {
    environment = {
      INSTANCE_HOST                = format("https://%s:%s", var.timestream_influxdb_instance_endpoint, var.timestream_influxdb_instance_port) #TO CHECK: we should use a data source but the current version of aws provider does not support it, so we've created a variable
      ORGANIZATION                 = var.timestream_influxdb_organization                                                                      #TO CHECK: we should use a data source but the current version of aws provider does not support it, so we've created a variable
      USERNAME                     = var.username
      PASSWORD                     = random_password.this.result
      ADMIN_CREDENTIALS_SECRET_ARN = data.aws_secretsmanager_secret.timestream_influxdb_admin.arn
      SECRET_NAME                  = aws_secretsmanager_secret.this.name
    }

    command = <<EOT
      #!/bin/bash
      set -euo pipefail
      
      secret_json=$(aws secretsmanager get-secret-value --secret-id $ADMIN_CREDENTIALS_SECRET_ARN --query SecretString --output text)

      ADMIN_TOKEN=$(echo $secret_json | jq -r '.token')
      if [ -z "$ADMIN_TOKEN" ]; then
        echo "The admin token has not been set in the secret. The InfluxDB user creation will be skipped."
        exit 0
      fi

      echo "Checking if user '$USERNAME' exists..."
      USER_EXISTS=$(influx user list --host "$INSTANCE_HOST" --org "$ORGANIZATION" --token "$ADMIN_TOKEN" --json | jq -r --arg name "$USERNAME" '.[] | select(.name == $name) | .id')

      if [ -z "$USER_EXISTS" ]; then
        echo "Creating user '$USERNAME'..."
        influx user create --host "$INSTANCE_HOST" --org "$ORGANIZATION" --name "$USERNAME" --password "$PASSWORD" --token "$ADMIN_TOKEN"
      else
        echo "User '$USERNAME' already exists."
      fi

      echo "Creating token for user '$USERNAME'..."
      TOKEN_JSON=$(influx auth create --host "$INSTANCE_HOST" --org "$ORGANIZATION" --user "$USERNAME" ${var.permission_flags} --token "$ADMIN_TOKEN" --json)
      USER_TOKEN=$(echo "$TOKEN_JSON" | jq -r '.token')

      echo "Saving secret to AWS Secrets Manager..."
      aws secretsmanager put-secret-value --secret-id "$SECRET_NAME" \
        --secret-string "$(jq -n \
          --arg timestream_instance "${var.timestream_influxdb_instance_endpoint}" \
          --arg timestream_organization "${var.timestream_influxdb_organization}" \
          --arg username "$USERNAME" \
          --arg password "$PASSWORD" \
          --arg token "$USER_TOKEN" \
          '{timestream_instance: $timestream_instance, timestream_organization: $timestream_organization, username: $username, password: $password, token: $token}'
        )"
    EOT
  }
}

resource "terraform_data" "delete_previous_user" {
  input = {
    instance_host                = format("https://%s:%s", var.timestream_influxdb_instance_endpoint, var.timestream_influxdb_instance_port)
    organization                 = var.timestream_influxdb_organization
    username                     = var.username
    admin_credentials_secret_arn = data.aws_secretsmanager_secret.timestream_influxdb_admin.arn
    secret_name                  = aws_secretsmanager_secret.this.name
  }

  triggers_replace = [
    var.username
  ]

  depends_on = [
    aws_secretsmanager_secret.this
  ]

  provisioner "local-exec" {
    environment = {
      INSTANCE_HOST                = self.input.instance_host
      ORGANIZATION                 = self.input.organization
      USERNAME                     = self.triggers_replace[0]
      CURRENT_USERNAME             = self.input.username
      ADMIN_CREDENTIALS_SECRET_ARN = self.input.admin_credentials_secret_arn
      SECRET_NAME                  = aws_secretsmanager_secret.this.name
    }

    command = <<EOT
      #!/bin/bash
      set -euo pipefail
      
      if [[ "$USERNAME" != "$CURRENT_USERNAME" ]]; then
        secret_json=$(aws secretsmanager get-secret-value --secret-id $ADMIN_CREDENTIALS_SECRET_ARN --query SecretString --output text)

        ADMIN_TOKEN=$(echo $secret_json | jq -r '.token')
        if [ -z "$ADMIN_TOKEN" ]; then
            echo "The admin token has not been set in the secret. The InfluxDB user update will be skipped."
            exit 0
        fi

        echo "Checking if user '$USERNAME' exists..."
        USER_EXISTS=$(influx user list --host "$INSTANCE_HOST" --org "$ORGANIZATION" --token "$ADMIN_TOKEN" --json | jq -r --arg name "$USERNAME" '.[] | select(.name == $name) | .id')

        if [ -z "$USER_EXISTS" ]; then
            echo "User '$USERNAME' does not exists."
        else
            echo "Updating user '$USERNAME'..."
            influx user update --host "$INSTANCE_HOST" --org "$ORGANIZATION" --id "$USERNAME" --name "$CURRENT_USERNAME" --token "$ADMIN_TOKEN"
        fi
        
        echo "Saving updated username into Secrets Manager..."
        aws secretsmanager put-secret-value --secret-id "$SECRET_NAME" \
            --secret-string "$(echo "$secret_json" | jq --arg username "$CURRENT_USERNAME" '. + {username: $username}')"
      fi
    EOT
  }
}

resource "terraform_data" "delete_user" {
  input = {
    instance_host                = format("https://%s:%s", var.timestream_influxdb_instance_endpoint, var.timestream_influxdb_instance_port)
    organization                 = var.timestream_influxdb_organization
    username                     = var.username
    admin_credentials_secret_arn = data.aws_secretsmanager_secret.timestream_influxdb_admin.arn
  }

  triggers_replace = [
    aws_secretsmanager_secret.this.id
  ]

  depends_on = [
    aws_secretsmanager_secret.this
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
      USER_EXISTS=$(influx user list --host "$INSTANCE_HOST" --org "$ORGANIZATION" --token "$ADMIN_TOKEN" --json | jq -r --arg name "$USERNAME" '.[] | select(.name == $name) | .id')

      if [ -z "$USER_EXISTS" ]; then
        echo "User '$USERNAME' does not exists."
      else
        echo "Deleting user '$USERNAME'..."
        influx user delete --host "$INSTANCE_HOST" --org "$ORGANIZATION" --id "$USERNAME" --token "$ADMIN_TOKEN"
      fi
    EOT
  }
}
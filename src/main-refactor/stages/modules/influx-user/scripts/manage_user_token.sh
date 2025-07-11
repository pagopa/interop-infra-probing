#!/bin/bash
set -euo pipefail

secret_json=$(aws secretsmanager get-secret-value --secret-id $ADMIN_CREDENTIALS_SECRET_ARN --query SecretString --output text)

ADMIN_TOKEN=$(echo $secret_json | jq -r '.token')
if [ -z "$ADMIN_TOKEN" ]; then
  echo "The admin token has not been set in the secret. The InfluxDB user creation will be skipped."
  exit 0
fi

echo "Checking if user '$USERNAME' exists..."

set +e
  USER_ID=$(influx user list --host "$INSTANCE_HOST" --token "$ADMIN_TOKEN" --name "$USERNAME" | awk 'NR>1 {print $1}')
  USER_LIST_EXIT_CODE=$?
set -e

if [ $USER_LIST_EXIT_CODE -ne 0 ]; then
  echo "User does not exist. Proceeding to create user."
  if [ -z "$USER_ID" ]; then
    echo "Creating user '$USERNAME'..."
    influx user create --host "$INSTANCE_HOST" --org "$ORGANIZATION" --name "$USERNAME" --password "$PASSWORD" --token "$ADMIN_TOKEN"
  fi
else
  echo "User '$USERNAME' already exists."
  exit 1
fi

FLAGS_ARGS=""
for flag in $PERMISSION_FLAGS; do
  FLAGS_ARGS+=" $flag"
done

echo "Retrieving buckets ID for which the user must be granted read permission..."
READ_BUCKET_IDS=()
for bucket in $GRANT_READ_ON_BUCKETS; do
  BUCKET_ID=$(influx bucket list --host "$INSTANCE_HOST" --org "$ORGANIZATION" --token "$ADMIN_TOKEN" --name "$bucket" | awk 'NR==2 {print $1}')
  READ_BUCKET_IDS+=("$BUCKET_ID")
done
READ_BUCKET_ARGS=""
if [ ${#READ_BUCKET_IDS[@]} -gt 0 ]; then
  READ_BUCKET_ARGS="--read-bucket ${READ_BUCKET_IDS[*]}"
fi

echo "Retrieving buckets ID for which the user must be granted write permission..."
WRITE_BUCKET_IDS=()
for bucket in $GRANT_WRITE_ON_BUCKETS; do
  BUCKET_ID=$(influx bucket list --host "$INSTANCE_HOST" --org "$ORGANIZATION" --token "$ADMIN_TOKEN" --name "$bucket" | awk 'NR==2 {print $1}')
  WRITE_BUCKET_IDS+=("$BUCKET_ID")
done
WRITE_BUCKET_ARGS=""
if [ ${#WRITE_BUCKET_IDS[@]} -gt 0 ]; then
  WRITE_BUCKET_ARGS="--write-bucket ${WRITE_BUCKET_IDS[*]}"
fi

echo "Creating token for user '$USERNAME'..."
TOKEN_JSON=$(influx auth create --host "$INSTANCE_HOST" --org "$ORGANIZATION" --user "$USERNAME" $FLAGS_ARGS $READ_BUCKET_ARGS $WRITE_BUCKET_ARGS --token "$ADMIN_TOKEN" --json)
USER_TOKEN=$(echo "$TOKEN_JSON" | jq -r '.token')

echo "Saving secret to AWS Secrets Manager..."
aws secretsmanager put-secret-value --secret-id "$SECRET_NAME" \
  --secret-string "$(jq -n \
    --arg timestream_instance "$INSTANCE_ENDPOINT" \
    --arg timestream_organization "$ORGANIZATION" \
    --arg username "$USERNAME" \
    --arg password "$PASSWORD" \
    --arg token "$USER_TOKEN" \
    '{timestream_instance: $timestream_instance, timestream_organization: $timestream_organization, username: $username, password: $password, token: $token}'
  )"
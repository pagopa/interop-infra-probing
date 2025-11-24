locals {
  be_app_influx_users = {
    telemetry_writer_user = {
      username               = "${var.stage}_probing_telemetry_writer_user",
      k8s_secret_name        = "${var.stage}-probing-analytics-db-telemetry-writer-user"
      grant_write_on_buckets = [var.timestream_instance_bucket_name]
    }
    statistics_api_user = {
      username              = "${var.stage}_probing_statistics_api_user",
      k8s_secret_name       = "${var.stage}-probing-analytics-db-statistics-api-user"
      grant_read_on_buckets = [var.timestream_instance_bucket_name]
    }
  }
}

module "probing_analytics_influx_users" {
  for_each = local.be_app_influx_users

  source = "./modules/influx-user"

  timestream_influxdb_instance_endpoint             = var.timestream_instance_endpoint
  timestream_influxdb_instance_port                 = var.timestream_instance_port
  timestream_influxdb_organization                  = var.timestream_instance_organization
  timestream_influxdb_admin_credentials_secret_name = var.probing_analytics_admin_secret_name

  username                  = each.value.username
  generated_password_length = 16

  grant_read_on_buckets  = try(each.value.grant_read_on_buckets, [])
  grant_write_on_buckets = try(each.value.grant_write_on_buckets, [])
  permission_flags       = try(each.value.permission_flags, [])

  secret_recovery_window_in_days = 0
  secret_prefix                  = "timestream/${var.timestream_instance_name}/users/"
  secret_tags                    = merge(local.eks_secret_default_tags, { EKSReplicaSecretName = each.value.k8s_secret_name })
}

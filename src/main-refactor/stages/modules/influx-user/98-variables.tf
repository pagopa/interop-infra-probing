variable "timestream_influxdb_instance_endpoint" {
  description = "Endpoint of the Timestream for InfluxDB instance"
  type        = string
}

variable "timestream_influxdb_instance_port" {
  description = "Port of the Timestream for InfluxDB instance"
  type        = number
  default     = 5432
}

variable "timestream_influxdb_organization" {
  description = "Organization name in the Timestream for InfluxDB instance"
  type        = string
}

variable "timestream_influxdb_admin_credentials_secret_name" {
  description = "Name of the SM secrets for the admin user in the Timestream for InfluxDB instance"
  type        = string
}

variable "username" {
  description = "Username to be created"
  type        = string
}

variable "generated_password_length" {
  description = "Length of the generated password for the user"
  type        = number
}

variable "grant_read_on_buckets" {
  description = "List of bucket names to which the user will be granted read access"
  type        = list(string)
  default     = []
}

variable "grant_write_on_buckets" {
  description = "List of bucket names to which the user will be granted write access"
  type        = list(string)
  default     = []
}

variable "permission_flags" {
  description = "List of flags that represent permissions to be granted to the user"
  type        = list(string)
  default     = []
}

variable "secret_prefix" {
  description = "Prefix of the SM secret that will be created"
  type        = string
}

variable "secret_tags" {
  description = "Tags to apply to the SM secret that will be created"
  type        = map(string)
  default     = {}
}

variable "secret_recovery_window_in_days" {
  description = "Number of days that AWS Secrets Manager waits before it can delete the secret"
  type        = number
  default     = 0
}
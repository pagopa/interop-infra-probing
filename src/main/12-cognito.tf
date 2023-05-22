resource "aws_cognito_user_pool" "user_pool" {
  name                = "${var.app_name}-user-pool-${var.env}"
  deletion_protection = "ACTIVE"
  mfa_configuration   = "OFF"

  account_recovery_setting {
    recovery_mechanism {
      name     = "verified_email"
      priority = 1
    }
    recovery_mechanism {
      name     = "verified_phone_number"
      priority = 2
    }
  }
  verification_message_template {
    default_email_option = "CONFIRM_WITH_CODE"
    email_message        = "{####} Insert html"
    email_subject        = "Confirmation subject"
  }
}
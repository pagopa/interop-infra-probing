resource "aws_cognito_user_pool" "user_pool" {
  name = "${var.app_name}-user-pool-${var.env}"
  deletion_protection = "ACTIVE"
  mfa_configuration = "OFF"
    invite_message_template {
        email_message = "{username} and {####} insert html"
        email_subject = "Invitation subject"
    }
    verification_message_template {
      default_email_option = "CONFIRM_WITH_CODE"
      email_message = "{####} Insert html"
      email_subject = "Confirmation subject"
    }
}
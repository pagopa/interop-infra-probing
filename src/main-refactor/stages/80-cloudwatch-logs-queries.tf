resource "aws_cloudwatch_query_definition" "app_logs_errors" {
  name = "Application-Logs-Errors-${title(var.stage)}"

  log_group_names = [var.eks_application_log_group_name]

  query_string = <<-EOT
    fields @timestamp, @message
    | sort @timestamp asc
    | filter (@message like /ERROR/ or stream = "stderr")
    | filter @logStream not like /adot-collector/
    | filter pod_namespace = "${var.stage}"
    # | filter pod_app like /probing-be-api/
  EOT
}

resource "aws_cloudwatch_query_definition" "cid_tracker" {
  name = "CID-Tracker-${title(var.stage)}"

  log_group_names = [var.eks_application_log_group_name]

  query_string = <<-EOT
    fields @timestamp, @message
    | sort @timestamp asc
    | parse @message "[CID=*]" as CID
    | filter CID = ""
    | filter pod_namespace = "${var.stage}"
    | display @message
  EOT
}

resource "aws_cloudwatch_query_definition" "apigw_5xx" {
  name = "APIGW-Probing-5xx-${title(var.stage)}"

  log_group_names = [aws_cloudwatch_log_group.apigw_access_logs.name]

  query_string = <<-EOT
    fields @timestamp, @message
    | filter apigwId = "${module.probing_apigw.apigw_id}"
    | filter status like /5./
    | sort @timestamp desc
  EOT
}

resource "aws_cloudwatch_query_definition" "apigw_waf_block" {
  name = "APIGW-Probing-WAF-Block-${title(var.stage)}"

  log_group_names = [aws_cloudwatch_log_group.apigw_access_logs.name]

  query_string = <<-EOT
    fields @timestamp, @message
    | filter apigwId = "${module.probing_apigw.apigw_id}"
    | filter wafStatus != "200"
    | sort @timestamp desc
  EOT
}

resource "aws_cloudwatch_query_definition" "apigw_extended_request_id" {
  name = "APIGW-Probing-ExtendedRequestId-${title(var.stage)}"

  log_group_names = [aws_cloudwatch_log_group.apigw_access_logs.name]

  query_string = <<-EOT
    SELECT APIGW.`@timestamp` as apigw_timestamp, APIGW.`@message` as apigw_message, WAF.`@message` as waf_message, WAF.`@timestamp` as waf_timestamp
    FROM "${aws_cloudwatch_log_group.apigw_access_logs.name}" as APIGW
    INNER JOIN "${aws_cloudwatch_log_group.probing_waf.name}" as WAF ON APIGW.`requestId` = WAF.`httpRequest.requestId`
    WHERE APIGW.extendedRequestId = ''
  EOT
}

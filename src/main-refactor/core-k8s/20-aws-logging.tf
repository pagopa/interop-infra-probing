resource "aws_cloudwatch_log_group" "fallback" {
  name = "/aws/eks/${data.aws_eks_cluster.this.name}/fallback"

  retention_in_days = var.container_logs_cloudwatch_retention_days
}

resource "kubernetes_config_map_v1" "aws_logging" {
  metadata {
    name      = "aws-logging"
    namespace = kubernetes_namespace_v1.aws_observability.metadata[0].name
  }

  data = {
    # ships fluent-bit process logs to CloudWatch.
    flb_log_cw = var.enable_fluentbit_process_logs

    "parsers.conf" = <<-EOT
      [PARSER]
          Name crio
          Format Regex
          Regex ^(?<time>[^ ]+) (?<stream>stdout|stderr) (?<logtag>P|F) (?<log>.*)$
          Time_Key    time
          Time_Format %Y-%m-%dT%H:%M:%S.%L%z
    EOT

    "filters.conf" = <<-EOT
      [FILTER]
          Name                parser
          Match               *
          Key_name            log
          Parser              crio
      [FILTER]
          Name                kubernetes
          Match               kube.*
          Merge_Log           Off
          Keep_log            Off
          Labels              On
          Buffer_Size         0
      [FILTER]
          Name                rewrite_tag
          Match               kube.*
          Rule                $kubernetes['labels']['app'] ^(.+)$ application.$0.$kubernetes['pod_name'] false
          Emitter_Name        rewrite_app_tag
      [FILTER]
          Name                nest
          Match               application.*
          Operation           lift
          Nested_under        kubernetes
          Add_prefix          kubernetes_
      [FILTER]
          Name                nest
          Match               application.*
          Operation           lift
          Nested_under        kubernetes_labels
          Add_prefix          kubernetes_labels_
      [FILTER]
          Name                modify
          Match               application.*
          Rename              kubernetes_labels_app pod_app
      [FILTER]
          Name                modify
          Match               application.*
          Rename              kubernetes_namespace_name pod_namespace
      [FILTER]
          Name                record_modifier
          Match               application.*
          Allowlist_key       log
          Allowlist_key       stream
          Allowlist_key       pod_app
          Allowlist_key       pod_namespace
    EOT

    "output.conf" = <<-EOT
      [OUTPUT]
          Name                     cloudwatch
          Match                    kube.*
          region                   ${var.aws_region}
          auto_create_group        true
          log_retention_days       ${var.container_logs_cloudwatch_retention_days}
          log_group_name           /aws/eks/${data.aws_eks_cluster.this.name}/other
          log_stream_name          $(kubernetes['pod_name'])
          default_log_group_name   ${aws_cloudwatch_log_group.fallback.name}
          default_log_stream_name  $(tag)
      [OUTPUT]
          Name                     cloudwatch
          Match                    application.*
          region                   ${var.aws_region}
          auto_create_group        true
          log_retention_days       ${var.container_logs_cloudwatch_retention_days}
          log_group_name           /aws/eks/${data.aws_eks_cluster.this.name}/application
          log_stream_name          $(tag[2])
          default_log_group_name   ${aws_cloudwatch_log_group.fallback.name}
          default_log_stream_name  $(tag)
    EOT
  }
}

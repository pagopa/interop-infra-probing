# TODO: check if EKS ADOT addon is better

data "aws_iam_role" "adot_collector" {
  name = var.adot_collector_role_name
}

resource "kubernetes_service_account_v1" "adot_collector" {
  metadata {
    name      = "adot-collector"
    namespace = kubernetes_namespace_v1.aws_observability.metadata[0].name

    labels = {
      "app.kubernetes.io/name" = "adot-collector"
    }

    annotations = {
      "eks.amazonaws.com/role-arn" = data.aws_iam_role.adot_collector.arn
    }
  }
}

resource "kubernetes_service_v1" "adot_collector" {
  metadata {
    name      = "adot-collector-service"
    namespace = kubernetes_namespace_v1.aws_observability.metadata[0].name

    labels = {
      app       = "aws-adot"
      component = "adot-collector"
    }
  }

  spec {
    type = "ClusterIP"

    port {
      name = "metric"
      port = 8888
    }

    selector = {
      component = "adot-collector"
    }
  }
}

resource "kubernetes_cluster_role_v1" "adot_collector" {
  metadata {
    name = "adot-collector-role"
  }

  rule {
    api_groups = [""]
    resources = [
      "nodes",
      "nodes/proxy",
      "nodes/metrics",
      "services",
      "endpoints",
      "pods",
      "pods/proxy",
      "configmaps"
    ]
    verbs = ["get", "list", "watch"]
  }

  rule {
    non_resource_urls = ["/metrics/cadvisor", "/metrics"]
    verbs             = ["get", "list", "watch"]
  }
}

resource "kubernetes_cluster_role_binding_v1" "adot_collector" {
  metadata {
    name = "adot-collector-cluster-role-binding"
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = kubernetes_cluster_role_v1.adot_collector.metadata[0].name
  }

  subject {
    kind      = "ServiceAccount"
    name      = kubernetes_service_account_v1.adot_collector.metadata[0].name
    namespace = kubernetes_namespace_v1.aws_observability.metadata[0].name
  }
}

resource "kubernetes_config_map_v1" "adot_collector" {
  metadata {
    name      = "adot-collector-config"
    namespace = kubernetes_namespace_v1.aws_observability.metadata[0].name

    labels = {
      app       = "aws-adot"
      component = "adot-collector-config"
    }
  }

  data = {
    adot-collector-config = <<-EOT
      receivers:
        prometheus:
          config:
            scrape_configs:
            - job_name: 'kubelets-cadvisor-metrics'
              scrape_interval: 20s
              scrape_timeout: 10s
              scheme: https

              kubernetes_sd_configs:
              - role: node
              tls_config:
                ca_file: /var/run/secrets/kubernetes.io/serviceaccount/ca.crt
              bearer_token_file: /var/run/secrets/kubernetes.io/serviceaccount/token

              relabel_configs:
                - action: labelmap
                  regex: __meta_kubernetes_node_label_(.+)
                  # Only for Kubernetes ^1.7.3.
                  # See: https://github.com/prometheus/prometheus/issues/2916
                - target_label: __address__
                  # Changes the address to Kube API server's default address and port
                  replacement: kubernetes.default.svc:443
                - source_labels: [__meta_kubernetes_node_name]
                  regex: (.+)
                  target_label: __metrics_path__
                  # Changes the default metrics path to kubelet's proxy cadvdisor metrics endpoint
                  replacement: /api/v1/nodes/$$${1}/proxy/metrics/cadvisor

              metric_relabel_configs:
                # extract readable container/pod name from id field
                - action: replace
                  source_labels: [id]
                  regex: '^/machine\.slice/machine-rkt\\x2d([^\\]+)\\.+/([^/]+)\.service$'
                  target_label: rkt_container_name
                  replacement: '$$${2}-$$${1}'
                - action: replace
                  source_labels: [id]
                  regex: '^/system\.slice/(.+)\.service$'
                  target_label: systemd_service_name
                  replacement: '$$${1}'
                - action: replace
                  source_labels: [pod]
                  regex: '^(.+)-([^-]*-[^-]*)'
                  target_label: Service
                  replacement: '$$${1}'
                - action: replace
                  source_labels: [pod]
                  regex: '^(.+)-\d$'
                  target_label: Service
                  replacement: '$$${1}'

        prometheus/ksm:
          config:
            scrape_configs:
            - job_name: 'kube-state-metrics'
              scrape_interval: 15s
              scrape_timeout: 7s
              static_configs:
                - targets: ['kube-state-metrics.aws-observability.svc.cluster.local:8080']
              metric_relabel_configs:
                - action: replace
                  source_labels: [pod]
                  regex: '^(.+)-([^-]*-[^-]*)'
                  target_label: Service
                  replacement: '$$${1}'
                - action: replace
                  source_labels: [pod]
                  regex: '^(.+)-\d$'
                  target_label: Service
                  replacement: '$$${1}'
                - action: replace
                  source_labels: [namespace]
                  target_label: Namespace

      processors:
        # rename labels which apply to all metrics and are used in metricstransform/rename processor
        metricstransform/label_1:
          transforms:
            - include: .*
              match_type: regexp
              action: update
              operations:
                - action: update_label
                  label: name
                  new_label: container_id
                - action: update_label
                  label: kubernetes_io_hostname
                  new_label: NodeName
                - action: update_label
                  label: eks_amazonaws_com_compute_type
                  new_label: LaunchType

        # rename container and pod metrics which we care about.
        # container metrics are renamed to `new_container_*` to differentiate them with unused container metrics
        metricstransform/rename:
          transforms:
            - include: container_spec_cpu_quota
              new_name: new_container_cpu_limit_raw
              action: insert
              match_type: regexp
              experimental_match_labels: {"container": "\\S", "LaunchType": "fargate"}
            - include: container_spec_cpu_shares
              new_name: new_container_cpu_request
              action: insert
              match_type: regexp
              experimental_match_labels: {"container": "\\S", "LaunchType": "fargate"}
            - include: container_cpu_usage_seconds_total
              new_name: new_container_cpu_usage_seconds_total
              action: insert
              match_type: regexp
              experimental_match_labels: {"container": "\\S", "LaunchType": "fargate"}
            - include: container_spec_memory_limit_bytes
              new_name: new_container_memory_limit
              action: insert
              match_type: regexp
              experimental_match_labels: {"container": "\\S", "LaunchType": "fargate"}
            - include: container_memory_cache
              new_name: new_container_memory_cache
              action: insert
              match_type: regexp
              experimental_match_labels: {"container": "\\S", "LaunchType": "fargate"}
            - include: container_memory_max_usage_bytes
              new_name: new_container_memory_max_usage
              action: insert
              match_type: regexp
              experimental_match_labels: {"container": "\\S", "LaunchType": "fargate"}
            - include: container_memory_usage_bytes
              new_name: new_container_memory_usage
              action: insert
              match_type: regexp
              experimental_match_labels: {"container": "\\S", "LaunchType": "fargate"}
            - include: container_memory_working_set_bytes
              new_name: new_container_memory_working_set
              action: insert
              match_type: regexp
              experimental_match_labels: {"container": "\\S", "LaunchType": "fargate"}
            - include: container_memory_rss
              new_name: new_container_memory_rss
              action: insert
              match_type: regexp
              experimental_match_labels: {"container": "\\S", "LaunchType": "fargate"}
            - include: container_memory_swap
              new_name: new_container_memory_swap
              action: insert
              match_type: regexp
              experimental_match_labels: {"container": "\\S", "LaunchType": "fargate"}
            - include: container_memory_failcnt
              new_name: new_container_memory_failcnt
              action: insert
              match_type: regexp
              experimental_match_labels: {"container": "\\S", "LaunchType": "fargate"}
            - include: container_memory_failures_total
              new_name: new_container_memory_hierarchical_pgfault
              action: insert
              match_type: regexp
              experimental_match_labels: {"container": "\\S", "LaunchType": "fargate", "failure_type": "pgfault", "scope": "hierarchy"}
            - include: container_memory_failures_total
              new_name: new_container_memory_hierarchical_pgmajfault
              action: insert
              match_type: regexp
              experimental_match_labels: {"container": "\\S", "LaunchType": "fargate", "failure_type": "pgmajfault", "scope": "hierarchy"}
            - include: container_memory_failures_total
              new_name: new_container_memory_pgfault
              action: insert
              match_type: regexp
              experimental_match_labels: {"container": "\\S", "LaunchType": "fargate", "failure_type": "pgfault", "scope": "container"}
            - include: container_memory_failures_total
              new_name: new_container_memory_pgmajfault
              action: insert
              match_type: regexp
              experimental_match_labels: {"container": "\\S", "LaunchType": "fargate", "failure_type": "pgmajfault", "scope": "container"}
            - include: container_fs_limit_bytes
              new_name: new_container_filesystem_capacity
              action: insert
              match_type: regexp
              experimental_match_labels: {"container": "\\S", "LaunchType": "fargate"}
            - include: container_fs_usage_bytes
              new_name: new_container_filesystem_usage
              action: insert
              match_type: regexp
              experimental_match_labels: {"container": "\\S", "LaunchType": "fargate"}
            # POD LEVEL METRICS
            - include: container_spec_cpu_quota
              new_name: pod_cpu_limit_raw
              action: insert
              match_type: regexp
              experimental_match_labels: {"image": "^$", "container": "^$", "pod": "\\S", "LaunchType": "fargate"}
            - include: container_spec_cpu_shares
              new_name: pod_cpu_request
              action: insert
              match_type: regexp
              experimental_match_labels: {"image": "^$", "container": "^$", "pod": "\\S", "LaunchType": "fargate"}
            - include: container_cpu_usage_seconds_total
              new_name: pod_cpu_usage_seconds_total
              action: insert
              match_type: regexp
              experimental_match_labels: {"image": "^$", "container": "^$", "pod": "\\S", "LaunchType": "fargate"}
            - include: container_spec_memory_limit_bytes
              new_name: pod_memory_limit
              action: insert
              match_type: regexp
              experimental_match_labels: {"image": "^$", "container": "^$", "pod": "\\S", "LaunchType": "fargate"}
            - include: container_memory_cache
              new_name: pod_memory_cache
              action: insert
              match_type: regexp
              experimental_match_labels: {"image": "^$", "container": "^$", "pod": "\\S", "LaunchType": "fargate"}
            - include: container_memory_max_usage_bytes
              new_name: pod_memory_max_usage
              action: insert
              match_type: regexp
              experimental_match_labels: {"image": "^$", "container": "^$", "pod": "\\S", "LaunchType": "fargate"}
            - include: container_memory_usage_bytes
              new_name: pod_memory_usage
              action: insert
              match_type: regexp
              experimental_match_labels: {"image": "^$", "container": "^$", "pod": "\\S", "LaunchType": "fargate"}
            - include: container_memory_working_set_bytes
              new_name: pod_memory_working_set
              action: insert
              match_type: regexp
              experimental_match_labels: {"image": "^$", "container": "^$", "pod": "\\S", "LaunchType": "fargate"}
            - include: container_memory_rss
              new_name: pod_memory_rss
              action: insert
              match_type: regexp
              experimental_match_labels: {"image": "^$", "container": "^$", "pod": "\\S", "LaunchType": "fargate"}
            - include: container_memory_swap
              new_name: pod_memory_swap
              action: insert
              match_type: regexp
              experimental_match_labels: {"image": "^$", "container": "^$", "pod": "\\S", "LaunchType": "fargate"}
            - include: container_memory_failcnt
              new_name: pod_memory_failcnt
              action: insert
              match_type: regexp
              experimental_match_labels: {"image": "^$", "container": "^$", "pod": "\\S", "LaunchType": "fargate"}
            - include: container_memory_failures_total
              new_name: pod_memory_hierarchical_pgfault
              action: insert
              match_type: regexp
              experimental_match_labels: {"image": "^$", "container": "^$", "pod": "\\S", "LaunchType": "fargate", "failure_type": "pgfault", "scope": "hierarchy"}
            - include: container_memory_failures_total
              new_name: pod_memory_hierarchical_pgmajfault
              action: insert
              match_type: regexp
              experimental_match_labels: {"image": "^$", "container": "^$", "pod": "\\S", "LaunchType": "fargate", "failure_type": "pgmajfault", "scope": "hierarchy"}
            - include: container_memory_failures_total
              new_name: pod_memory_pgfault
              action: insert
              match_type: regexp
              experimental_match_labels: {"image": "^$", "container": "^$", "pod": "\\S", "LaunchType": "fargate", "failure_type": "pgfault", "scope": "container"}
            - include: container_memory_failures_total
              new_name: pod_memory_pgmajfault
              action: insert
              match_type: regexp
              experimental_match_labels: {"image": "^$", "container": "^$", "pod": "\\S", "LaunchType": "fargate", "failure_type": "pgmajfault", "scope": "container"}
            - include: container_network_receive_bytes_total
              new_name: pod_network_rx_bytes
              action: insert
              match_type: regexp
              experimental_match_labels: {"pod": "\\S", "LaunchType": "fargate"}
            - include: container_network_receive_packets_dropped_total
              new_name: pod_network_rx_dropped
              action: insert
              match_type: regexp
              experimental_match_labels: {"pod": "\\S", "LaunchType": "fargate"}
            - include: container_network_receive_errors_total
              new_name: pod_network_rx_errors
              action: insert
              match_type: regexp
              experimental_match_labels: {"pod": "\\S", "LaunchType": "fargate"}
            - include: container_network_receive_packets_total
              new_name: pod_network_rx_packets
              action: insert
              match_type: regexp
              experimental_match_labels: {"pod": "\\S", "LaunchType": "fargate"}
            - include: container_network_transmit_bytes_total
              new_name: pod_network_tx_bytes
              action: insert
              match_type: regexp
              experimental_match_labels: {"pod": "\\S", "LaunchType": "fargate"}
            - include: container_network_transmit_packets_dropped_total
              new_name: pod_network_tx_dropped
              action: insert
              match_type: regexp
              experimental_match_labels: {"pod": "\\S", "LaunchType": "fargate"}
            - include: container_network_transmit_errors_total
              new_name: pod_network_tx_errors
              action: insert
              match_type: regexp
              experimental_match_labels: {"pod": "\\S", "LaunchType": "fargate"}
            - include: container_network_transmit_packets_total
              new_name: pod_network_tx_packets
              action: insert
              match_type: regexp
              experimental_match_labels: {"pod": "\\S", "LaunchType": "fargate"}

        # filter out only renamed metrics which we care about
        filter:
          metrics:
            include:
              match_type: regexp
              metric_names:
                - new_container_.*
                - pod_.*
                - kube_pod_status_replicas_.*
                - kube_pod_status_phase.*
                - kube_pod_container_status_restarts_total

        filter/deployment:
          metrics:
            include:
              match_type: regexp
              metric_names:
                - kube_deployment_status_replicas.*
                - kube_statefulset_status_replicas.*

        # convert cumulative sum datapoints to delta
        cumulativetodelta:
          include:
            metrics:
              - new_container_cpu_usage_seconds_total
              - pod_cpu_usage_seconds_total
              - pod_memory_pgfault
              - pod_memory_pgmajfault
              - pod_memory_hierarchical_pgfault
              - pod_memory_hierarchical_pgmajfault
              - pod_network_rx_bytes
              - pod_network_rx_dropped
              - pod_network_rx_errors
              - pod_network_rx_packets
              - pod_network_tx_bytes
              - pod_network_tx_dropped
              - pod_network_tx_errors
              - pod_network_tx_packets
              - new_container_memory_pgfault
              - new_container_memory_pgmajfault
              - new_container_memory_hierarchical_pgfault
              - new_container_memory_hierarchical_pgmajfault
            match_type: strict

        # convert delta to rate
        deltatorate:
          metrics:
            - new_container_cpu_usage_seconds_total
            - pod_cpu_usage_seconds_total
            - pod_memory_pgfault
            - pod_memory_pgmajfault
            - pod_memory_hierarchical_pgfault
            - pod_memory_hierarchical_pgmajfault
            - pod_network_rx_bytes
            - pod_network_rx_dropped
            - pod_network_rx_errors
            - pod_network_rx_packets
            - pod_network_tx_bytes
            - pod_network_tx_dropped
            - pod_network_tx_errors
            - pod_network_tx_packets
            - new_container_memory_pgfault
            - new_container_memory_pgmajfault
            - new_container_memory_hierarchical_pgfault
            - new_container_memory_hierarchical_pgmajfault


        experimental_metricsgeneration/1:
          rules:
            - name: pod_network_total_bytes
              unit: Bytes/Second
              type: calculate
              metric1: pod_network_rx_bytes
              metric2: pod_network_tx_bytes
              operation: add
            - name: pod_memory_utilization_over_pod_limit
              unit: Percent
              type: calculate
              metric1: pod_memory_working_set
              metric2: pod_memory_limit
              operation: percent
            - name: pod_cpu_usage_total
              unit: Millicore
              type: scale
              metric1: pod_cpu_usage_seconds_total
              operation: multiply
              # core to millicore: multiply by 1000
              # millicore seconds to millicore nanoseconds: multiply by 10^9
              scale_by: 1000
            - name: pod_cpu_limit
              unit: Millicore
              type: scale
              metric1: pod_cpu_limit_raw
              operation: divide
              scale_by: 100

        experimental_metricsgeneration/2:
          rules:
            - name: pod_cpu_utilization_over_pod_limit
              type: calculate
              unit: Percent
              metric1: pod_cpu_usage_total
              metric2: pod_cpu_limit
              operation: percent


        # add `Type` and rename metrics and labels
        metricstransform/label_2:
          transforms:
            - include: pod_.*
              match_type: regexp
              action: update
              operations:
                - action: add_label
                  new_label: Type
                  new_value: "Pod"
            - include: new_container_.*
              match_type: regexp
              action: update
              operations:
                - action: add_label
                  new_label: Type
                  new_value: Container
            - include: .*
              match_type: regexp
              action: update
              operations:
                - action: update_label
                  label: namespace
                  new_label: Namespace
                - action: update_label
                  label: pod
                  new_label: PodName
            - include: kube_deployment.*
              match_type: regexp
              action: update
              operations:
                - action: update_label
                  label: namespace
                  new_label: Namespace
                - action: update_label
                  label: deployment
                  new_label: Service
            - include: kube_pod.*
              match_type: regexp
              action: update
              operations:
                - action: update_label
                  label: namespace
                  new_label: Namespace
                - action: update_label
                  label: phase
                  new_label: Phase
                - action: update_label
                  label: container
                  new_label: Container
            - include: ^new_container_(.*)$$
              match_type: regexp
              action: update
              new_name: container_$$1

        metricstransform/deployment:
          transforms:
            - include: kube_deployment.*
              match_type: regexp
              action: update
              operations:
                - action: update_label
                  label: namespace
                  new_label: Namespace
                - action: update_label
                  label: deployment
                  new_label: Service

        # add cluster name from env variable and EKS metadata
        resourcedetection:
          detectors: [env, eks]

        batch:
          timeout: 45s
        batch/deployment:
          timeout: 30s

      exporters:
        awsemf:
          log_group_name: '/aws/eks/{ClusterName}/adot-metrics'
          log_stream_name: '{PodName}'
          namespace: 'ContainerInsights'
          region: ${var.aws_region}
          resource_to_telemetry_conversion:
            enabled: true
          eks_fargate_container_insights_enabled: true
          parse_json_encoded_attr_values: ["kubernetes"]
          dimension_rollup_option: NoDimensionRollup
          metric_declarations:
            - dimensions: [[ClusterName, Namespace, Service]]
              metric_name_selectors:
                - pod_cpu_usage_total
                - pod_cpu_limit
                - pod_memory_working_set
                - pod_memory_limit
                - pod_network_rx_bytes
                - pod_network_tx_bytes
                - kube_pod_container_status_restarts_total
            - dimensions: [[ClusterName, Namespace, Service],[ClusterName, Namespace, Service, PodName]]
              metric_name_selectors:
                - pod_cpu_utilization_over_pod_limit
                - pod_memory_utilization_over_pod_limit

        awsemf/deployment:
          log_group_name: '/aws/eks/{ClusterName}/adot-metrics'
          log_stream_name: 'service_metrics'
          namespace: 'ContainerInsights'
          region: ${var.aws_region}
          resource_to_telemetry_conversion:
            enabled: true
          eks_fargate_container_insights_enabled: true
          parse_json_encoded_attr_values: ["kubernetes"]
          dimension_rollup_option: NoDimensionRollup
          max_retries: 5
          metric_declarations:
            - dimensions: [[ClusterName, Namespace, Service]]
              metric_name_selectors:
                - kube_deployment_status_replicas
                - kube_deployment_status_replicas_available
                - kube_statefulset_status_replicas
                - kube_statefulset_status_replicas_available

      extensions:
        health_check:

      service:
        telemetry:
          logs:
            level: "info"
        pipelines:
          metrics:
            receivers: [prometheus, prometheus/ksm]
            processors: [metricstransform/label_1, resourcedetection, metricstransform/rename, filter, cumulativetodelta, deltatorate, experimental_metricsgeneration/1, experimental_metricsgeneration/2, metricstransform/label_2, batch]
            exporters: [awsemf]
          metrics/deployment:
            receivers: [prometheus/ksm]
            processors: [resourcedetection, filter/deployment, metricstransform/deployment, batch/deployment]
            exporters: [awsemf/deployment]
        extensions: [health_check]
    EOT
  }
}

resource "kubernetes_stateful_set_v1" "adot_colector" {
  metadata {
    name      = "adot-collector"
    namespace = kubernetes_namespace_v1.aws_observability.metadata[0].name

    labels = {
      app       = "aws-adot"
      component = "adot-collector"
    }
  }

  spec {
    selector {
      match_labels = {
        app       = "aws-adot"
        component = "adot-collector"
      }
    }

    service_name = kubernetes_service_v1.adot_collector.metadata[0].name

    template {
      metadata {
        labels = {
          app       = "aws-adot"
          component = "adot-collector"
        }
      }

      spec {
        service_account_name = kubernetes_service_account_v1.adot_collector.metadata[0].name

        security_context {
          fs_group = 65534
        }

        container {
          name              = "adot-collector"
          image             = var.adot_collector_image_uri
          image_pull_policy = "Always"
          command = [
            "/awscollector",
            "--config=/conf/adot-collector-config.yaml"
          ]
          env {
            name  = "OTEL_RESOURCE_ATTRIBUTES"
            value = format("ClusterName=%s", data.aws_eks_cluster.this.name)
          }

          resources {
            limits = {
              cpu    = var.adot_collector_cpu
              memory = var.adot_collector_memory
            }
            requests = {
              cpu    = var.adot_collector_cpu
              memory = var.adot_collector_memory
            }
          }

          volume_mount {
            name       = "adot-collector-config-volume"
            mount_path = "/conf"
          }
        }

        volume {
          name = "adot-collector-config-volume"

          config_map {
            name = kubernetes_config_map_v1.adot_collector.metadata[0].name
            items {
              key  = "adot-collector-config"
              path = "adot-collector-config.yaml"
            }
          }
        }
      }
    }
  }
}

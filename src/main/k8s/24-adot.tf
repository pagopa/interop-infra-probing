resource "kubernetes_cluster_role_v1" "adcot_admin_role" {
  metadata {
    name = "adotcol-admin-role"
  }

  rule {
    api_groups = [""]
    resources = ["nodes",
      "nodes/proxy",
      "nodes/metrics",
      "services",
      "endpoints",
      "pods",
    "pods/proxy"]
    verbs             = ["get", "list", "watch"]
    non_resource_urls = ["/metrics/cadvisor"]

  }
}

resource "kubernetes_cluster_role_binding_v1" "adcot_admin_role_binding" {
  metadata {
    name = "adotcol-admin-role-binding"
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "adotcol-admin-role"
  }
  subject {
    kind      = "ServiceAccount"
    name      = "adot-collector"
    api_group = "rbac.authorization.k8s.io"
  }
}

resource "kubernetes_config_map_v1" "adot_collector_config" {
  metadata {
    name      = "adot-collector-config"
    namespace = "opentelemetry-operator-system"
    labels = {
      app       = "aws-adot"
      component = "adot-collector-config"
    }

  }

  data = {
    adot-collector-config = templatefile("${path.module}/assets/adot/configmap.yaml.tfpl", { aws_region = var.aws_region })
  }

}

resource "kubernetes_api_service_v1" "adot_collector_service" {
  metadata {
    name      = "adot-collector-service"
    namespace = "opentelemetry-operator-system"
    labels = {

      app       = "aws-adot"
      component = "adot-collector"
    }
  }
  spec {
    selector {
      component = "adot-collector"
    }
    session_affinity = "ClientIP"
    ports {
      port = 8888
      name = "metrics"
    }

    type = "ClusterIP"
  }
}


resource "k8s_apps_v1_stateful_set" "adot_collector_statefulset" {

  metadata {

    labels = { app = "aws-adot"
    component = "adot-collector" }
    name      = "adot-collector"
    namespace = "opentelemetry-operator-system"
  }

  spec {


    selector {


      match_labels = { app = "aws-adot"
      component = "adot-collector" }
    }
    service_name = "adot-collector-service"

    template {

      metadata {

        labels = { app = "aws-adot"
        component = "adot-collector" }
      }

      spec {
        active_deadline_seconds = "TypeInt"



        containers {
          command = ["/awscollector", -"--config=/conf/adot-collector-config.yaml"]

          env {
            name  = "OTEL_RESOURCE_ATTRIBUTES"
            value = "ClusterName=${eks_cluster_name}"
          }

          image             = "public.ecr.aws/aws-observability/aws-otel-collector:latest"
          image_pull_policy = "Always"

          name = "adot-collector"

          ports {
            container_port = "TypeInt*"
            host_ip        = "TypeString"
            host_port      = "TypeInt"
            name           = "TypeString"
            protocol       = "TypeString"
          }


          resources {
            limits = { cpu = "1",
            memory = "2Gi" }
            requests = { cpu = "1",
            memory = "2Gi" }
          }






          volume_mounts {
            mount_path = "/conf"

            name = "adot-collector-config-volume"

          }

        }




        security_context {
          fsgroup = 65534
        }
        service_account                  = "TypeString"
        service_account_name             = "TypeString"
        share_process_namespace          = "TypeString"
        subdomain                        = "TypeString"
        termination_grace_period_seconds = "TypeInt"


        volumes {



          config_map {


            items {
              key  = "adot-collector-config"
              path = "adot-collector-config.yaml"
            }
            name = "adot-collector-config"

          }


          name = "adot-collector-config-volume"


        }
      }
    }


  }
}
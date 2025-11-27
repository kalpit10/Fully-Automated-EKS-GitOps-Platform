locals {
  dashboard_body = jsonencode({
    widgets = [

      # ROW 1 — Cluster CPU & Memory
      {
        "type" : "metric",
        "x" : 0, "y" : 0,
        "width" : 24, "height" : 6,
        "properties" : {
          "title" : "Cluster CPU & Memory (${var.cluster_name})",
          "view" : "timeSeries",
          "metrics" : [
            ["ContainerInsights", "node_cpu_utilization", "ClusterName", var.cluster_name],
            ["ContainerInsights", "node_memory_utilization", "ClusterName", var.cluster_name]
          ],
          "region" : var.region
        }
      },

      # ROW 2 — Running pods per node / namespace
      {
        "type" : "metric",
        "x" : 0, "y" : 6,
        "width" : 12, "height" : 6,
        "properties" : {
          "title" : "Running Pods per Node",
          "view" : "timeSeries",
          "metrics" : [
            ["ContainerInsights", "node_number_of_running_pods", "ClusterName", var.cluster_name]
          ],
          "region" : var.region
        }
      },
      {
        "type" : "metric",
        "x" : 12, "y" : 6,
        "width" : 12, "height" : 6,
        "properties" : {
          "title" : "Running Pods in Namespace (${var.namespace})",
          "view" : "timeSeries",
          "metrics" : [
            [
              "ContainerInsights",
              "namespace_number_of_running_pods",
              "ClusterName", var.cluster_name,
              "Namespace", var.namespace
            ]
          ],
          "region" : var.region
        }
      },

      # ROW 3 — Pod CPU + Restarts
      {
        "type" : "metric",
        "x" : 0, "y" : 12,
        "width" : 12, "height" : 6,
        "properties" : {
          "title" : "Pod CPU Utilization (ns: ${var.namespace})",
          "view" : "timeSeries",
          "metrics" : [
            [
              "ContainerInsights",
              "pod_cpu_utilization",
              "ClusterName", var.cluster_name,
              "Namespace", var.namespace
            ]
          ],
          "region" : var.region
        }
      },
      {
        "type" : "metric",
        "x" : 12, "y" : 12,
        "width" : 12, "height" : 6,
        "properties" : {
          "title" : "Pod Container Restarts",
          "view" : "timeSeries",
          "metrics" : [
            [
              "ContainerInsights",
              "pod_number_of_container_restarts",
              "ClusterName", var.cluster_name,
              "Namespace", var.namespace
            ]
          ],
          "region" : var.region
        }
      },

      # ROW 4 — ALB Request Count & Latency (SEARCH-based)
      {
        "type" : "metric",
        "x" : 0, "y" : 18,
        "width" : 12, "height" : 6,
        "properties" : {
          "title" : "ALB Request Count (Dynamic)",
          "view" : "timeSeries",
          "metrics" : [
            [
              {
                "expression" : "SEARCH('{AWS/ApplicationELB,LoadBalancer} \"${var.alb_name}\"', 'Sum', 300)",
                "label" : "RequestCount (ALB Auto-Detected)",
                "id" : "e1"
              }
            ]
          ],
          "region" : var.region
        }
      },
      {
        "type" : "metric",
        "x" : 12, "y" : 18,
        "width" : 12, "height" : 6,
        "properties" : {
          "title" : "ALB Target Response Time (Dynamic)",
          "view" : "timeSeries",
          "metrics" : [
            [
              {
                "expression" : "SEARCH('{AWS/ApplicationELB,LoadBalancer} \"${var.alb_name}\"', 'Average', 300)",
                "label" : "TargetResponseTime (ALB Auto-Detected)",
                "id" : "e2"
              }
            ]
          ],
          "region" : var.region
        }
      },

      # ROW 5 — ALB 4XX & 5XX Errors (also SEARCH-based)
      {
        "type" : "metric",
        "x" : 0, "y" : 24,
        "width" : 12, "height" : 6,
        "properties" : {
          "title" : "ALB HTTP 4XX Errors",
          "view" : "timeSeries",
          "metrics" : [
            [
              {
                "expression" : "SEARCH('{AWS/ApplicationELB,LoadBalancer} \"${var.alb_name}\"', 'Sum', 300)",
                "label" : "HTTP 4XX (ALB Auto-Detected)",
                "id" : "e3"
              }
            ]
          ],
          "region" : var.region
        }
      },
      {
        "type" : "metric",
        "x" : 12, "y" : 24,
        "width" : 12, "height" : 6,
        "properties" : {
          "title" : "ALB HTTP 5XX Errors",
          "view" : "timeSeries",
          "metrics" : [
            [
              {
                "expression" : "SEARCH('{AWS/ApplicationELB,LoadBalancer} \"${var.alb_name}\"', 'Sum', 300)",
                "label" : "HTTP 5XX (ALB Auto-Detected)",
                "id" : "e4"
              }
            ]
          ],
          "region" : var.region
        }
      }
    ]
  })
}

resource "aws_cloudwatch_dashboard" "eks_observability" {
  dashboard_name = "eks-observability-${var.env}"
  dashboard_body = local.dashboard_body
}

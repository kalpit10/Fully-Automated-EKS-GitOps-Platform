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

      # ROW 4 — ALB Request Count & Response Time
      # SEARCH scoped by MetricName so each panel shows exactly one metric.
      # The stable substring "k8s-proshop" matches the LBC-generated ALB name
      # regardless of the hash suffix that changes on every redeploy.
      {
        "type" : "metric",
        "x" : 0, "y" : 18,
        "width" : 12, "height" : 6,
        "properties" : {
          "title" : "ALB Request Count",
          "view" : "timeSeries",
          "metrics" : [
            [
              {
                "expression" : "SEARCH('{AWS/ApplicationELB,LoadBalancer} MetricName=\"RequestCount\" \"${var.alb_name_prefix}\"', 'Sum', 60)",
                "label" : "RequestCount",
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
          "title" : "ALB Target Response Time (avg seconds)",
          "view" : "timeSeries",
          "metrics" : [
            [
              {
                "expression" : "SEARCH('{AWS/ApplicationELB,LoadBalancer} MetricName=\"TargetResponseTime\" \"${var.alb_name_prefix}\"', 'Average', 60)",
                "label" : "TargetResponseTime",
                "id" : "e2"
              }
            ]
          ],
          "region" : var.region
        }
      },

      # ROW 5 — ALB 4XX and 5XX Errors
      # Each panel uses a different MetricName — this is what was missing before.
      # HTTPCode_Target_4XX_Count and HTTPCode_Target_5XX_Count are distinct metrics
      # in the AWS/ApplicationELB namespace. Without MetricName scoping, both panels
      # run an identical SEARCH and show identical data.
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
                "expression" : "SEARCH('{AWS/ApplicationELB,LoadBalancer} MetricName=\"HTTPCode_Target_4XX_Count\" \"${var.alb_name_prefix}\"', 'Sum', 60)",
                "label" : "HTTP 4XX Count",
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
                "expression" : "SEARCH('{AWS/ApplicationELB,LoadBalancer} MetricName=\"HTTPCode_Target_5XX_Count\" \"${var.alb_name_prefix}\"', 'Sum', 60)",
                "label" : "HTTP 5XX Count",
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

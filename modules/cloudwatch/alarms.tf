# ── ALB data source ────────────────────────────────────────────────────────────
# The LBC automatically tags every ALB it creates with:
#   ingress.k8s.aws/stack = <namespace>/<ingress-name>
# This tag is stable across destroy/redeploy cycles. The ALB name and ARN
# suffix change with every redeploy — this tag never does.
# Constraint: this data source requires the ALB to exist at apply time.
# During standup, apply the cloudwatch module AFTER ArgoCD has synced the ingress.

data "aws_lb" "proshop" {
  tags = {
    "ingress.k8s.aws/stack" = "${var.namespace}/proshop-ingress"
  }
}

# ── SNS Topic & Email Subscription ────────────────────────────────────────────

resource "aws_sns_topic" "cloudwatch_alarms" {
  name              = "eks-cloudwatch-alarms-${var.env}"
  kms_master_key_id = "alias/aws/sns"
}

resource "aws_sns_topic_subscription" "email" {
  topic_arn = aws_sns_topic.cloudwatch_alarms.arn
  protocol  = "email"
  endpoint  = var.notification_email

  # After terraform apply, AWS sends a confirmation email to this address.
  # The subscription stays in PendingConfirmation until the link is clicked.
  # Alarms will not deliver notifications until confirmation is complete.
}

# ── Cluster-Level Alarms ───────────────────────────────────────────────────────

resource "aws_cloudwatch_metric_alarm" "node_cpu_high" {
  alarm_name          = "${var.cluster_name}-node-cpu-high"
  alarm_description   = "Node CPU utilization above 80% for 5 consecutive minutes. Investigate pod resource requests or scale the node group."
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 5
  period              = 60
  threshold           = 80
  statistic           = "Average"
  treat_missing_data  = "breaching"

  namespace   = "ContainerInsights"
  metric_name = "node_cpu_utilization"

  dimensions = {
    ClusterName = var.cluster_name
  }

  alarm_actions             = [aws_sns_topic.cloudwatch_alarms.arn]
  ok_actions                = [aws_sns_topic.cloudwatch_alarms.arn]
  insufficient_data_actions = [aws_sns_topic.cloudwatch_alarms.arn]
}

resource "aws_cloudwatch_metric_alarm" "node_memory_high" {
  alarm_name          = "${var.cluster_name}-node-memory-high"
  alarm_description   = "Node memory utilization above 85% for 5 consecutive minutes. t3.medium nodes running kube-prometheus-stack are memory-constrained — this fires before OOM kills begin."
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 5
  period              = 60
  threshold           = 85
  statistic           = "Average"
  treat_missing_data  = "breaching"

  namespace   = "ContainerInsights"
  metric_name = "node_memory_utilization"

  dimensions = {
    ClusterName = var.cluster_name
  }

  alarm_actions             = [aws_sns_topic.cloudwatch_alarms.arn]
  ok_actions                = [aws_sns_topic.cloudwatch_alarms.arn]
  insufficient_data_actions = [aws_sns_topic.cloudwatch_alarms.arn]
}

resource "aws_cloudwatch_metric_alarm" "node_count_low" {
  alarm_name          = "${var.cluster_name}-node-count-low"
  alarm_description   = "Cluster node count dropped below 2. A node has been terminated and not replaced. Single-node clusters have no scheduling redundancy."
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = 1
  period              = 60
  threshold           = 2
  statistic           = "Average"
  treat_missing_data  = "breaching"

  # cluster_node_count tracks EC2 nodes registered in the cluster.
  # node_number_of_running_pods counts pods — not what we want here.
  namespace   = "ContainerInsights"
  metric_name = "cluster_node_count"

  dimensions = {
    ClusterName = var.cluster_name
  }

  alarm_actions             = [aws_sns_topic.cloudwatch_alarms.arn]
  ok_actions                = [aws_sns_topic.cloudwatch_alarms.arn]
  insufficient_data_actions = [aws_sns_topic.cloudwatch_alarms.arn]
}

# ── Application-Level Alarms ───────────────────────────────────────────────────

resource "aws_cloudwatch_metric_alarm" "pod_restarts_high" {
  alarm_name          = "${var.cluster_name}-pod-restarts-high"
  alarm_description   = "Pod restart count exceeded 5 in 15 minutes in namespace ${var.namespace}. Threshold is 5 not 1 — single restarts are normal during startup. 5 in 15 minutes means a crash loop that is not self-resolving."
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  period              = 900
  threshold           = 5
  statistic           = "Sum"
  treat_missing_data  = "notBreaching"

  namespace   = "ContainerInsights"
  metric_name = "pod_number_of_container_restarts"

  dimensions = {
    ClusterName = var.cluster_name
    Namespace   = var.namespace
  }

  alarm_actions             = [aws_sns_topic.cloudwatch_alarms.arn]
  ok_actions                = [aws_sns_topic.cloudwatch_alarms.arn]
  insufficient_data_actions = [aws_sns_topic.cloudwatch_alarms.arn]
}

resource "aws_cloudwatch_metric_alarm" "hpa_at_max_replicas" {
  alarm_name          = "${var.cluster_name}-hpa-at-max-replicas"
  alarm_description   = "Pod count has been at or above HPA maximum (${var.hpa_max_replicas}) for 10 consecutive minutes in namespace ${var.namespace}. The autoscaler has no remaining headroom — act before response time degrades."
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 10
  period              = 60
  threshold           = var.hpa_max_replicas
  statistic           = "Maximum"
  treat_missing_data  = "notBreaching"

  namespace   = "ContainerInsights"
  metric_name = "service_number_of_running_pods"

  dimensions = {
    ClusterName = var.cluster_name
    Namespace   = var.namespace
  }

  alarm_actions             = [aws_sns_topic.cloudwatch_alarms.arn]
  ok_actions                = [aws_sns_topic.cloudwatch_alarms.arn]
  insufficient_data_actions = [aws_sns_topic.cloudwatch_alarms.arn]
}

# ── ALB-Level Alarms ───────────────────────────────────────────────────────────
# All three ALB alarms use data.aws_lb.proshop.arn_suffix as the LoadBalancer
# dimension value. This is resolved dynamically at apply time via the LBC tag
# lookup above — no hardcoded ARN suffix anywhere.

resource "aws_cloudwatch_metric_alarm" "alb_5xx_rate_high" {
  alarm_name          = "${var.cluster_name}-alb-5xx-rate-high"
  alarm_description   = "ALB HTTP 5xx error rate exceeded 1% of total requests for 5 minutes. Indicates backend failures — check pod logs and deployment health."
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 5
  threshold           = 1
  treat_missing_data  = "notBreaching"

  # Metric math: CloudWatch alarms cannot natively compute ratios.
  # A raw 5xx count alarm is meaningless without context — 10 errors on
  # 100 requests (10%) is critical; 10 errors on 100,000 requests is noise.
  metric_query {
    id          = "e1"
    expression  = "(m1 / m2) * 100"
    label       = "5xx Error Rate (%)"
    return_data = true
  }

  metric_query {
    id = "m1"
    metric {
      namespace   = "AWS/ApplicationELB"
      metric_name = "HTTPCode_Target_5XX_Count"
      period      = 60
      stat        = "Sum"
      dimensions = {
        LoadBalancer = data.aws_lb.proshop.arn_suffix
      }
    }
  }

  metric_query {
    id = "m2"
    metric {
      namespace   = "AWS/ApplicationELB"
      metric_name = "RequestCount"
      period      = 60
      stat        = "Sum"
      dimensions = {
        LoadBalancer = data.aws_lb.proshop.arn_suffix
      }
    }
  }

  alarm_actions             = [aws_sns_topic.cloudwatch_alarms.arn]
  ok_actions                = [aws_sns_topic.cloudwatch_alarms.arn]
  insufficient_data_actions = [aws_sns_topic.cloudwatch_alarms.arn]
}

resource "aws_cloudwatch_metric_alarm" "alb_4xx_rate_high" {
  alarm_name          = "${var.cluster_name}-alb-4xx-rate-high"
  alarm_description   = "ALB HTTP 4xx error rate exceeded 5% of total requests for 5 minutes. Indicates client-side errors — check ingress routing rules or auth failures."
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 5
  threshold           = 5
  treat_missing_data  = "notBreaching"

  metric_query {
    id          = "e1"
    expression  = "(m1 / m2) * 100"
    label       = "4xx Error Rate (%)"
    return_data = true
  }

  metric_query {
    id = "m1"
    metric {
      namespace   = "AWS/ApplicationELB"
      metric_name = "HTTPCode_Target_4XX_Count"
      period      = 60
      stat        = "Sum"
      dimensions = {
        LoadBalancer = data.aws_lb.proshop.arn_suffix
      }
    }
  }

  metric_query {
    id = "m2"
    metric {
      namespace   = "AWS/ApplicationELB"
      metric_name = "RequestCount"
      period      = 60
      stat        = "Sum"
      dimensions = {
        LoadBalancer = data.aws_lb.proshop.arn_suffix
      }
    }
  }

  alarm_actions             = [aws_sns_topic.cloudwatch_alarms.arn]
  ok_actions                = [aws_sns_topic.cloudwatch_alarms.arn]
  insufficient_data_actions = [aws_sns_topic.cloudwatch_alarms.arn]
}

resource "aws_cloudwatch_metric_alarm" "alb_response_time_high" {
  alarm_name          = "${var.cluster_name}-alb-response-time-high"
  alarm_description   = "ALB average target response time exceeded 2 seconds for 5 minutes. Check pod CPU/memory, database connection pool, or MongoDB Atlas latency."
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 5
  period              = 60
  threshold           = 2
  statistic           = "Average"
  treat_missing_data  = "notBreaching"

  namespace   = "AWS/ApplicationELB"
  metric_name = "TargetResponseTime"

  dimensions = {
    LoadBalancer = data.aws_lb.proshop.arn_suffix
  }

  alarm_actions             = [aws_sns_topic.cloudwatch_alarms.arn]
  ok_actions                = [aws_sns_topic.cloudwatch_alarms.arn]
  insufficient_data_actions = [aws_sns_topic.cloudwatch_alarms.arn]
}

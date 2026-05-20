# SNS Topic for Deployment Alerts
resource "aws_sns_topic" "deployments" {
  name              = "${var.project_name}-deployment-alerts"
  kms_master_key_id = "alias/aws/sns"

  tags = {
    Name = "${var.project_name}-deployment-alerts"
  }
}

# SNS Topic Subscription (Email)
resource "aws_sns_topic_subscription" "deployment_email" {
  topic_arn = aws_sns_topic.deployments.arn
  protocol  = "email"
  endpoint  = var.sns_email_endpoint

  # Note: Email subscriptions require confirmation via email link
}

# CloudWatch Alarm for EKS Cluster Health
resource "aws_cloudwatch_metric_alarm" "eks_node_cpu" {
  alarm_name          = "${var.project_name}-eks-node-cpu"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "300"
  statistic           = "Average"
  threshold           = "80"
  alarm_description   = "Alert when EKS node CPU exceeds 80%"
  alarm_actions       = [aws_sns_topic.deployments.arn]

  dimensions = {
    Cluster = aws_eks_cluster.main.name
  }
}

# CloudWatch Alarm for Jenkins
resource "aws_cloudwatch_metric_alarm" "jenkins_cpu" {
  count               = var.enable_jenkins ? 1 : 0
  alarm_name          = "${var.project_name}-jenkins-cpu"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "300"
  statistic           = "Average"
  threshold           = "80"
  alarm_description   = "Alert when Jenkins CPU exceeds 80%"
  alarm_actions       = [aws_sns_topic.deployments.arn]

  dimensions = {
    InstanceId = aws_instance.jenkins[0].id
  }
}

# CloudWatch Alarm for Jenkins Disk
resource "aws_cloudwatch_metric_alarm" "jenkins_disk" {
  count               = var.enable_jenkins ? 1 : 0
  alarm_name          = "${var.project_name}-jenkins-disk"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "DiskSpaceUtilization"
  namespace           = "AWS/EC2"
  period              = "300"
  statistic           = "Average"
  threshold           = "85"
  alarm_description   = "Alert when Jenkins disk exceeds 85%"
  alarm_actions       = [aws_sns_topic.deployments.arn]
}

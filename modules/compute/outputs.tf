output "autoscaling_group_id" {
  description = "ID of the Auto Scaling Group"
  value       = aws_autoscaling_group.app_asg.id
}

output "launch_template_id" {
  description = "ID of the Launch Template"
  value       = aws_launch_template.app_lt.id
}
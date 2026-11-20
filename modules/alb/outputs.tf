output "alb_dns_name" {
	description = "Public DNS name of the Application Load Balancer"
	value = aws_lb.app_alb.dns_name
}

output "target_group_arn" {
	description = "ARN of the ALB target group"
	value = aws_lb_target_group.app_tg.arn
}
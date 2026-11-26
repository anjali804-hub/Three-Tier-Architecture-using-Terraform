
output "web_alb_dns" {

  description = "Public Web Load Balancer DNS"

  value = aws_lb.web_alb.dns_name
}

output "internal_alb_dns" {

  description = "Internal Application Load Balancer DNS"

  value = aws_lb.internal_alb.dns_name
}

output "web_asg_name" {

  value = aws_autoscaling_group.web_asg.name
}

output "app_asg_name" {

  value = aws_autoscaling_group.app_asg.name
}

output "rds_endpoint" {

  description = "RDS MySQL endpoint"

  value = aws_db_instance.main.endpoint
}

output "rds_address" {

  description = "RDS database hostname"

  value = aws_db_instance.main.address
}

output "rds_port" {

  description = "RDS database port"

  value = aws_db_instance.main.port
}

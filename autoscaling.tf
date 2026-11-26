
resource "aws_autoscaling_group" "app_asg" {

  name = "application-asg"

  min_size         = 2
  desired_capacity = 2
  max_size         = 4

  vpc_zone_identifier = [
    aws_subnet.app_az1.id,
    aws_subnet.app_az2.id
  ]

  target_group_arns = [
    aws_lb_target_group.app_tg.arn
  ]

  health_check_type         = "ELB"
  health_check_grace_period = 300

  launch_template {
    id = aws_launch_template.app_lt.id

    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "Application-ASG-Instance"
    propagate_at_launch = true
  }
}

resource "aws_autoscaling_group" "web_asg" {

  name = "web-asg"

  min_size         = 2
  desired_capacity = 2
  max_size         = 4

  vpc_zone_identifier = [
    aws_subnet.public_az1.id,
    aws_subnet.public_az2.id
  ]

  target_group_arns = [
    aws_lb_target_group.web_tg.arn
  ]

  health_check_type         = "ELB"
  health_check_grace_period = 300

  launch_template {
    id = aws_launch_template.web_lt.id

    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "Web-ASG-Instance"
    propagate_at_launch = true
  }
  instance_refresh {
    strategy = "Rolling"
  
    preferences {
      min_healthy_percentage = 50
      instance_warmup        = 300
    }
  }
}



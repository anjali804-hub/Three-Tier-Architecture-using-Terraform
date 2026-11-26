
resource "aws_lb_target_group" "web_tg" {

  name     = "web-target-group"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.main.id

  health_check {
    path                = "/"
    protocol            = "HTTP"
    matcher             = "200"
    interval            = 30
    healthy_threshold   = 2
    unhealthy_threshold = 3
  }

  tags = {
    Name = "Web-Target-Group"
  }
}

resource "aws_lb" "web_alb" {

  name               = "three-tier-web-alb"
  internal           = false
  load_balancer_type = "application"

  security_groups = [
    aws_security_group.web_alb_sg.id
  ]

  subnets = [
    aws_subnet.public_az1.id,
    aws_subnet.public_az2.id
  ]

  tags = {
    Name = "Three-Tier-Web-ALB"
  }
}

resource "aws_lb_listener" "web_listener" {

  load_balancer_arn = aws_lb.web_alb.arn

  port     = 80
  protocol = "HTTP"

  default_action {
    type = "forward"

    target_group_arn = aws_lb_target_group.web_tg.arn
  }
}

resource "aws_lb_target_group" "app_tg" {

  name     = "app-target-group"
  port     = 8080
  protocol = "HTTP"
  vpc_id   = aws_vpc.main.id

  health_check {
    path                = "/health"
    protocol            = "HTTP"
    matcher             = "200"
    interval            = 30
    healthy_threshold   = 2
    unhealthy_threshold = 3
  }

  tags = {
    Name = "App-Target-Group"
  }
}

resource "aws_lb" "internal_alb" {

  name               = "three-tier-internal-alb"
  internal           = true
  load_balancer_type = "application"

  security_groups = [
    aws_security_group.internal_alb_sg.id
  ]

  subnets = [
    aws_subnet.app_az1.id,
    aws_subnet.app_az2.id
  ]

  tags = {
    Name = "Three-Tier-Internal-ALB"
  }
}

resource "aws_lb_listener" "app_listener" {

  load_balancer_arn = aws_lb.internal_alb.arn

  port     = 8080
  protocol = "HTTP"

  default_action {
    type = "forward"

    target_group_arn = aws_lb_target_group.app_tg.arn
  }
}

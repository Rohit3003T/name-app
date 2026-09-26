resource "aws_lb_target_group" "app_tg" {
  name     = "name-app-tg"
  port     = 5000
  protocol = "HTTP"

  vpc_id = aws_vpc.main.id

  health_check {
    path = "/health"
  }
  tags = {
    Name = "name-app-tg"
  }

}

resource "aws_lb" "app_alb" {
  name            = "name-app-alb"
  internal        = false
  security_groups = [aws_security_group.alb_sg.id]

  subnets = [
    aws_subnet.subnet_az1_public.id,
    aws_subnet.subnet_az2_public.id,
    aws_subnet.subnet_az3_public.id
  ]
  tags = { Name = "app-alb" }
}

resource "aws_lb_listener" "app_listener" {
  load_balancer_arn = aws_lb.app_alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app_tg.arn
  }
}




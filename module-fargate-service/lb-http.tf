# adds an http listener to the load balancer and allows ingress
# (delete this file if you only want https)

resource "aws_alb_listener" "http" {
  load_balancer_arn = aws_alb.main.id
  port              = var.lb_port
  protocol          = var.lb_protocol

  default_action {
    target_group_arn = aws_alb_target_group.main.id
    type             = "forward"
  }

  lifecycle {
    ignore_changes = [port, protocol, default_action]
  }
}

resource "aws_lb_listener" "https" {
  count = (var.lb_ssl_certificate_arn==null && var.dggr_acm_certificate_arn==null) ? 0 : 1
  load_balancer_arn = aws_alb.main.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = var.lb_ssl_certificate_arn==null ? var.dggr_acm_certificate_arn : var.lb_ssl_certificate_arn
  default_action {
    target_group_arn = aws_alb_target_group.main.id
    type             = "forward"
  }
}

resource "aws_lb_listener_certificate" "lb_listener_cert" {
   count = (var.lb_ssl_certificate_arn==null && var.dggr_acm_certificate_arn==null) ? 0 : 1
   listener_arn = aws_lb_listener.https[0].arn
   certificate_arn   = var.lb_ssl_certificate_arn==null ? var.dggr_acm_certificate_arn : var.lb_ssl_certificate_arn
}

resource "aws_security_group_rule" "ingress_lb_http" {
  type              = "ingress"
  description       = var.lb_protocol
  from_port         = var.lb_port
  to_port           = var.lb_port
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.nsg_lb.id
}

resource "aws_security_group_rule" "ingress_lb_https" {
  type              = "ingress"
  description       = var.lb_ssl_protocol
  from_port         = var.lb_ssl_port
  to_port           = var.lb_ssl_port
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.nsg_lb.id
}


module "alb" {
  source  = "terraform-aws-modules/alb/aws"
  version = "~> 10.0"

  name = var.name

  vpc_id  = var.vpc_id
  subnets = var.public_subnets

  security_groups = [var.alb_sg_id]

  load_balancer_type         = "application"
  enable_deletion_protection = false


  listeners = {
    http = {
      port     = 80
      protocol = "HTTP"

      action_type = "redirect"

      redirect = {
        port        = "443"
        protocol    = "HTTPS"
        status_code = "HTTP_301"
      }
    }

    https = {
      port            = 443
      protocol        = "HTTPS"
      certificate_arn = var.certificate_arn

      fixed_response = {
        content_type = "text/plain"
        message_body = "default"
        status_code  = "200"
      }

      rules = {
        app1 = {
          priority = 1

          actions = [{
            type = "forward"
            forward = {
              target_group_key = "app1"
            }
          }]

          conditions = [{
            host_header = {
              values = ["app1.mbodou.org"]
            }
          }]
        }

        app2 = {
          priority = 2

          actions = [{
            type = "forward"
            forward = {
              target_group_key = "app2"
            }
          }]

          conditions = [{
            host_header = {
              values = ["app2.mbodou.org"]
            }
          }]
        }
      }
    }
  }

  target_groups = {
    app1 = {
      name_prefix       = "app1-"
      protocol          = "HTTP"
      port              = 80
      target_type       = "instance"
      create_attachment = false
      health_check = {
        path = "/"
      }
    }

    app2 = {
      name_prefix       = "app2-"
      protocol          = "HTTP"
      port              = 80
      target_type       = "instance"
      create_attachment = false
      health_check = {
        path = "/"
      }
    }
  }

  tags = var.tags
}


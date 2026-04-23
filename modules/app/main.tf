resource "aws_launch_template" "this" {
  name_prefix   = "${var.name}-lt-"
  image_id      = var.ami_id
  instance_type = var.instance_type

  iam_instance_profile {
    name = var.instance_profile_name
  }

  vpc_security_group_ids = var.security_group_ids

  user_data = base64encode(templatefile("${path.module}/user_data.sh", {
    artifact_bucket = var.artifact_bucket
    artifact_key    = var.artifact_key
    app_name        = var.app_name
  }))

  tag_specifications {
    resource_type = "instance"

    tags = merge(var.tags, {
      Name = "${var.name}-instance"
      App  = var.app_name
    })
  }

  tags = merge(var.tags, {
    Name = "${var.name}-lt"
    App  = var.app_name
  })

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "this" {
  name                      = "${var.name}-asg"
  min_size                  = var.min_size
  max_size                  = var.max_size
  desired_capacity          = var.desired_capacity
  vpc_zone_identifier       = var.subnet_ids
  health_check_type         = "ELB"
  health_check_grace_period = 300
  target_group_arns         = [var.target_group_arn]

  launch_template {
    id      = aws_launch_template.this.id
    version = "$Latest"
  }

  instance_refresh {
    strategy = "Rolling"

    preferences {
      min_healthy_percentage = 50
      instance_warmup        = 300
    }


  }

  tag {
    key                 = "Name"
    value               = "${var.name}-asg-instance"
    propagate_at_launch = true
  }

  dynamic "tag" {
    for_each = merge(var.tags, {
      App = var.app_name
    })

    content {
      key                 = tag.key
      value               = tag.value
      propagate_at_launch = true
    }
  }

  lifecycle {
    create_before_destroy = true
  }
}
# resource "aws_launch_template" "app" {


#   # name = var.name

#   image_id      = "ami-0c3389a4fa5bddaad" # Replace with valid AMI
#   instance_type = "t2.micro"

#   vpc_security_group_ids = [var.app_sg_id]

#   iam_instance_profile {
#   name = var.iam_instance_profile
# }
# # user_data = base64encode(file("${path.module}/app1.sh"))
# user_data = base64encode(templatefile("${path.module}/user_data.sh", {
#   APP_NAME    = var.app_name,
#   APP_PORT    = var.app_port
#   APP_MESSAGE = var.app_message
#   APP_VERSION = var.app_version
# }))

#   tag_specifications {
#   resource_type = "instance"

#   tags = {
#     Name = var.app_name
#   }
# }
# }

# resource "aws_autoscaling_group" "app" {
#   desired_capacity = 2
#   max_size         = 3
#   min_size         = 1

#   vpc_zone_identifier = var.private_subnets

#   launch_template {
#     id      = aws_launch_template.app.id
#     version = "$Latest"
#   }

#  target_group_arns = [var.target_group_arn]

#   tag {
#     key                 = "Name"
#     value               = var.app_name
#     propagate_at_launch = true
#   }

# }
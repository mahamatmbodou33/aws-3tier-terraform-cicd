resource "aws_security_group" "observability_sg" {
  name        = "${var.project_name}-${var.environment}-observability-sg"
  description = "Prometheus and Grafana"
  vpc_id      = var.vpc_id

  ingress {
    description = "Grafana"
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Prometheus"
    from_port   = 9090
    to_port     = 9090
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Node Exporter Metrics"
    from_port   = 9100
    to_port     = 9100
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]
  }
  ingress {
    from_port   = 9093
    to_port     = 9093
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, {
    Name = "${var.project_name}-${var.environment}-observability-sg"
  })
}

resource "aws_instance" "observability" {
  ami                    = var.ami_id
  instance_type          = "t3.micro"
  subnet_id              = var.public_subnet_id
  iam_instance_profile   = var.instance_profile_name
  vpc_security_group_ids = [aws_security_group.observability_sg.id]

  associate_public_ip_address = true

  user_data = templatefile("${path.module}/monitoring-user-data.sh", {
    aws_region         = var.aws_region
    environment        = var.environment
    gmail_app_password = var.gmail_app_password
  })

  tags = merge(var.tags, {
    Name = "${var.project_name}-${var.environment}-observability"
  })
}
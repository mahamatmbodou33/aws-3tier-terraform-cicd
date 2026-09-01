resource "aws_db_subnet_group" "db" {
  name       = "${var.project_name}-${var.environment}-db-subnet-group"
  subnet_ids = var.db_subnets
}

resource "aws_db_instance" "db" {
  identifier = var.name
  engine         = "mysql"
  instance_class = "db.t3.micro"
  allocated_storage = 20
storage_encrypted = true
  username = "admin"
  password = var.db_password # Use secrets manager in real prod

  db_subnet_group_name   = aws_db_subnet_group.db.name
  vpc_security_group_ids = [var.db_sg_id]
multi_az = var.multi_az
  skip_final_snapshot = true
  tags                = var.tags
}
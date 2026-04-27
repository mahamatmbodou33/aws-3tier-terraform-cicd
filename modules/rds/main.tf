resource "aws_db_subnet_group" "db" {
  name       = "${var.project_name}-${var.environment}-db-subnet-group"
  subnet_ids = var.db_subnets
}

resource "aws_db_instance" "db" {
  identifier = var.name

  engine         = "mysql"
  instance_class = "db.t3.micro"

  allocated_storage = 20

  username = "admin"
  password = "Password123!" # Use secrets manager in real prod

  db_subnet_group_name   = aws_db_subnet_group.db.name
  vpc_security_group_ids = [var.db_sg_id]

  skip_final_snapshot = true
  tags                = var.tags
}
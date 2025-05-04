resource "aws_security_group" "rds_sg_postgres" {
  name   = "${terraform.workspace}-rds-sg-postgres"
  vpc_id = module.vpc.vpc_id

  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]

  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = local.common_tags
}

resource "aws_db_subnet_group" "rds_postgres_subnet_group" {
  name       = "${terraform.workspace}-rds-postgres-subnet-group-public"
  subnet_ids = module.vpc.public_subnets

  tags = local.common_tags
}

resource "aws_db_instance" "rds_postgres" {
  identifier                = "${terraform.workspace}-db-dados"
  instance_class            = "db.t3.micro"
  allocated_storage         = 8
  engine                    = "postgres"
  engine_version            = "14.12"
  db_name                   = "postgres"
  username                  = "postgres"
  password                  = "senhasegura"
  port                      = 5432
  db_subnet_group_name      = aws_db_subnet_group.rds_postgres_subnet_group.name
  vpc_security_group_ids    = [aws_security_group.rds_sg_postgres.id]
  parameter_group_name      = "default.postgres14"
  publicly_accessible       = true
  skip_final_snapshot       = true
  delete_automated_backups  = true
  copy_tags_to_snapshot     = true
  multi_az = false
  tags     = local.common_tags
}

output "rds_postgres_endpoint" {
  value = aws_db_instance.rds_postgres.endpoint
}

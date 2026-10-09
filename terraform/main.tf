resource "aws_db_instance" "production" {
  identifier          = "production-db"
  engine              = "postgres"
  instance_class      = "db.t3.medium"
  allocated_storage   = 20
  storage_encrypted   = true
  publicly_accessible = false
}

resource "aws_s3_bucket" "citizen_data" {
  bucket = "citizen-data-bucket"
}

resource "aws_s3_bucket_server_side_encryption_configuration" "citizen_data" {
  bucket = aws_s3_bucket.citizen_data.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "aws:kms"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "citizen_data" {
  bucket                  = aws_s3_bucket.citizen_data.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_versioning" "citizen_data" {
  bucket = aws_s3_bucket.citizen_data.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_ebs_volume" "data" {
  availability_zone = "us-east-1a"
  size              = 40
  encrypted         = true
}

resource "aws_cloudwatch_log_group" "app" {
  name              = "/aws/app"
  retention_in_days = 365
}

resource "aws_lb_listener" "https" {
  load_balancer_arn = "arn:aws:elasticloadbalancing:us-east-1:123:loadbalancer/app/demo"
  port              = 443
  protocol          = "HTTPS"
}

resource "aws_kms_key" "main" {
  description         = "app key"
  enable_key_rotation = true
}

locals {
  metrics_endpoint = "https://api.datadoghq.com/api/v1/series"
}

resource "aws_security_group" "app" {
  name        = "app-sg"
  description = "Application access"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["10.0.1.0/24"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

locals {
  s3_origin_id = "hosting-access"
}


##### SSL CERTIFICATE #####

locals {
  domain = "${var.subdomain}.${var.name}"
}

// Create SSL certificate
resource "aws_acm_certificate" "ssl_cert" {
  domain_name       = local.domain
  validation_method = "DNS"

  tags = {
    Name        = "hosting"
  }

  lifecycle {
    create_before_destroy = true
  }
}
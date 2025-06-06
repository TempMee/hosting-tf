locals {
  s3_origin_id = "hosting-access"
}


##### SSL CERTIFICATE #####

locals {
  fqdn = var.subdomain != "" ? "${var.subdomain}.${var.domain}" : var.domain
}

// Create SSL certificate
resource "aws_acm_certificate" "ssl_cert" {
  domain_name       = local.fqdn
  validation_method = "DNS"

  tags = {
    Name        = var.bucket_prefix
    Environment = var.environment
    Terraform   = "true"
  }

  lifecycle {
    create_before_destroy = true
  }
}

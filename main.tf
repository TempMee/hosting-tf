// Create static-site hosting bucket
resource "aws_s3_bucket" "bucket" {
  bucket_prefix = "${var.bucket_prefix}-"
  tags = {
    Name        = "hosting"
  }
#checkov:skip=CKV_AWS_144: "No need to enable cross-region replication for now"
#checkov:skip=CKV_AWS_18: "No need to enable access logging for now"
#checkov:skip=CKV_AWS_145: "No need right now"
#checkov:skip=CKV_AWS_21: "No need right now"
#checkov:skip=CKV_AWS_19: "No need right now"
#checkov:skip=CKV2_AWS_6: "No need right now"
}


// allow public access
resource "aws_s3_bucket_public_access_block" "bucket_public_access" {
#checkov:skip=CKV_AWS_53: "No need right now"
#checkov:skip=CKV_AWS_54: "No need right now"
#checkov:skip=CKV_AWS_55: "No need right now"
#checkov:skip=CKV_AWS_56: "No need right now"
  bucket = aws_s3_bucket.bucket.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

//enable static-site hosting
resource "aws_s3_bucket_website_configuration" "static_site" {
  bucket = aws_s3_bucket.bucket.id

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "error.html"
  }
}

//add bucket policy
resource "aws_s3_bucket_policy" "bucket_policy" {
  bucket = aws_s3_bucket.bucket.id

  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "AllowGetObj",
      "Effect": "Allow",
      "Principal": "*",
      "Action": "s3:GetObject",
      "Resource": "arn:aws:s3:::${aws_s3_bucket.bucket.id}/*"
    }
  ]
}
POLICY
}

resource "aws_s3_object" "upload_object" {
  for_each      = fileset("html/", "*")
  bucket        = aws_s3_bucket.bucket.id
  key           = each.value
  source        = "html/${each.value}"
  etag          = filemd5("html/${each.value}")
  content_type  = "text/html"
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

### Create DNS validation records for the SSL certificate

resource "aws_route53_record" "ssl_cert_validation_records" {
  for_each = {
    for dvo in aws_acm_certificate.ssl_cert.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = var.route53_zone_id
}

locals {
  s3_origin_id = "hosting-access"
}


##### CLOUD FRONT DISTRIBUTION #####
resource "aws_cloudfront_distribution" "static_site_distribution" {
#checkov:skip=CKV_AWS_68: "No need right now"
#checkov:skip=CKV_AWS_32: "No need right now"
#checkov:skip=CKV_AWS_86: "No need right now"
  origin {
    domain_name = "${aws_s3_bucket.bucket.bucket}.s3-website-${var.aws_region}.amazonaws.com" // static site domain name
    origin_id   = local.s3_origin_id

    // The custom_origin_config is for the website endpoint settings configured via the AWS Console.
    // https://docs.aws.amazon.com/cloudfront/latest/APIReference/API_CustomOriginConfig.html
    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "http-only"
      origin_ssl_protocols   = ["SSLv3", "TLSv1", "TLSv1.1", "TLSv1.2"]
      origin_read_timeout = 30
      origin_keepalive_timeout = 5
    }
    connection_attempts = 3
    connection_timeout = 10
  }

  enabled             = true
  comment             = local.domain
  default_root_object = "index.html"

  aliases = [local.domain]

  default_cache_behavior {
    allowed_methods  = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = local.s3_origin_id

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
    compress = true
  }

  price_class = "PriceClass_All"

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  tags = {
    Name        = "hosting"
  }

  // The viewer_certificate is for ssl certificate settings configured via the AWS Console.
  viewer_certificate {
    cloudfront_default_certificate = false
    ssl_support_method  = "sni-only"
    acm_certificate_arn = aws_acm_certificate.ssl_cert.arn
    minimum_protocol_version = "TLSv1.2_2021"
  }
}

######## ROUTE 53 RECORD #######
resource "aws_route53_record" "hosting_page_A_record" {
  zone_id = var.route53_zone_id
  name    = local.domain
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.static_site_distribution.domain_name
    zone_id                = aws_cloudfront_distribution.static_site_distribution.hosted_zone_id
    evaluate_target_health = false
  }
}
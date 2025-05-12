##### CLOUD FRONT DISTRIBUTION #####
resource "aws_cloudfront_distribution" "static_site_distribution" {
  #checkov:skip=CKV_AWS_68: "No need right now"
  #checkov:skip=CKV2_AWS_32: "No need right now"
  #checkov:skip=CKV_AWS_86: "No need right now"

  #checkov:skip=CKV_AWS_310: "No need right now"
  #checkov:skip=CKV_AWS_374: "No need right now"
  #checkov:skip=CKV2_AWS_47: "No need right now"
  #checkov:skip=CKV2_AWS_46: "No need right now"
  #checkov:skip=CKV2_AWS_54: "No need right now"

  origin {
    domain_name = "${aws_s3_bucket.bucket.bucket}.s3-website-${var.aws_region}.amazonaws.com" // static site domain name
    origin_id   = local.s3_origin_id

    // The custom_origin_config is for the website endpoint settings configured via the AWS Console.
    // https://docs.aws.amazon.com/cloudfront/latest/APIReference/API_CustomOriginConfig.html
    custom_origin_config {
      http_port                = 80
      https_port               = 443
      origin_protocol_policy   = "http-only"
      origin_ssl_protocols     = ["SSLv3", "TLSv1", "TLSv1.1", "TLSv1.2"]
      origin_read_timeout      = 30
      origin_keepalive_timeout = 5
    }
    connection_attempts = 3
    connection_timeout  = 10
  }

  enabled             = true
  comment             = local.fqdn
  default_root_object = "index.html"

  aliases = [local.fqdn]

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
    compress               = true
  }

  price_class = "PriceClass_All"

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  tags = {
    Name = "hosting"
  }

  // The viewer_certificate is for ssl certificate settings configured via the AWS Console.
  viewer_certificate {
    cloudfront_default_certificate = false
    ssl_support_method             = "sni-only"
    acm_certificate_arn            = aws_acm_certificate.ssl_cert.arn
    minimum_protocol_version       = "TLSv1.2_2021"
  }
}

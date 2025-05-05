output "s3_bucket_id" {
  value = aws_s3_bucket_website_configuration.static_site.bucket
}

output "domain_name" {
  value = aws_route53_record.hosting_page_A_record.fqdn
}

output "acm_certificate_arn" {
  value = aws_acm_certificate.ssl_cert.arn
}

output "cloudfront_domain_name" {
  value = aws_cloudfront_distribution.static_site_distribution.domain_name
}

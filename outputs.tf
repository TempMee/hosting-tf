output "s3_bucket_id" {
  value = aws_s3_bucket_website_configuration.static_site.website_endpoint
}

output "domain_name" {
  value = aws_route53_record.hosting_page_A_record.fqdn
}


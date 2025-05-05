variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "name" {
  description = "domain"
  type        = string
}
variable "subdomain" {
  description = "subdomain"
  type        = string
}

variable "route53_zone_id" {
  description = " Hosted Zone ID for the domain"
  type        = string
}

variable "bucket_prefix" {
  description = "Prefix for the S3 bucket name"
  type        = string
  default     = "static-site"
}

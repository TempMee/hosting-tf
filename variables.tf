variable "aws_access_key" {
  description = "AWS access key"
  type        = string
}

variable "aws_secret_key" {
  description = "AWS secret key"
  type        = string
}

variable "aws_token" {
  description = "AWS token"
  type        = string
  default     = ""
}

variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "name" {
  description = "domain"
  type = string  
}
variable "subdomain" {
  description = "subdomain"
  type        = string
}

variable "route53_zone_id" {
  description = " Hosted Zone ID for the domain"
  type = string
}

variable "bucket_prefix" {
  description = "Prefix for the S3 bucket name"
  type        = string
  default     = "static-site"
}
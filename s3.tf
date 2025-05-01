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

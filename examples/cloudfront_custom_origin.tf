
terraform {
  required_version = ">= 0.12"
}

provider "aws" {
  version = "~> 2.7"
  region  = "us-west-2"
}

resource "random_string" "cloudfront_rstring" {
  length  = 18
  special = false
  upper   = false
}

module "cloudfront_custom_origin" {
  source = "git@github.com:rackspace-infrastructure-automation/aws-terraform-cloudfront_custom_origin//?ref=v0.12.0"

  aliases                        = ["testdomain.testing.example.com"]
  allowed_methods                = ["GET", "HEAD"]
  bucket                         = "mybucket.s3.amazonaws.com"
  bucket_logging                 = true
  cached_methods                 = ["GET", "HEAD"]
  cloudfront_default_certificate = true
  comment                        = "This is a test comment"
  default_root_object            = "index.html"
  default_ttl                    = "3600"
  domain_name                    = "customdomain.testing.example.com"
  enabled                        = true
  forward                        = "none"
  https_port                     = "443"
  locations                      = ["US", "CA", "GB", "DE"]
  origin_id                      = random_string.cloudfront_rstring.result
  origin_protocol_policy         = "https-only"
  path_pattern                   = "*"
  prefix                         = "myprefix"
  price_class                    = "PriceClass_200"
  query_string                   = false
  restriction_type               = "whitelist"
  target_origin_id               = random_string.cloudfront_rstring.result
  viewer_protocol_policy         = "redirect-to-https"
}


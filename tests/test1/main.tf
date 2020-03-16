
terraform {
  required_version = ">= 0.12"
}

provider "aws" {
  region  = "us-west-2"
  version = "~> 2.7"
}

resource "random_string" "cloudfront_rstring" {
  length  = 18
  special = false
  upper   = false
}

module "cloudfront_custom_origin" {
  source = "../../module"

  allowed_methods                = ["GET", "HEAD"]
  custom_header                  = [{ name = "header1", value = "value1" }, { name = "header2", value = "value2" }]
  bucket_logging                 = false
  cached_methods                 = ["GET", "HEAD"]
  cloudfront_default_certificate = true
  comment                        = "This is a test comment"
  default_root_object            = "index.html"
  default_ttl                    = "3600"
  domain_name                    = "customdomain.testing.example.com"
  enabled                        = true
  forward                        = "none"
  https_port                     = 443
  locations                      = ["US", "CA", "GB", "DE"]
  origin_id                      = random_string.cloudfront_rstring.result
  origin_protocol_policy         = "https-only"
  path_pattern                   = "*"
  price_class                    = "PriceClass_200"
  query_string                   = false
  restriction_type               = "whitelist"
  target_origin_id               = random_string.cloudfront_rstring.result
  viewer_protocol_policy         = "redirect-to-https"
}


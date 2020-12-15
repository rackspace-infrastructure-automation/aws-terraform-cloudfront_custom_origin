/*
 * # aws-terraform-cloudfront_custom_origin
 *
 * This modules creates an AWS CloudFront distribution with a custom origin
 *
 * ## Basic Usage
 *
 * ```
 * module "cloudfront_custom_origin" {
 *   source = "git@github.com:rackspace-infrastructure-automation/aws-terraform-cloudfront_custom_origin//?ref=v0.12.0"
 *
 *   aliases                        = ["testdomain.testing.example.com"]
 *   allowed_methods                = ["GET", "HEAD"]
 *   bucket                         = "mybucket.s3.amazonaws.com"
 *   bucket_logging                 = true
 *   cached_methods                 = ["GET", "HEAD"]
 *   cloudfront_default_certificate = true
 *   comment                        = "This is a test comment"
 *   default_root_object            = "index.html"
 *   default_ttl                    = "3600"
 *   domain_name                    = "customdomain.testing.example.com"
 *   enabled                        = true
 *   forward                        = "none"
 *   https_port                     = 443
 *   locations                      = ["US", "CA", "GB", "DE"]
 *   origin_id                      = "${random_string.cloudfront_rstring.result}"
 *   origin_protocol_policy         = "https-only"
 *   path_pattern                   = "*"
 *   prefix                         = "myprefix"
 *   price_class                    = "PriceClass_200"
 *   query_string                   = false
 *   restriction_type               = "whitelist"
 *   target_origin_id               = "${random_string.cloudfront_rstring.result}"
 *   viewer_protocol_policy         = "redirect-to-https"
 * }
 * ```
 *
 * Full working references are available at [examples](examples)
 *
 * ## Terraform 0.12 upgrade
 *
 * Several changes were made while adding terraform 0.12 compatibility.
 * The main change to be aware of is the `customer_header` variable
 * changed types from `list(string)` to `list(map(string))` to properly function with dynamic
 * configuration blocks.
 */

terraform {
  required_version = ">= 0.12"

  required_providers {
    aws = ">= 3.0.0"
  }
}


locals {

  tags = {
    Name            = var.origin_id
    ServiceProvider = "Rackspace"
    Environment     = var.environment
  }

  bucket_logging = {
    bucket          = var.bucket
    include_cookies = var.include_cookies
    prefix          = var.prefix

  }
}

resource "aws_cloudfront_distribution" "cf_distribution" {
  aliases             = var.aliases
  comment             = var.comment
  default_root_object = var.default_root_object
  enabled             = var.enabled
  http_version        = var.http_version
  is_ipv6_enabled     = var.is_ipv6_enabled
  price_class         = var.price_class
  tags                = merge(var.tags, local.tags)
  web_acl_id          = var.web_acl_id

  dynamic "logging_config" {
    for_each = var.bucket_logging ? [local.bucket_logging] : []
    content {
      bucket          = logging_config.value.bucket
      include_cookies = lookup(logging_config.value, "include_cookies", null)
      prefix          = lookup(logging_config.value, "prefix", null)
    }
  }

  default_cache_behavior {
    allowed_methods        = var.allowed_methods
    cached_methods         = var.cached_methods
    compress               = var.compress
    default_ttl            = var.default_ttl
    max_ttl                = var.max_ttl
    min_ttl                = var.min_ttl
    smooth_streaming       = var.smooth_streaming
    target_origin_id       = var.target_origin_id
    trusted_signers        = var.trusted_signers
    viewer_protocol_policy = var.viewer_protocol_policy

    # Removing this property due to issues dynamically providing these values.  Will be reenabled
    # after release of terraform v0.12 and support for dynamic config blocks.
    #
    # lambda_function_association = "${var.lambdas}"

    forwarded_values {
      headers                 = var.headers
      query_string            = var.query_string
      query_string_cache_keys = var.query_string_cache_keys

      cookies {
        forward           = var.forward
        whitelisted_names = var.whitelisted_names
      }
    }
  }

  origin {
    domain_name = var.domain_name
    origin_id   = var.origin_id
    origin_path = var.origin_path

    dynamic "custom_header" {
      for_each = var.custom_header
      content {
        name  = custom_header.value.name
        value = custom_header.value.value
      }
    }

    custom_origin_config {
      http_port                = var.http_port
      https_port               = var.https_port
      origin_keepalive_timeout = var.origin_keepalive_timeout
      origin_protocol_policy   = var.origin_protocol_policy
      origin_read_timeout      = var.origin_read_timeout
      origin_ssl_protocols     = var.origin_ssl_protocols
    }
  }

  restrictions {
    geo_restriction {
      locations        = var.locations
      restriction_type = var.restriction_type
    }
  }

  viewer_certificate {
    acm_certificate_arn            = var.acm_certificate_arn
    cloudfront_default_certificate = var.cloudfront_default_certificate
    iam_certificate_id             = var.iam_certificate_id
    minimum_protocol_version       = var.minimum_protocol_version
    ssl_support_method             = var.ssl_support_method
  }
}


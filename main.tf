/**
 *# aws-terraform-cloudfront_custom_origin
 *
 *This modules creates an AWS CloudFront distribution with a custom origin
 *
 *## Basic Usage
 *
 *```
 *module "cloudfront_custom_origin" {
 *  source              = "git@github.com:rackspace-infrastructure-automation/aws-terraform-cloudfront_custom_origin//?ref=v0.0.3"
 *  domain_name         = "customdomain.testing.example.com"
 *  origin_id           = "${random_string.cloudfront_rstring.result}"
 *  enabled             = true
 *  comment             = "This is a test comment"
 *  default_root_object = "index.html"
 *
 *  # logging config
 *  # Bucket must already exist, can't be generated as a resource along with example.
 *  # This is a TF bug.
 *  # The bucket name must be the full bucket ie bucket.s3.amazonaws.com
 *  bucket = "mybucket.s3.amazonaws.com"
 *
 *  prefix         = "myprefix"
 *  bucket_logging = true
 *
 *  # Custom Origin
 *  https_port             = 443
 *  origin_protocol_policy = "https-only"
 *
 *  aliases = ["testdomain.testing.example.com"]
 *
 *  # default cache behavior
 *  allowed_methods  = ["GET", "HEAD"]
 *  cached_methods   = ["GET", "HEAD"]
 *  path_pattern     = "*"
 *  target_origin_id = "${random_string.cloudfront_rstring.result}"
 *
 *  # Forwarded Values
 *  query_string = false
 *
 *  #Cookies
 *  forward = "none"
 *
 *  viewer_protocol_policy = "redirect-to-https"
 *  default_ttl            = "3600"
 *
 *  price_class = "PriceClass_200"
 *
 *  # restrictions
 *  restriction_type = "whitelist"
 *  locations        = ["US", "CA", "GB", "DE"]
 *
 *  # Certificate
 *  cloudfront_default_certificate = true
 *}
 *```
 *
 * Full working references are available at [examples](examples)
 */

locals {
  tags = {
    Name            = "${var.origin_id}"
    ServiceProvider = "Rackspace"
    Environment     = "${var.environment}"
  }

  bucket_logging = {
    enabled = [{
      bucket          = "${var.bucket}"
      include_cookies = "${var.include_cookies}"
      prefix          = "${var.prefix}"
    }]

    disabled = "${list()}"
  }

  bucket_logging_config = "${var.bucket_logging ? "enabled" : "disabled"}"
}

resource "aws_cloudfront_distribution" "cf_distribution" {
  aliases = ["${var.aliases}"]

  default_cache_behavior {
    allowed_methods = "${var.allowed_methods}"
    cached_methods  = "${var.cached_methods}"
    compress        = "${var.compress}"
    default_ttl     = "${var.default_ttl}"

    forwarded_values {
      cookies {
        forward           = "${var.forward}"
        whitelisted_names = "${var.whitelisted_names}"
      }

      headers                 = "${var.headers}"
      query_string            = "${var.query_string}"
      query_string_cache_keys = "${var.query_string_cache_keys}"
    }

    # Removing this property due to issues dynamically providing these values.  Will be reenabled
    # after release of terraform v0.12 and support for dynamic config blocks.
    #
    # lambda_function_association = "${var.lambdas}"

    max_ttl                = "${var.max_ttl}"
    min_ttl                = "${var.min_ttl}"
    smooth_streaming       = "${var.smooth_streaming}"
    target_origin_id       = "${var.target_origin_id}"
    trusted_signers        = "${var.trusted_signers}"
    viewer_protocol_policy = "${var.viewer_protocol_policy}"
  }

  comment             = "${var.comment}"
  default_root_object = "${var.default_root_object}"
  enabled             = "${var.enabled}"
  http_version        = "${var.http_version}"
  is_ipv6_enabled     = "${var.is_ipv6_enabled}"

  logging_config = ["${local.bucket_logging[local.bucket_logging_config]}"]

  origin {
    domain_name   = "${var.domain_name}"
    custom_header = "${var.custom_header}"
    origin_id     = "${var.origin_id}"
    origin_path   = "${var.origin_path}"

    custom_origin_config = {
      http_port                = "${var.http_port}"
      https_port               = "${var.https_port}"
      origin_protocol_policy   = "${var.origin_protocol_policy}"
      origin_ssl_protocols     = "${var.origin_ssl_protocols}"
      origin_keepalive_timeout = "${var.origin_keepalive_timeout}"
      origin_read_timeout      = "${var.origin_read_timeout}"
    }
  }

  price_class = "${var.price_class}"

  restrictions {
    geo_restriction {
      locations        = "${var.locations}"
      restriction_type = "${var.restriction_type}"
    }
  }

  tags = "${merge(var.tags, local.tags)}"

  viewer_certificate {
    acm_certificate_arn            = "${var.acm_certificate_arn}"
    cloudfront_default_certificate = "${var.cloudfront_default_certificate}"
    iam_certificate_id             = "${var.iam_certificate_id}"
    minimum_protocol_version       = "${var.minimum_protocol_version}"
    ssl_support_method             = "${var.ssl_support_method}"
  }

  web_acl_id = "${var.web_acl_id}"
}

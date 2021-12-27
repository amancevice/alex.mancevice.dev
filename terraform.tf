terraform {
  backend "s3" {
    bucket = "mancevice-dev-us-west-2-terraform"
    key    = "alexander.tfstate"
    region = "us-west-2"
  }

  required_version = "~> 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}

locals {
  tags = {
    App  = "alexander.mancevice.dev"
    Name = "mancevice.dev"
    Repo = "https://github.com/amancevice/alex.mancevice.dev"
  }
}

provider "aws" {
  region = "us-west-2"

  default_tags { tags = local.tags }
}

provider "aws" {
  alias  = "us_east_1"
  region = "us-east-1"

  default_tags { tags = local.tags }
}

data "aws_region" "current" {
}

# CLOUDFRONT

data "aws_acm_certificate" "cert" {
  provider = aws.us_east_1
  domain   = "mancevice.dev"
  statuses = ["ISSUED"]
}

resource "aws_cloudfront_distribution" "website" {
  default_root_object = "index.html"
  enabled             = true
  is_ipv6_enabled     = true
  price_class         = "PriceClass_100"

  aliases = [
    "alex.mancevice.dev",
    "alexander.mancevice.dev",
    "mancevice.dev",
    "www.mancevice.dev"
  ]

  custom_error_response {
    error_caching_min_ttl = 300
    error_code            = 403
    response_code         = 404
    response_page_path    = "/error.html"
  }

  default_cache_behavior {
    allowed_methods        = ["GET", "HEAD"]
    cached_methods         = ["GET", "HEAD"]
    default_ttl            = 86400
    max_ttl                = 31536000
    min_ttl                = 0
    target_origin_id       = aws_s3_bucket.alexander.bucket
    viewer_protocol_policy = "redirect-to-https"

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }
  }

  origin {
    domain_name = aws_s3_bucket.alexander.bucket_regional_domain_name
    origin_id   = aws_s3_bucket.alexander.bucket

    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.website.cloudfront_access_identity_path
    }
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    acm_certificate_arn      = data.aws_acm_certificate.cert.arn
    minimum_protocol_version = "TLSv1.1_2016"
    ssl_support_method       = "sni-only"
  }
}

resource "aws_cloudfront_origin_access_identity" "website" {
  comment = "access-identity-alexander.mancevice.dev.s3.amazonaws.com"
}

# ROUTE53

data "aws_route53_zone" "mancevice_dev" {
  name = "mancevice.dev"
}

# ROUTE53 :: RECORDS

resource "aws_route53_record" "a" {
  name    = "mancevice.dev"
  type    = "A"
  zone_id = data.aws_route53_zone.mancevice_dev.id

  alias {
    evaluate_target_health = true
    name                   = aws_cloudfront_distribution.website.domain_name
    zone_id                = aws_cloudfront_distribution.website.hosted_zone_id
  }
}

resource "aws_route53_record" "aaaa" {
  name    = "mancevice.dev"
  type    = "AAAA"
  zone_id = data.aws_route53_zone.mancevice_dev.id

  alias {
    evaluate_target_health = true
    name                   = aws_cloudfront_distribution.website.domain_name
    zone_id                = aws_cloudfront_distribution.website.hosted_zone_id
  }
}

resource "aws_route53_record" "alex_a" {
  name    = "alex.mancevice.dev"
  type    = "A"
  zone_id = data.aws_route53_zone.mancevice_dev.id

  alias {
    evaluate_target_health = true
    name                   = aws_cloudfront_distribution.website.domain_name
    zone_id                = aws_cloudfront_distribution.website.hosted_zone_id
  }
}

resource "aws_route53_record" "alex_aaaa" {
  name    = "alex.mancevice.dev"
  type    = "AAAA"
  zone_id = data.aws_route53_zone.mancevice_dev.id

  alias {
    evaluate_target_health = true
    name                   = aws_cloudfront_distribution.website.domain_name
    zone_id                = aws_cloudfront_distribution.website.hosted_zone_id
  }
}

resource "aws_route53_record" "alexander_a" {
  name    = "alexander.mancevice.dev"
  type    = "A"
  zone_id = data.aws_route53_zone.mancevice_dev.id

  alias {
    evaluate_target_health = true
    name                   = aws_cloudfront_distribution.website.domain_name
    zone_id                = aws_cloudfront_distribution.website.hosted_zone_id
  }
}

resource "aws_route53_record" "alexander_aaaa" {
  name    = "alexander.mancevice.dev"
  type    = "AAAA"
  zone_id = data.aws_route53_zone.mancevice_dev.id

  alias {
    evaluate_target_health = true
    name                   = aws_cloudfront_distribution.website.domain_name
    zone_id                = aws_cloudfront_distribution.website.hosted_zone_id
  }
}

# ROUTE53 :: HEALTH CHECKS

/*
resource aws_route53_health_check alex_mancevice_dev {
  failure_threshold = "3"
  fqdn              = "alex.mancevice.dev"
  measure_latency   = true
  port              = 443
  request_interval  = "30"
  tags              = { Name = "alex.mancevice.dev" }
  type              = "HTTPS"
}

resource aws_route53_health_check alexander_mancevice_dev {
  failure_threshold = "3"
  fqdn              = "alexander.mancevice.dev"
  measure_latency   = true
  port              = 443
  request_interval  = "30"
  tags              = { Name = "alexander.mancevice.dev" }
  type              = "HTTPS"
}

resource aws_route53_health_check mancevice_dev {
  failure_threshold = "3"
  fqdn              = "mancevice.dev"
  measure_latency   = true
  port              = 443
  request_interval  = "30"
  tags              = { Name = "mancevice.dev" }
  type              = "HTTPS"
}
*/

# S3 BUCKET

data "aws_iam_policy_document" "alexander" {
  statement {
    sid       = "AllowCloudFront"
    actions   = ["s3:GetObject"]
    resources = ["arn:aws:s3:::mancevice-dev-${data.aws_region.current.name}-alexander/*"]

    principals {
      type        = "AWS"
      identifiers = [aws_cloudfront_origin_access_identity.website.iam_arn]
    }
  }
}

resource "aws_s3_bucket" "alexander" {
  bucket = "mancevice-dev-${data.aws_region.current.name}-alexander"
  policy = data.aws_iam_policy_document.alexander.json

  website {
    error_document = "error.html"
    index_document = "index.html"
  }
}

resource "aws_s3_bucket_public_access_block" "alexander" {
  block_public_acls       = true
  block_public_policy     = true
  bucket                  = aws_s3_bucket.alexander.id
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# OUTPUTS

output "bucket_name" {
  description = "S3 website bucket name."
  value       = aws_s3_bucket.alexander.bucket
}

output "cloudfront_distribution_id" {
  description = "CloudFront distribution ID."
  value       = aws_cloudfront_distribution.website.id
}

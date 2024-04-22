provider "aws" {
  region = "us-east-1"
  alias  = "us-east-1"
}


resource "aws_cloudfront_origin_access_identity" "oai" {
}

resource "aws_s3_bucket" "vacgom-images" {
  bucket = "vacgom-images"

  tags = {
    Name = "vacgom-images"
  }
}

data "aws_iam_policy_document" "vacgom-policy" {
  statement {
    actions   = ["s3:GetObject"]
    effect    = "Allow"
    resources = ["${aws_s3_bucket.vacgom-images.arn}/*"]
    principals {
      type        = "Service"
      identifiers = ["cloudfront.amazonaws.com"]
    }
    condition {
      test     = "StringEquals"
      variable = "AWS:SourceArn"
      values   = [aws_cloudfront_origin_access_identity.oai.iam_arn]
    }
  }
}

resource "aws_s3_bucket_policy" "vacgom-policy" {
  bucket = aws_s3_bucket.vacgom-images.id
  policy = data.aws_iam_policy_document.vacgom-policy.json
}


data "aws_acm_certificate" "vacgom-cert" {
  domain = var.vacgom-domain

  provider = aws.us-east-1
}

resource "aws_cloudfront_distribution" "vacgom-distribution" {
  depends_on = [data.aws_acm_certificate.vacgom-cert]

  enabled = true
  aliases = ["images.vacgom.co.kr"]

  origin {
    domain_name = aws_s3_bucket.vacgom-images.bucket_domain_name
    origin_id   = aws_s3_bucket.vacgom-images.id

    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.oai.cloudfront_access_identity_path
    }
  }

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = aws_s3_bucket.vacgom-images.id

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "allow-all"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
    acm_certificate_arn            = data.aws_acm_certificate.vacgom-cert.id
    ssl_support_method             = "sni-only"
  }
}

resource "aws_route53_record" "s3-record" {
  zone_id = var.vacgom-zone
  name    = "images.vacgom.co.kr"
  type    = "CNAME"

  alias {
    name                   = aws_cloudfront_distribution.vacgom-distribution.domain_name
    zone_id                = aws_cloudfront_distribution.vacgom-distribution.hosted_zone_id
    evaluate_target_health = false
  }
}


resource "aws_route53_record" "s3-route" {
  zone_id = var.vacgom-zone
  name    = "images.${var.vacgom-zone}"
  type    = "CNAME"
  ttl     = 300
  records = [aws_cloudfront_distribution.vacgom-distribution.domain_name]
}

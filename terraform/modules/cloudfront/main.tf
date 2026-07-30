# ==============================================================================
# Reusable CloudFront Module with Origin Access Control (OAC)
# ==============================================================================
# Provisions an Amazon CloudFront distribution configured with:
# - Origin Access Control (OAC) with SigV4 signing for S3 origins
# - Automatic HTTP to HTTPS redirection
# - Default root object (index.html)
# - Least-privilege S3 bucket policy granting access strictly to CloudFront
# ==============================================================================

# ------------------------------------------------------------------------------
# Origin Access Control (OAC)
# ------------------------------------------------------------------------------
resource "aws_cloudfront_origin_access_control" "this" {
  name                              = var.oac_name
  description                       = "Origin Access Control for CloudFront S3 frontend bucket access."
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

# ------------------------------------------------------------------------------
# CloudFront Distribution
# ------------------------------------------------------------------------------
resource "aws_cloudfront_distribution" "this" {
  enabled             = true
  is_ipv6_enabled     = true
  default_root_object = "index.html"
  price_class         = "PriceClass_100"

  origin {
    domain_name              = var.bucket_regional_domain_name
    origin_id                = "S3-${var.bucket_id}"
    origin_access_control_id = aws_cloudfront_origin_access_control.this.id
  }

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "S3-${var.bucket_id}"

    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 86400
    max_ttl                = 31536000

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }

  tags = var.tags
}

# ------------------------------------------------------------------------------
# S3 Bucket Policy for CloudFront OAC Access
# ------------------------------------------------------------------------------
# Grants s3:GetObject permission strictly to this CloudFront distribution ARN.
resource "aws_s3_bucket_policy" "frontend" {
  bucket = var.bucket_id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowCloudFrontServicePrincipalReadOnly"
        Effect = "Allow"
        Principal = {
          Service = "cloudfront.amazonaws.com"
        }
        Action   = "s3:GetObject"
        Resource = "${var.bucket_arn}/*"
        Condition = {
          StringEquals = {
            "AWS:SourceArn" = aws_cloudfront_distribution.this.arn
          }
        }
      }
    ]
  })
}

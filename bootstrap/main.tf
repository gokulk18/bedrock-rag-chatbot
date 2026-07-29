# ==============================================================================
# Terraform Bootstrap - Main Infrastructure
# ==============================================================================
# Provisions the remote Terraform backend S3 bucket for storing state files.
#
# AWS Security Best Practices Implemented:
# 1. Bucket Versioning: Protection against state file corruption and accidental loss.
# 2. Server-Side Encryption (SSE-S3): Mandatory AES256 encryption at rest.
# 3. Public Access Block: Complete block on public ACLs and bucket policies.
# 4. Ownership Controls: Enforces BucketOwnerEnforced to disable legacy ACLs.
# 5. Native S3 Locking: Compatible with Terraform 1.15+ native S3 lockfiles.
# ==============================================================================

# Local values for standardized tagging and bucket name generation
locals {
  # Base tags applied across all bootstrap infrastructure
  effective_tags = merge(
    {
      Project     = var.project_name
      Environment = var.environment
      Owner       = var.owner
      ManagedBy   = "Terraform"
    },
    var.common_tags
  )

  # Standardized bucket prefix
  bucket_prefix = "${var.project_name}-${var.environment}-tfstate"
}

# ------------------------------------------------------------------------------
# Random Suffix Generator
# ------------------------------------------------------------------------------
# Generates a random alphanumeric suffix to guarantee global S3 bucket uniqueness.
resource "random_string" "suffix" {
  length  = 8
  special = false
  upper   = false
}

# ------------------------------------------------------------------------------
# S3 State Bucket
# ------------------------------------------------------------------------------
# Primary S3 bucket dedicated exclusively to storing Terraform state files.
resource "aws_s3_bucket" "terraform_state" {
  bucket        = "${local.bucket_prefix}-${random_string.suffix.result}"
  force_destroy = false

  lifecycle {
    prevent_destroy = true
  }
}

# ------------------------------------------------------------------------------
# S3 Bucket Versioning
# ------------------------------------------------------------------------------
# Enables bucket versioning so every state update maintains a historical record.
# Essential for state recovery and rollback in case of corruption.
resource "aws_s3_bucket_versioning" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id

  versioning_configuration {
    status = "Enabled"
  }
}

# ------------------------------------------------------------------------------
# S3 Bucket Server-Side Encryption
# ------------------------------------------------------------------------------
# Enforces mandatory AES256 server-side encryption for all objects written to bucket.
resource "aws_s3_bucket_server_side_encryption_configuration" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# ------------------------------------------------------------------------------
# S3 Public Access Block Configuration
# ------------------------------------------------------------------------------
# Restricts all public access to the state bucket in compliance with AWS Security Hub
# and CIS Benchmark security controls.
resource "aws_s3_bucket_public_access_block" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# ------------------------------------------------------------------------------
# S3 Bucket Ownership Controls
# ------------------------------------------------------------------------------
# Disables legacy S3 Access Control Lists (ACLs) and enforces bucket owner ownership
# for all written objects.
resource "aws_s3_bucket_ownership_controls" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id

  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}

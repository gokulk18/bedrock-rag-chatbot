
variable "github_repository" {
  type        = string
  description = "GitHub repository in 'owner/repo' format allowed to assume OIDC roles."
  default     = "gokulk18/bedrock-rag-chatbot"
}

resource "aws_iam_openid_connect_provider" "github" {
  url             = "https://token.actions.githubusercontent.com"
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [
    "6938fd5d98bab03faadb97b34396831e3780aea1",
    "1c58a2a851587db77a042fe341d5c2b69d4596fc"
  ]

  tags = local.effective_tags
}

data "aws_iam_policy_document" "github_oidc_trust" {
  statement {
    sid     = "GitHubActionsOIDCAssumeRole"
    effect  = "Allow"
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = [aws_iam_openid_connect_provider.github.arn]
    }

    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:aud"
      values   = ["sts.amazonaws.com"]
    }

    condition {
      test     = "StringLikeIgnoreCase"
      variable = "token.actions.githubusercontent.com:sub"
      values   = [
        "repo:${var.github_repository}:*",
        "repo:${lower(var.github_repository)}:*"
      ]
    }
  }
}

resource "aws_iam_role" "github_actions_terraform" {
  name               = "github-actions-terraform-role"
  description        = "IAM role assumed by GitHub Actions to manage core infrastructure via Terraform."
  assume_role_policy = data.aws_iam_policy_document.github_oidc_trust.json
  tags               = local.effective_tags
}

resource "aws_iam_role_policy_attachment" "github_actions_terraform_admin" {
  role       = aws_iam_role.github_actions_terraform.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}

resource "aws_iam_role" "github_actions_lambda" {
  name               = "github-actions-lambda-role"
  description        = "IAM role assumed by GitHub Actions to deploy Lambda code packages."
  assume_role_policy = data.aws_iam_policy_document.github_oidc_trust.json
  tags               = local.effective_tags
}

data "aws_iam_policy_document" "github_actions_lambda" {
  statement {
    sid    = "S3ArtifactsBucketAccess"
    effect = "Allow"
    actions = [
      "s3:PutObject",
      "s3:GetObject",
      "s3:ListBucket"
    ]
    resources = ["arn:aws:s3:::*"]
  }

  statement {
    sid    = "LambdaFunctionUpdateAccess"
    effect = "Allow"
    actions = [
      "lambda:UpdateFunctionCode",
      "lambda:GetFunction",
      "lambda:GetFunctionConfiguration"
    ]
    resources = ["arn:aws:lambda:*:*:function:bedrock-rag-chatbot-*"]
  }
}

resource "aws_iam_policy" "github_actions_lambda" {
  name        = "github-actions-lambda-policy"
  description = "Permissions for GitHub Actions to update Lambda function packages."
  policy      = data.aws_iam_policy_document.github_actions_lambda.json
  tags        = local.effective_tags
}

resource "aws_iam_role_policy_attachment" "github_actions_lambda" {
  role       = aws_iam_role.github_actions_lambda.name
  policy_arn = aws_iam_policy.github_actions_lambda.arn
}

resource "aws_iam_role" "github_actions_frontend" {
  name               = "github-actions-frontend-role"
  description        = "IAM role assumed by GitHub Actions to sync static assets to S3 and invalidate CloudFront."
  assume_role_policy = data.aws_iam_policy_document.github_oidc_trust.json
  tags               = local.effective_tags
}

data "aws_iam_policy_document" "github_actions_frontend" {
  statement {
    sid    = "S3FrontendBucketSyncAccess"
    effect = "Allow"
    actions = [
      "s3:PutObject",
      "s3:GetObject",
      "s3:DeleteObject",
      "s3:ListBucket"
    ]
    resources = ["arn:aws:s3:::*"]
  }

  statement {
    sid    = "CloudFrontInvalidationAccess"
    effect = "Allow"
    actions = [
      "cloudfront:CreateInvalidation"
    ]
    resources = ["*"]
  }
}

resource "aws_iam_policy" "github_actions_frontend" {
  name        = "github-actions-frontend-policy"
  description = "Permissions for GitHub Actions to sync frontend build files and invalidate CloudFront."
  policy      = data.aws_iam_policy_document.github_actions_frontend.json
  tags        = local.effective_tags
}

resource "aws_iam_role_policy_attachment" "github_actions_frontend" {
  role       = aws_iam_role.github_actions_frontend.name
  policy_arn = aws_iam_policy.github_actions_frontend.arn
}

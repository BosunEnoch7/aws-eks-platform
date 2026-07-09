data "aws_caller_identity" "current" {}

data "aws_iam_policy_document" "eks_cluster_admin_assume_role" {
  statement {
    sid     = "AllowCurrentOperatorToAssumeRole"
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "AWS"
      identifiers = [data.aws_caller_identity.current.arn]
    }
  }
}

data "aws_iam_policy_document" "eks_cluster_admin" {
  statement {
    sid    = "DescribeDevelopmentCluster"
    effect = "Allow"

    actions = [
      "eks:DescribeCluster",
    ]

    resources = [
      "arn:aws:eks:${var.aws_region}:${data.aws_caller_identity.current.account_id}:cluster/${local.project}-dev",
    ]
  }
}

data "aws_iam_policy_document" "state_bucket" {
  statement {
    sid    = "DenyInsecureTransport"
    effect = "Deny"

    principals {
      type        = "*"
      identifiers = ["*"]
    }

    actions = ["s3:*"]

    resources = [
      aws_s3_bucket.terraform_state.arn,
      "${aws_s3_bucket.terraform_state.arn}/*",
    ]

    condition {
      test     = "Bool"
      variable = "aws:SecureTransport"
      values   = ["false"]
    }
  }
}

resource "aws_s3_bucket" "terraform_state" {
  bucket = local.state_bucket_name

  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_s3_bucket_ownership_controls" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id

  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}

resource "aws_s3_bucket_public_access_block" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_versioning" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_policy" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id
  policy = data.aws_iam_policy_document.state_bucket.json

  depends_on = [aws_s3_bucket_public_access_block.terraform_state]
}

resource "aws_iam_role" "eks_cluster_admin" {
  name               = "${local.project}-eks-cluster-admin"
  description        = "Operator role granted initial Kubernetes admin access through EKS access entries."
  assume_role_policy = data.aws_iam_policy_document.eks_cluster_admin_assume_role.json
  tags               = local.common_tags
}

resource "aws_iam_policy" "eks_cluster_admin" {
  name        = "${local.project}-eks-cluster-admin-describe"
  description = "Allows the EKS admin role to describe the development cluster for kubectl authentication."
  policy      = data.aws_iam_policy_document.eks_cluster_admin.json
  tags        = local.common_tags
}

resource "aws_iam_role_policy_attachment" "eks_cluster_admin" {
  policy_arn = aws_iam_policy.eks_cluster_admin.arn
  role       = aws_iam_role.eks_cluster_admin.name
}

resource "aws_budgets_budget" "monthly_account_cost" {
  name         = "${local.project}-monthly-account-cost"
  budget_type  = "COST"
  limit_amount = tostring(var.monthly_budget_amount_usd)
  limit_unit   = "USD"
  time_unit    = "MONTHLY"

  notification {
    comparison_operator        = "GREATER_THAN"
    threshold                  = 50
    threshold_type             = "PERCENTAGE"
    notification_type          = "ACTUAL"
    subscriber_email_addresses = [var.budget_notification_email]
  }

  notification {
    comparison_operator        = "GREATER_THAN"
    threshold                  = 80
    threshold_type             = "PERCENTAGE"
    notification_type          = "ACTUAL"
    subscriber_email_addresses = [var.budget_notification_email]
  }

  notification {
    comparison_operator        = "GREATER_THAN"
    threshold                  = 100
    threshold_type             = "PERCENTAGE"
    notification_type          = "FORECASTED"
    subscriber_email_addresses = [var.budget_notification_email]
  }
}

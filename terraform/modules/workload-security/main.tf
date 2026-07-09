locals {
  oidc_issuer_hostpath = replace(var.oidc_provider_url, "https://", "")
}

resource "aws_secretsmanager_secret" "application_runtime" {
  name                    = var.secret_name
  description             = "Runtime configuration secret for ${var.namespace}/${var.service_account}."
  recovery_window_in_days = var.recovery_window_in_days
  tags                    = var.tags
}

data "aws_iam_policy_document" "application_runtime_assume_role" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = [var.oidc_provider_arn]
    }

    condition {
      test     = "StringEquals"
      variable = "${local.oidc_issuer_hostpath}:aud"
      values   = ["sts.amazonaws.com"]
    }

    condition {
      test     = "StringEquals"
      variable = "${local.oidc_issuer_hostpath}:sub"
      values   = ["system:serviceaccount:${var.namespace}:${var.service_account}"]
    }
  }
}

data "aws_iam_policy_document" "application_runtime_secret" {
  statement {
    sid    = "ReadOnlyApplicationRuntimeSecret"
    effect = "Allow"

    actions = [
      "secretsmanager:DescribeSecret",
      "secretsmanager:GetSecretValue",
    ]

    resources = [aws_secretsmanager_secret.application_runtime.arn]
  }
}

resource "aws_iam_policy" "application_runtime_secret" {
  name        = "${var.cluster_name}-${var.service_account}-runtime-secret"
  description = "Read-only access to the application runtime secret."
  policy      = data.aws_iam_policy_document.application_runtime_secret.json
  tags        = var.tags
}

resource "aws_iam_role" "application_runtime" {
  name               = "${var.cluster_name}-${var.service_account}"
  assume_role_policy = data.aws_iam_policy_document.application_runtime_assume_role.json
  tags               = var.tags
}

resource "aws_iam_role_policy_attachment" "application_runtime_secret" {
  policy_arn = aws_iam_policy.application_runtime_secret.arn
  role       = aws_iam_role.application_runtime.name
}

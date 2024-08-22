provider "aws" {
  region = var.region
}

data "aws_caller_identity" "current" {}

resource "aws_iam_group" "github_actions_group" {
  name = "github-actions-group"
}

resource "aws_iam_policy" "ecr_policy" {
  name        = "gha-ecr-policy"
  path        = "/"
  description = "Policy for ECR access"
  policy      = templatefile("${path.module}/gha-ecr-policy.json", { aws_account_id = var.aws_account_id })
}

resource "aws_iam_policy" "assuming_policy" {
  name        = "gha-assuming-policy"
  path        = "/"
  description = "Policy for assuming roles"
  policy      = templatefile("${path.module}/gha-assuming-policy.json", { aws_account_id = var.aws_account_id })
}

resource "aws_iam_policy" "trust_policy" {
  name        = "gha-trust-policy"
  path        = "/"
  description = "Trust policy"
  policy      = templatefile("${path.module}/gha-trust-policy.json", { aws_account_id = var.aws_account_id })
}

resource "aws_iam_group_policy_attachment" "ecr_policy_attachment" {
  group      = aws_iam_group.github_actions_group.name
  policy_arn = aws_iam_policy.ecr_policy.arn
}

resource "aws_iam_group_policy_attachment" "assuming_policy_attachment" {
  group      = aws_iam_group.github_actions_group.name
  policy_arn = aws_iam_policy.assuming_policy.arn
}

resource "aws_iam_group_policy_attachment" "trust_policy_attachment" {
  group      = aws_iam_group.github_actions_group.name
  policy_arn = aws_iam_policy.trust_policy.arn
}

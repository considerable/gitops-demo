provider "aws" {
  region = var.region
}

data "aws_caller_identity" "current" {}

resource "aws_iam_group" "github_actions_group" {
  name = "github-actions-group"
}

data "aws_iam_policy" "existing_ecr_policy" {
  arn = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:policy/gha-ecr-policy"
}

data "aws_iam_policy" "existing_assuming_policy" {
  arn = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:policy/gha-assuming-policy"
}

data "aws_iam_policy" "existing_trust_policy" {
  arn = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:policy/gha-trust-policy"
}

resource "aws_iam_policy" "ecr_policy" {
  name        = "gha-ecr-policy"
  path        = "/"
  description = "Policy for ECR access"
  policy      = file("gha-ecr-policy.json")
}

resource "aws_iam_policy" "assuming_policy" {
  name        = "gha-assuming-policy"
  path        = "/"
  description = "Policy for assuming roles"
  policy      = file("gha-assuming-policy.json")
}

resource "aws_iam_policy" "trust_policy" {
  name        = "gha-trust-policy"
  path        = "/"
  description = "Trust policy"
  policy      = file("gha-trust-policy.json")
}

resource "aws_iam_group_policy_attachment" "ecr_policy_attachment" {
  group      = aws_iam_group.github_actions_group.name
  policy_arn = coalesce(aws_iam_policy.ecr_policy.arn, data.aws_iam_policy.existing_ecr_policy.arn)
}

resource "aws_iam_group_policy_attachment" "assuming_policy_attachment" {
  group      = aws_iam_group.github_actions_group.name
  policy_arn = coalesce(aws_iam_policy.assuming_policy.arn, data.aws_iam_policy.existing_assuming_policy.arn)
}

resource "aws_iam_group_policy_attachment" "trust_policy_attachment" {
  group      = aws_iam_group.github_actions_group.name
  policy_arn = coalesce(aws_iam_policy.trust_policy.arn, data.aws_iam_policy.existing_trust_policy.arn)
}

resource "null_resource" "create_ecr_repository" {
  provisioner "local-exec" {
    command = <<EOT
      aws ecr describe-repositories --repository-names platform-mvp-ecr || \
      aws ecr create-repository --repository-name platform-mvp-ecr
    EOT
  }
}

resource "null_resource" "delete_ecr_images" {
  provisioner "local-exec" {
    command = <<EOT
      aws ecr list-images --repository-name platform-mvp-ecr --query 'imageIds[*]' --output json | \
      jq -c '.[]' | \
      xargs -I {} aws ecr batch-delete-image --repository-name platform-mvp-ecr --image-ids {}
    EOT
  }
}

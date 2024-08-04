provider "aws" {
  region = var.region
}

resource "aws_iam_group" "github_actions_group" {
  provider = aws.default
  name     = "github-actions-group"
}

resource "aws_iam_policy" "ecr_policy" {
  provider    = aws.default
  name        = "gha-ecr-policy"
  path        = "/"
  description = "Policy for ECR access"
  policy      = file("../terraform/gha-ecr-policy.json")
}

resource "aws_iam_group_policy_attachment" "ecr_policy_attachment" {
  provider  = aws.default
  group     = aws_iam_group.github_actions_group.name
  policy_arn = aws_iam_policy.ecr_policy.arn
}

resource "aws_iam_policy" "assuming_policy" {
  provider    = aws.default
  name        = "gha-assuming-policy"
  path        = "/"
  description = "Policy for assuming roles"
  policy      = file("../terraform/gha-assuming-policy.json")
}

resource "aws_iam_group_policy_attachment" "assuming_policy_attachment" {
  provider  = aws.default
  group     = aws_iam_group.github_actions_group.name
  policy_arn = aws_iam_policy.assuming_policy.arn
}

resource "aws_iam_policy" "trust_policy" {
  name        = "gha-trust-policy"
  path        = "/"
  description = "Trust policy"
  policy      = file("../terraform/gha-trust-policy.json")
}

resource "aws_iam_group_policy_attachment" "trust_policy_attachment" {
  group      = aws_iam_group.github_actions_group.name
  policy_arn = aws_iam_policy.trust_policy.arn
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

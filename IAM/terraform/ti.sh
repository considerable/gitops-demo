terraform import aws_iam_group.github_actions_group github-actions-group
terraform import aws_iam_policy.ecr_policy arn:aws:iam::757996166630:policy/gha-ecr-policy
terraform import aws_iam_policy.assuming_policy arn:aws:iam::757996166630:policy/gha-assuming-policy
terraform import aws_iam_policy.trust_policy arn:aws:iam::757996166630:policy/gha-trust-policy


terraform import aws_iam_group.github_actions_group github-actions-group
terraform import aws_iam_policy.ecr_policy arn:aws:iam::<account-id>:policy/gha-ecr-policy
terraform import aws_iam_policy.assuming_policy arn:aws:iam::<account-id>:policy/gha-assuming-policy
terraform import aws_iam_policy.trust_policy arn:aws:iam::<account-id>:policy/gha-trust-policy


#!/bin/bash

# Set variables
AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query "Account" --output text)
REGION="us-west-2"  # Modify as needed

# Check if AWS_ACCOUNT_ID is set
if [ -z "$AWS_ACCOUNT_ID" ]; then
  echo "Error: AWS_ACCOUNT_ID is not set. Exiting."
  exit 1
fi

# Export the AWS_ACCOUNT_ID to ensure Terraform picks it up
export TF_VAR_aws_account_id=$AWS_ACCOUNT_ID

# Initialize Terraform
terraform init -input=false

# Import existing IAM group
terraform import aws_iam_group.github_actions_group github-actions-group

# Import existing IAM policies
terraform import aws_iam_policy.ecr_policy arn:aws:iam::${AWS_ACCOUNT_ID}:policy/gha-ecr-policy
terraform import aws_iam_policy.assuming_policy arn:aws:iam::${AWS_ACCOUNT_ID}:policy/gha-assuming-policy
terraform import aws_iam_policy.trust_policy arn:aws:iam::${AWS_ACCOUNT_ID}:policy/gha-trust-policy

# Plan and apply the Terraform configuration with auto-approve
terraform plan -input=false -var="aws_account_id=${AWS_ACCOUNT_ID}" -var="region=${REGION}" -out=tfplan
terraform apply -input=false -auto-approve tfplan

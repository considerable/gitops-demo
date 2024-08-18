#!/bin/bash

# Set variables
AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query "Account" --output text)
REGION="us-west-2"
SSH_KEY_NAME="k8s-mvp"

# Check if AWS_ACCOUNT_ID is set
if [ -z "$AWS_ACCOUNT_ID" ]; then
  echo "Error: AWS_ACCOUNT_ID is not set. Exiting."
  exit 1
fi

# Export the AWS_ACCOUNT_ID to ensure Terraform picks it up
export TF_VAR_aws_account_id=$AWS_ACCOUNT_ID

## Fetch the latest Amazon Linux 2 AMI ID
#AMI_ID=$(aws ec2 describe-images --region "$REGION" \
#  --filters "Name=name,Values=amzn2-ami-hvm-*-x86_64-gp2" \
#  --query "Images | sort_by(@, &CreationDate) | [-1].ImageId" --output text)

## Retrieve the latest Amazon Linux 2023 AMI ID with the SSM Agent preinstalled.
AMI_ID=$(aws ssm get-parameters --region "$REGION" \
  --names /aws/service/ami-amazon-linux-latest/al2023-ami-kernel-6.1-x86_64 \
  --query "Parameters[0].Value" --output text)

# Check if AMI_ID is set
if [ -z "$AMI_ID" ]; then
  echo "Error: Unable to fetch AMI ID with SSM Agent. Exiting."
  exit 1
fi

# Check if AMI_ID is set
if [ -z "$AMI_ID" ]; then
  echo "Error: Unable to fetch AMI ID. Exiting."
  exit 1
fi

# Fetch your public IP address
MY_PUBLIC_IP=$(curl -4s ipinfo.io/ip)

# Export the variables for Terraform
export TF_VAR_ami_id=$AMI_ID
export TF_VAR_my_public_ip=$MY_PUBLIC_IP

# Initialize Terraform
terraform init -input=false

# Plan and apply the Terraform configuration with auto-approve
terraform plan -input=false -var="aws_account_id=${AWS_ACCOUNT_ID}" -var="region=${REGION}" -var="ami_id=${AMI_ID}" -var="key_name=${SSH_KEY_NAME}" -out=tfplan
terraform apply -input=false -auto-approve tfplan

# Fetch the public IPs of the instances
CONTROLLER_PUBLIC_IP=$(terraform output -raw controller_public_ip)
WORKER_PUBLIC_IP=$(terraform output -raw worker_public_ip)

# Display the SSH access instructions
echo "You can access your EC2 instances via SSH using the following commands:"
echo "Controller: ssh -i ~/.ssh/${SSH_KEY_NAME}.pem ec2-user@${CONTROLLER_PUBLIC_IP}"
echo "Worker: ssh -i ~/.ssh/${SSH_KEY_NAME}.pem ec2-user@${WORKER_PUBLIc_ip}"

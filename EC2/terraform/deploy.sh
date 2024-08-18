#!/bin/bash

# Set variables
REGION="us-west-2"
SSH_KEY_NAME="k8s-mvp"
AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query "Account" --output text)

# Check if AWS_ACCOUNT_ID is set
if [ -z "$AWS_ACCOUNT_ID" ]; then
  echo "Error: AWS_ACCOUNT_ID is not set. Exiting."
  exit 1
fi

# Export the AWS_ACCOUNT_ID to ensure Terraform picks it up
export TF_VAR_aws_account_id=$AWS_ACCOUNT_ID

# Retrieve the latest Amazon Linux 2023 AMI ID with the SSM Agent preinstalled.
AMI_ID=$(aws ssm get-parameters --region "$REGION" \
  --names /aws/service/ami-amazon-linux-latest/al2023-ami-kernel-6.1-x86_64 \
  --query "Parameters[0].Value" --output text)

# Export the variables for Terraform
export TF_VAR_ami_id=$AMI_ID
export TF_VAR_key_name=$SSH_KEY_NAME

# Initialize Terraform
terraform init -input=false

# Import existing AWS resources if they exist
terraform import aws_iam_role.ec2_role k8s-mvp-ec2-role || true
terraform import aws_iam_instance_profile.ec2_instance_profile k8s-mvp-instance-profile || true
terraform import aws_cloudwatch_log_group.k8s_mvp_log_group /aws/ec2/k8s-mvp || true

# Plan and apply the Terraform configuration with auto-approve
terraform plan -input=false -var="aws_account_id=${AWS_ACCOUNT_ID}" -var="region=${REGION}" -var="ami_id=${AMI_ID}" -var="key_name=${SSH_KEY_NAME}" -out=tfplan
terraform apply -input=false -auto-approve tfplan

# Fetch the public IPs of the instances
CONTROLLER_PUBLIC_IP=$(terraform output -raw controller_public_ip)
WORKER_PUBLIC_IP=$(terraform output -raw worker_public_ip)

# Display the SSH access instructions
echo "You can access your EC2 instances via SSH using the following commands:"
echo "Controller: ssh -i ~/.ssh/${SSH_KEY_NAME}.pem ec2-user@${CONTROLLER_PUBLIC_IP}"
echo "Worker: ssh -i ~/.ssh/${SSH_KEY_NAME}.pem ec2-user@${WORKER_PUBLIC_IP}"

# Update Ansible inventory with the new IP addresses
cat ../ansible/inventory.ini-eg \
  | sed -e "s/<controller_public_ip>/${CONTROLLER_PUBLIC_IP}/" -e "s/<worker_public_ip>/${WORKER_PUBLIC_IP}/" \
  > ../ansible/inventory.ini

# Run Ansible playbook
cd ../ansible
ansible-playbook -i inventory.ini playbook.yml

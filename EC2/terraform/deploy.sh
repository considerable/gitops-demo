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

# Retrieve the latest Ubuntu 24.04 AMI ID
AMI_ID="ami-0aff18ec83b712f05"

# Export the variables for Terraform
export TF_VAR_ami_id=$AMI_ID
export TF_VAR_key_name=$SSH_KEY_NAME

# Initialize Terraform
terraform init -input=false

# Plan and apply the Terraform configuration with auto-approve
terraform plan -input=false -var="aws_account_id=${AWS_ACCOUNT_ID}" -var="region=${REGION}" -var="ami_id=${AMI_ID}" -var="key_name=${SSH_KEY_NAME}" -out=tfplan
terraform apply -input=false -auto-approve tfplan

# Fetch the public IPs of the instances
MASTER_PUBLIC_IP=$(terraform output -raw master_public_ip)
WORKER_PUBLIC_IP=$(terraform output -raw worker_public_ip)

# Fetch the private IPs of the instances
MASTER_PRIVATE_IP=$(terraform output -raw master_private_ip)
WORKER_PRIVATE_IP=$(terraform output -raw worker_private_ip)

# Display the SSH access instructions
echo "You can access your EC2 instances via SSH using the following commands:"
echo "Master: ssh -i ~/.ssh/${SSH_KEY_NAME}.pem ubuntu@${MASTER_PUBLIC_IP}"
echo "Worker: ssh -i ~/.ssh/${SSH_KEY_NAME}.pem ubuntu@${WORKER_PUBLIC_IP}"

# Update Ansible inventory with the new public IP addresses
cat ../ansible/inventory.ini-eg | sed \
  -e "s/<master_public_ip>/${MASTER_PUBLIC_IP}/" \
  -e "s/<worker_public_ip>/${WORKER_PUBLIC_IP}/" \
  > ../ansible/inventory.ini

# Update vars.yml with the private IP addresses
cat ../ansible/vars.yml-eg | sed \
  -e "s/<master_private_ip>/${MASTER_PRIVATE_IP}/" \
  -e "s/<worker_private_ip>/${WORKER_PRIVATE_IP}/" \
  > ../ansible/vars.yml

# Run Ansible playbook
echo Run Ansible playbook
echo cd ../ansible
echo ansible-playbook -i inventory.ini playbook.yml

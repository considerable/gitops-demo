# Terraform AWS ECR & IAM Setup

This project automates the setup of AWS IAM roles and policies for GitHub Actions integration with AWS ECR using Terraform. The scripts provided help manage Terraform configurations, clean up resources, and deploy the infrastructure.

## Folder Structure

```
.
├── clean-aws-ecr.sh
├── clean-local-tf.sh
├── deploy.sh
├── gha-assuming-policy.json
├── gha-ecr-policy.json
├── gha-trust-policy.json
├── main.tf
└── variabbles.tf
```

### File Descriptions

- **`clean-aws-ecr.sh`**: Cleans up all images in the specified AWS ECR repository by listing and deleting them.

- **`clean-local-tf.sh`**: Cleans up Terraform state files and other local temporary files to ensure a fresh environment.

- **`deploy.sh`**: Automates the deployment process by initializing Terraform, importing existing IAM resources, and applying the Terraform configuration.

- **`gha-assuming-policy.json`**: JSON policy document allowing GitHub Actions to assume specific IAM roles.

- **`gha-ecr-policy.json`**: JSON policy document granting GitHub Actions permissions to interact with AWS ECR (e.g., listing and deleting images).

- **`gha-trust-policy.json`**: JSON policy document defining trust relationships for GitHub Actions roles.

- **`main.tf`**: Terraform configuration file that sets up the necessary IAM groups, policies, and attachments.

- **`variabbles.tf`**: Defines the variables used in the Terraform configuration, including AWS region and account ID.

## Usage

### 1. Clean Up AWS ECR Images

To delete all images in your specified AWS ECR repository:

```bash
./clean-aws-ecr.sh
```

### 2. Clean Up Local Terraform Files

To remove local Terraform state and plan files:

```bash
./clean-local-tf.sh
```

### 3. Deploy Infrastructure

To deploy the infrastructure using Terraform:

```bash
./deploy.sh
```

This script will:

1. Set the AWS account ID and region.
2. Initialize Terraform.
3. Import existing IAM resources.
4. Plan and apply the Terraform configuration.

### 4. Customize Policies

The IAM policies (`gha-assuming-policy.json`, `gha-ecr-policy.json`, `gha-trust-policy.json`) can be modified to suit your specific use case.

## Prerequisites

- AWS CLI configured with appropriate access.
- Terraform installed and configured.

## Notes

- Modify the `REGION` variable in `deploy.sh` as needed.
- Ensure that the `aws_account_id` variable is correctly set in your environment or via Terraform variables.


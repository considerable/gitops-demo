## Terraform Setup for GitHub Actions IAM Group and ECR Repository

Terraform configuration files for setting up an AWS IAM group and ECR repository.     
These resources are specifically designed to support a GitHub Actions workflow for building, pushing, and testing Docker images.

### Files Overview

```plaintext
.
├── gha-assuming-policy.json        # IAM policy for assuming roles in GitHub Actions
├── gha-ecr-policy.json             # IAM policy for ECR access in GitHub Actions
├── gha-trust-policy.json           # Trust policy for GitHub Actions role assumption
├── main.tf                         # Main Terraform configuration
├── output.tf                       # Outputs the IAM group ARN
├── provider.tf                     # AWS provider configuration
├── terraform-import.sh            # Script for importing existing resources
├── terraform.tfstate               # Terraform state file
├── terraform.tfstate.backup        # Terraform state backup file
└── variables.tf                    # Variables for Terraform configuration
```

### 1. `gha-assuming-policy.json`
Defines the IAM policy that allows GitHub Actions to assume a specific IAM role.

### 2. `gha-ecr-policy.json`
Defines the IAM policy that allows access to the Amazon ECR (Elastic Container Registry).

### 3. `gha-trust-policy.json`
Defines the trust policy that specifies which entities can assume the GitHub Actions role.

### 4. `main.tf`
- Configures the AWS provider.
- Creates an IAM group named `github-actions-group`.
- Attaches the ECR and assuming policies to the group.
- Defines a provisioner to create an ECR repository named `platform-mvp-ecr` and a provisioner to delete its images.

### 5. `output.tf`
Outputs the ARN (Amazon Resource Name) of the `github-actions-group` IAM group.

### 6. `provider.tf`
Specifies the AWS region for the provider.

### 7. `variables.tf`
Defines the `region` variable used to set the AWS region.

### 8. `terraform-import.sh`
Script to import existing IAM group and policies into Terraform state if they already exist.

### Usage Instructions

1. **Install Terraform**: Make sure you have Terraform installed on your machine.

2. **Initialize Terraform**:
   ```bash
   terraform init
   ```

3. **Import Existing Resources** (if they already exist):
   ```bash
   bash terraform-import.sh
   ```
   This script will import the IAM group and policies into your Terraform state.

4. **Apply the Terraform Configuration**:
   ```bash
   terraform apply
   ```
   This command will create the IAM group, attach policies, and set up the ECR repository if they do not already exist.

5. **Integrate with GitHub Actions**:
   Use the IAM role and policies created by Terraform in your GitHub Actions workflow to build, push, and test Docker images in your ECR repository.

### GitHub Actions Workflow

The `.github/workflows/ecr.yml` file provides a GitHub Actions workflow that:

1. **Checks out the repository**.
2. **Sets up Docker Buildx**.
3. **Configures AWS credentials** using the IAM role.
4. **Logs in to Amazon ECR**.
5. **Builds and pushes a multi-architecture Docker image** to ECR.
6. **Pulls and tests the Docker image**.

### Notes

- Update the IAM role ARN, region, and other secrets as required in your GitHub Actions workflow file.
- Customize the Terraform variables if you need to change the default settings.
- Ensure that the `terraform-import.sh` script is configured with correct resource identifiers.

---

By using this setup, you can automate the deployment of Docker images to AWS ECR via GitHub Actions, ensuring a consistent and secure CI/CD pipeline.

### `terraform-import.sh`

You may want to create a `terraform-import.sh` script with the following content to handle the import of existing resources:

```bash
#!/bin/bash

# Replace <account-id> with your AWS account ID

terraform import aws_iam_group.github_actions_group github-actions-group
terraform import aws_iam_policy.ecr_policy arn:aws:iam::<account-id>:policy/gha-ecr-policy
terraform import aws_iam_policy.assuming_policy arn:aws:iam::<account-id>:policy/gha-assuming-policy
terraform import aws_iam_policy.trust_policy arn:aws:iam::<account-id>:policy/gha-trust-policy
```

Make sure to make this script executable with:

```bash
chmod +x terraform-import.sh
```

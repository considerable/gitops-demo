## Kubernetes Cluster Setup with Terraform and Ansible

This setup provisions two EC2 instances using Terraform, configures them to use IMDSv2, and then installs a Kubernetes cluster on them using Ansible.

### Directory Structure

```plaintext
../../EC2
├── ansible
│   ├── README.md
│   ├── inventory.ini-eg
│   ├── playbook.yml
│   ├── roles
│   │   ├── common
│   │   │   └── tasks
│   │   │       └── main.yml
│   │   ├── master
│   │   │   └── tasks
│   │   │       └── main.yml
│   │   └── worker
│   │       └── tasks
│   │           └── main.yml
│   └── vars.yml-eg
└── terraform
    ├── README.md
    ├── deploy.sh
    ├── main.tf
    ├── outputs.tf
    └── variables.tf
```

### Prerequisites

- **Terraform**: Ensure Terraform is installed on your local machine.
- **Ansible**: Ensure Ansible is installed on your local machine.
- **AWS CLI**: Install the AWS CLI and configure it with your credentials.
- **SSH keys**: Store the SSH key pair name in a var called `SSH_KEY_NAME`.

### Steps to Deploy

#### 1. Provision EC2 Instances with Terraform

1. **Navigate to the `terraform/` directory**:

```sh
cd ../EC2/terraform
```

2. **Run the `deploy.sh` script**:
    
```sh
./deploy.sh
```

This script will initialize Terraform, create a VPC, a subnet, an Internet Gateway, a security group, and provision the EC2 instances the latest Amazon Linux 2 AMI ID and with IMDSv2 enabled.

#### Terraform Outputs

Terraform will provide the following outputs:

- **Controller Public IP**: The public IP address of the Kubernetes controller node.
- **Worker Public IP**: The public IP address of the Kubernetes worker node.
- **VPC ID**: The ID of the VPC created by Terraform.

#### Terraform Notes

- The Terraform configuration enforces the use of IMDSv2 on the EC2 instances.
- Ensure you have the necessary IAM permissions to create instances in AWS.
- The AMI ID is dynamically fetched by the `deploy.sh` script to ensure you're using the latest Amazon Linux 2 image.
- The SSH key pair name is sourced from environment (`SSH_KEY_NAME`).

#### 2. Configure Kubernetes with Ansible

1. Navigate to the `terraform` directory and run `deploy.sh` to provision the infrastructure and configure the Kubernetes cluster.
2. The script will automatically update the Ansible inventory with the new IP addresses and run the Ansible playbook to set up the cluster.

#### 3. Access the Kubernetes Cluster

- SSH into the controller node using the public IP provided by Terraform.
- Use `kubectl` to interact with the Kubernetes cluster.


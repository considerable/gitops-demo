provider "aws" {
  region = var.region
}

# Create VPC
resource "aws_vpc" "k8s_vpc" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "k8s-vpc"
  }
}

# Create Subnet with auto-assign public IP
resource "aws_subnet" "k8s_subnet" {
  vpc_id            = aws_vpc.k8s_vpc.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = var.az
  map_public_ip_on_launch = true  # Ensure public IPs are auto-assigned

  tags = {
    Name = "k8s-subnet"
  }
}

# Create Internet Gateway
resource "aws_internet_gateway" "k8s_igw" {
  vpc_id = aws_vpc.k8s_vpc.id

  tags = {
    Name = "k8s-igw"
  }
}

# Create Route Table
resource "aws_route_table" "k8s_route_table" {
  vpc_id = aws_vpc.k8s_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.k8s_igw.id
  }

  tags = {
    Name = "k8s-route-table"
  }
}

# Associate Route Table with Subnet
resource "aws_route_table_association" "k8s_rta" {
  subnet_id      = aws_subnet.k8s_subnet.id
  route_table_id = aws_route_table.k8s_route_table.id
}

# Create Security Group
    #cidr_blocks = ["18.237.140.160/29","104.28.116.0/24"]
    #ipv6_cidr_blocks = ["2a09:bac2:afff:119::/64"]
resource "aws_security_group" "k8s_security_group" {
  vpc_id      = aws_vpc.k8s_vpc.id
  name        = "k8s-security-group"
  description = "Security group for Kubernetes instances"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  ingress {
    from_port   = 6443
    to_port     = 6443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "k8s-security-group"
  }
}

# Create CloudWatch Log Group
resource "aws_cloudwatch_log_group" "k8s_mvp_log_group" {
  name              = "/aws/ec2/k8s-mvp"
  retention_in_days = 7
   
  tags = {
    Name = "k8s-mvp-log-group"
  }
}

# Create IAM Role for EC2 Instances
resource "aws_iam_role" "ec2_role" {
  name = "k8s-mvp-ec2-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action    = "sts:AssumeRole"
        Effect    = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Name = "k8s-mvp-ec2-role"
  }
}

# Attach AmazonSSMManagedInstanceCore policy to the role
resource "aws_iam_role_policy_attachment" "ssm_policy_attachment" {
  role   = aws_iam_role.ec2_role.id
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

# Create IAM Role Policy for CloudWatch Logs
resource "aws_iam_role_policy" "ec2_policy" {
  name   = "k8s-mvp-ec2-policy"
  role   = aws_iam_role.ec2_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "logs:DescribeLogStreams",
          "logs:CreateLogGroup"
        ]
        Effect   = "Allow"
        Resource = "arn:aws:logs:${var.region}:${var.aws_account_id}:log-group:/aws/ec2/k8s-mvp:*"
      }
    ]
  })
}

# Create IAM Instance Profile for EC2 Instances
resource "aws_iam_instance_profile" "ec2_instance_profile" {
  name = "k8s-mvp-instance-profile"
  role = aws_iam_role.ec2_role.name
}

# Create EC2 Instance for Controller
resource "aws_instance" "controller" {
  ami                    = var.ami_id
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.k8s_subnet.id
  key_name               = var.key_name
  iam_instance_profile   = aws_iam_instance_profile.ec2_instance_profile.name
  associate_public_ip_address = true  # Ensure public IP is assigned

  tags = {
    Name = "K8s-Controller"
  }

  vpc_security_group_ids = [aws_security_group.k8s_security_group.id]

  user_data = <<-EOF
    #!/bin/bash
    yum update -y
    yum install -y awslogs

    # Configure CloudWatch Logs
    cat <<-CONFIG > /etc/awslogs/awslogs.conf
    [general]
    state_file = /var/lib/awslogs/agent-state
    
    [/var/log/messages]
    log_group_name = /aws/ec2/k8s-mvp
    log_stream_name = {instance_id}/var/log/messages
    file = /var/log/messages
    
    [/var/log/secure]
    log_group_name = /aws/ec2/k8s-mvp
    log_stream_name = {instance_id}/var/log/secure
    file = /var/log/secure
    CONFIG

    # Start the CloudWatch Logs agent
    systemctl start awslogsd
    systemctl enable awslogsd
  EOF
}

# Create EC2 Instance for Worker
resource "aws_instance" "worker" {
  ami                    = var.ami_id
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.k8s_subnet.id
  key_name               = var.key_name
  iam_instance_profile   = aws_iam_instance_profile.ec2_instance_profile.name
  associate_public_ip_address = true  # Ensure public IP is assigned

  tags = {
    Name = "K8s-Worker"
  }

  vpc_security_group_ids = [aws_security_group.k8s_security_group.id]

  user_data = <<-EOF
    #!/bin/bash
    yum update -y
    yum install -y awslogs

    # Configure CloudWatch Logs
    cat <<-CONFIG > /etc/awslogs/awslogs.conf
    [general]
    state_file = /var/lib/awslogs/agent-state
    
    [/var/log/messages]
    log_group_name = /aws/ec2/k8s-mvp
    log_stream_name = {instance_id}/var/log/messages
    file = /var/log/messages
    
    [/var/log/secure]
    log_group_name = /aws/ec2/k8s-mvp
    log_stream_name = {instance_id}/var/log/secure
    file = /var/log/secure
    CONFIG

    # Start the CloudWatch Logs agent
    systemctl start awslogsd
    systemctl enable awslogsd
  EOF
}

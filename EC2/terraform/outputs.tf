output "master_public_ip" {
  description = "The public IP of the Kubernetes master"
  value       = aws_instance.master.public_ip
}

output "worker_public_ip" {
  description = "The public IP of the Kubernetes worker"
  value       = aws_instance.worker.public_ip
}

output "master_private_ip" {
  description = "The private IP of the Kubernetes master"
  value       = aws_instance.master.private_ip
}

output "worker_private_ip" {
  description = "The private IP of the Kubernetes worker"
  value       = aws_instance.worker.private_ip
}

output "vpc_id" {
  description = "The ID of the VPC"
  value       = aws_vpc.k8s_vpc.id
}

output "subnet_id" {
  description = "The ID of the Subnet"
  value       = aws_subnet.k8s_subnet.id
}

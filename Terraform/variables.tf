variable "aws_region" {
  description = "AWS region where resources will be created"
  default     = "us-east-1"
}

variable "instance_type" {
  description = "Type of EC2 instance to create"
  default     = "t3.micro"
}

variable "key_name" {
  description = "SSH key pair name used for EC2 access"
  default     = "Key-Pair"   # 👈 Replace this with your actual key pair name from AWS console
}

variable "public_key_path" {
  description = "Path to the public key file (.pub)"
  default     = "./Key-Pair.pub"   # 👈 Make sure this file exists in your Terraform folder
}

variable "my_ip_cidr" {
  description = "Allowed CIDR block for SSH access"
  default     = "0.0.0.0/0"   # You can restrict this to your IP for better security
}

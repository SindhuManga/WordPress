variable "aws_region" { default = "us-east-1" }
variable "instance_type" { default = "t2.micro" }
variable "key_name" { description = "SSH key name" }
variable "public_key_path" { description = "Path to public key file" }
variable "my_ip_cidr" { default = "0.0.0.0/0" } # replace with your IP/CIDR for SSH

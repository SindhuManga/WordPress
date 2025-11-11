provider "aws" {
  region = var.aws_region
}

# ✅ Removed aws_key_pair resource because key already exists in AWS
# resource "aws_key_pair" "deployer" {
#   key_name   = var.key_name
#   public_key = file(var.public_key_path)
# }

resource "aws_security_group" "wordpress_sg" {
  name        = "wordpress-sg"
  description = "Allow HTTP and SSH"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.my_ip_cidr]    # limit SSH to your IP if possible
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "wp" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.instance_type

  # ✅ Use your existing AWS key pair
  key_name               = var.key_name

  vpc_security_group_ids = [aws_security_group.wordpress_sg.id]
  tags = {
    Name = "wordpress-server"
  }

  user_data = <<-EOF
              #!/bin/bash
              apt-get update -y
              apt-get install -y docker.io docker-compose git
              systemctl enable --now docker
              mkdir -p /opt/wordpress
              cd /opt/wordpress
              git clone https://github.com/SindhuManga/WordPress.git
              cd compose
              docker-compose pull || true
              docker-compose up -d
              EOF

  root_block_device {
    volume_size = 20
    volume_type = "gp2"
  }
}

data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }
}

# ✅ Output public IP for Jenkins next stage
output "public_ip" {
  value = aws_instance.wp.public_ip
}

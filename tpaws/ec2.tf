resource "tls_private_key" "key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "deployer" {
  key_name   = "deployer-key"
  public_key = tls_private_key.key.public_key_openssh
}

resource "local_file" "private_key" {
  content         = tls_private_key.key.private_key_pem
  filename        = "${path.module}/deployer-key.pem"
  file_permission = "0600"
}

resource "aws_instance" "web" {
  ami                    = "ami-0c101f26f147fa7fd"
  instance_type          = var.instance_type
  vpc_security_group_ids = [aws_security_group.web.id]
  key_name               = aws_key_pair.deployer.key_name

  user_data = <<-EOF
              #!/bin/bash
              yum update -y
              yum install -y docker git
              
              systemctl start docker
              systemctl enable docker
              usermod -aG docker ec2-user

              cd /home/ec2-user
              git clone https://github.com/Jules-u/Workshop.git
              cd Workshop

              docker build -t workshop-app .
              
              docker run -d -p 80:80 --name workshop-container workshop-app
              EOF

  tags = {
    Name = var.instance_name
  }
}
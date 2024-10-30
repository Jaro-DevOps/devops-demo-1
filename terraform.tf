provider "aws" {
  region = "eu-central-1"
}

resource "aws_key_pair" "deployer" {
  key_name   = "yaro.ssh.pub"
  public_key = file("~/.ssh/yaro-ssh.pub")
}

resource "aws_security_group" "allow_web" {
  name_prefix = "flask_app_sg"

  ingress {
    from_port   = 5000
    to_port     = 5000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
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

resource "aws_instance" "flask_app" {
  ami           = "ami-0745b7d4092315796" #Ubuntu 22.04
  instance_type = "t2.micro"
  key_name      = aws_key_pair.deployer.key_name
  security_groups = [aws_security_group.allow_web.name]

  user_data = <<-EOF
              #!/bin/bash
              sudo apt update -y
              sudo apt install -y software-properties-common
              sudo add-apt-repository -y ppa:ansible/ansible
              sudo apt update -y
              sudo apt install -y ansible git
              git clone https://github.com/Jaro-DevOps/devops-demo-1 /home/ubuntu/app
              cd /home/ubuntu/app 
              ansible-playbook /home/ubuntu/app/playbook.yaml
              EOF

  tags = {
    Name = "FlaskAppInstance"
  }
}

output "public_ip" {
  value = aws_instance.flask_app.public_ip
}
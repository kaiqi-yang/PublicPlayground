provider "aws" {
  region  = "ap-southeast-2"
  profile = "saml"
}

resource "aws_key_pair" "terraform_demo" {
  key_name   = "terraform_demo"
  public_key = file("~/.ssh/id_rsa.pub")
}

resource "aws_instance" "my_instance" {
  vpc_security_group_ids = ["${aws_security_group.ingress_all_test.id}"]
  ami             = "ami-0ded330691a314693"
  instance_type   = "t2.micro"
  user_data       = <<EOF
		#! /bin/bash
        sudo apt-get update
		sudo apt-get install -y apache2
		sudo systemctl start apache2
		sudo systemctl enable apache2
		echo "<h1>Deployed via Terraform</h1>" | sudo tee /var/www/html/index.html
	EOF
    key_name = aws_key_pair.terraform_demo.key_name
  tags = {
    Name = "test backstage"
  }
}

resource "aws_security_group" "ingress_all_test" {
  name = "allow-all-ssh"
  ingress {
    cidr_blocks = [
      "0.0.0.0/0"
    ]
    from_port = 22
    to_port   = 22
    protocol  = "tcp"
  }
  // Terraform removes the default rule
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group_rule" "nginx_http_ingress" {
  type      = "ingress"
  from_port = 80
  to_port   = 80
  protocol  = "tcp"
  cidr_blocks = [
    "0.0.0.0/0"
  ]
  security_group_id = aws_security_group.ingress_all_test.id
}

resource "aws_security_group_rule" "nginx_https_ingress" {
  type      = "ingress"
  from_port = 443
  to_port   = 443
  protocol  = "tcp"
  cidr_blocks = [
    "0.0.0.0/0"
  ]
  security_group_id = aws_security_group.ingress_all_test.id
}

output "public_ip" {
    value = aws_instance.my_instance.public_ip
}


output "public_dns" {
    value = aws_instance.my_instance.public_dns
}
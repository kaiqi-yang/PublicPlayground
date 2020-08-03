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
  ami                    = "ami-0bc49f9283d686bab"
  instance_type          = "t2.small"
  user_data              = <<EOF
        #! /bin/bash
        ## download git
        sudo yum update -y
        sudo yum install git -y

        ## set up node
        curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.34.0/install.sh | bash
        . ~/.nvm/nvm.sh
        nvm install 12.0.0
        nvm use 12.0.0

        ## yarn
        curl -o- -L https://yarnpkg.com/install.sh | bash
        export PATH="$HOME/.yarn/bin:$HOME/.config/yarn/global/node_modules/.bin:$PATH"

        ## Clone repo
        git clone https://github.com/spotify/backstage.git

        ## start the app
        cd backstage/
        yarn install
        yarn start
	EOF
  key_name               = aws_key_pair.terraform_demo.key_name
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

resource "aws_security_group_rule" "nginx_port_ingress" {
  type      = "ingress"
  from_port = 3000
  to_port   = 3000
  protocol  = "tcp"
  cidr_blocks = [
    "0.0.0.0/0"
  ]
  security_group_id = aws_security_group.ingress_all_test.id
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
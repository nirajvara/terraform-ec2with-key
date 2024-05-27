
resource "aws_default_vpc" "default" {}

resource "aws_key_pair" "tf-key-pair" {
key_name = "tf-key-pair"
public_key = tls_private_key.rsa.public_key_openssh
}
resource "tls_private_key" "rsa" {
algorithm = "RSA"
rsa_bits  = 4096
}
resource "local_file" "tf-key" {
content  = tls_private_key.rsa.private_key_pem
filename = "tf-key-pair"
}

resource "aws_security_group" "example" {
  name        = "example-security-group"
  description = "Allow inbound traffic on port 22"
  
  vpc_id = aws_default_vpc.default.id   # Use the default VPC

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

resource "aws_instance" "example" {
  ami             = "ami-0c7217cdde317cfec"   # Set your desired AMI ID
  instance_type   = "t2.micro"       # Set your desired instance type
  key_name        = "tf-key-pair"
  security_groups = [aws_security_group.example.name]   # Attach the security group
  
  tags = {
    Name = "example-instance"
  }

  user_data = file("/home/niraj_vara/samplefiles_nginx-apache/odoo.sh")

}

resource "aws_eip" "example" {
  instance = aws_instance.example.id
}

output "ec2_global_ips" {
  value = ["${aws_instance.example.public_ip}"]
}

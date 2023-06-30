
# Define SSH key pair for our instances


resource "tls_private_key" "we45_ssh_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "ssh" {
  key_name   = format("ase_ssh_key-%s", random_string.suffix.result)
  public_key = tls_private_key.we45_ssh_key.public_key_openssh
}


resource "aws_iam_instance_profile" "customer_profile" {
  name       = "customer_profile_terraform"
  role       = aws_iam_role.customer_role.id
  depends_on = [aws_iam_role.customer_role]
}

data "aws_ami" "amz_linux" {
  most_recent = true
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-bionic-18.04-amd64-server-*"]
  }
  owners = ["099720109477"]
}


resource "aws_instance" "wb" {
  depends_on = [aws_iam_instance_profile.customer_profile]
  #us-east-1
  ami                         = data.aws_ami.amz_linux.id
  instance_type               = "t2.micro"
  iam_instance_profile        = aws_iam_instance_profile.customer_profile.name
  key_name                    = aws_key_pair.ssh.key_name
  vpc_security_group_ids      = [aws_security_group.customer-SG.id]
  subnet_id = aws_subnet.public-subnet1.id
  associate_public_ip_address = true
  user_data                   = file("script.sh")
  tags = {
    Name = "Customer Application"
  }
}

resource "local_file" "aws_key" {
  content  = tls_private_key.we45_ssh_key.private_key_pem
  filename = "ase_customer.pem"
}





#output the EC2 details
output "EC2publicDNS" {
  value = aws_instance.wb.public_dns
}

module "ec2_instance" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "~> 3.0"

  name = "bastion-host-${var.env}"

  ami                         = data.aws_ami.amazon_linux.id
  instance_type               = var.bastion_host_instance_type
  key_name                    = data.aws_key_pair.this.key_name
  associate_public_ip_address = true
  monitoring                  = true
  subnet_id                   = module.vpc.public_subnets[0]
  vpc_security_group_ids      = [aws_security_group.ssh_access.id]
}

resource "aws_security_group" "bastion_host_ssh_access" {
  name   = "bastion-host-${var.app_name}-ssh-access-${var.env}"
  vpc_id = module.vpc.vpc_id
  ingress {
    cidr_blocks = [
      "0.0.0.0/0"
    ]
    from_port = 22
    to_port   = 22
    protocol  = "tcp"
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

data "aws_ami" "amazon_linux" {
  most_recent = false
  filter {
    name   = "name"
    values = [var.bastion_host_ami]
  }
}


data "aws_key_pair" "this" {
  key_name           = var.bastion_host_key_pair_name
  include_public_key = true
}
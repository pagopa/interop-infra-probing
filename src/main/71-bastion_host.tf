module "ec2_instance" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "~> 3.0"

  name = "bastion-host-${var.env}"

  ami                         = data.aws_ami.amazon_linux.id
  instance_type               = "t3.micro"
  key_name                    = data.aws_key_pair.this.key_name
  associate_public_ip_address = true
  monitoring                  = true
  subnet_id                   = module.vpc.public_subnets[0]

}

data "aws_ami" "amazon_linux" {
  most_recent = false
  filter {
    name   = "name"
    values = ["amzn2-ami-kernel-5.10-hvm-2.0.20230207.0-x86_64-gp2"]
  }
}

data "aws_key_pair" "this" {
  key_name           = "interop-probing-bh-dev"
  include_public_key = true
}
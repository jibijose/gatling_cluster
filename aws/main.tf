terraform {
  required_version = ">= 0.12.18"
}

provider "aws" {
  region = var.location
}

data "aws_vpc" "default" {
  cidr_block = "${var.vpc_cidr}"
}

data "aws_subnet" "default" {
  vpc_id = "${data.aws_vpc.default.id}"
  cidr_block = "${var.subnet_cidr}"
}

data "aws_ami" "linux" {
  most_recent = true
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-bionic-18.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"]
}

resource "aws_key_pair" "kp" {
  key_name   = "gatling_cluster_key"
  public_key = file("./ssh_keys/id_rsa.pub")
}

resource "aws_security_group" "sg" {
    name        = "gatling-cluster-sg"
    description = "Gatling cluster security group"
    vpc_id = data.aws_vpc.default.id
    ingress {
      from_port = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = ["${var.my_public_ip}/32", "${var.subnet_cidr}"]
    }
    egress {
      from_port       = 0
      to_port         = 0
      protocol        = "-1"
      cidr_blocks     = ["0.0.0.0/0"]
    }
    tags = {
      environment = "gatling_test"
    }
}


resource "aws_instance" "vm" {
  count                 = var.vmcount
  ami       =  data.aws_ami.linux.id
  instance_type = var.vmsize
  security_groups = ["${aws_security_group.sg.id}"]
  subnet_id = data.aws_subnet.default.id
  key_name = aws_key_pair.kp.id

  tags = {
    environment = "gatling_test"
    Name = "gatling-cluster-${count.index}-vm"
  }
}

resource "null_resource" "vminit" {
  count                 = var.vmcount

  triggers = {
    public_ip = "${element(aws_instance.vm.*.public_ip, count.index)}"
  }

  connection {
    type = "ssh"
    host = element(aws_instance.vm.*.public_ip, count.index)
    user = "ubuntu"
    private_key = file("./ssh_keys/id_rsa")
    agent = false
  }

  provisioner "remote-exec" {
    inline = [
      "sudo apt update -qqqq",
      "sudo apt update -qqqq",
      "sudo apt install openjdk-8-jdk --yes -qqqq",
      "sudo apt install unzip --yes -qqqq"
    ]
  }

}
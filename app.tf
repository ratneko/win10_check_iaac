resource "aws_vpc" "vpc" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Project = "win10-check"
  }
}

resource "aws_subnet" "sub-a" {
  vpc_id = "${aws_vpc.vpc.id}"
  availability_zone = "us-east-1a"
  cidr_block = "10.0.0.0/24"

  tags = {
    Project = "win10-check"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = "${aws_vpc.vpc.id}"

  tags = {
    Project = "win10-check"
  }
}

resource "aws_route_table" "route-table" {
  vpc_id = "${aws_vpc.vpc.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.igw.id}"
  }

  tags = {
    Project = "win10-check"
  }
}

resource "aws_route_table_association" "assc-a" {
  subnet_id = "${aws_subnet.sub-a.id}"
  route_table_id = "${aws_route_table.route-table.id}"
}

resource "aws_security_group" "sg" {
    name = "win10-check-sg"
    vpc_id = "${aws_vpc.vpc.id}"
    ingress {
        from_port = 3389
        to_port = 3389
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    tags = {
    Project = "win10-check"
  }
}

resource "aws_instance" "staging-ec2" {
  ami = "ami-00cb4c0d60b9476f4"
  instance_type = "t3.nano"
  subnet_id = "${aws_subnet.sub-a.id}"
  key_name = "ratneko_dev_key_us1"
  vpc_security_group_ids = [
    "${aws_security_group.sg.id}"
  ]
  associate_public_ip_address = "true"

  root_block_device {
    volume_type = "gp2"
    volume_size = "30"
  }

  ebs_block_device {
    device_name = "/dev/sdf"
    volume_type = "gp2"
    volume_size = "30"
  }

  tags = {
    Project = "win10-check"
  }
}

provider "aws" {
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
  region     = "eu-central-1"
}


##creating node#########################################################################################################
#
#resource "aws_instance" "bastion" {
#  count                  = 1
#  ami                    = "ami-00399ec92321828f5"
#  instance_type          = "t2.micro"
#  key_name               = "undrey"
#  subnet_id              = "${aws_subnet.subnet-undrey-public.id}"
#  private_ip             = "10.0.1.10"
#  vpc_security_group_ids = [
#    aws_security_group.undrey_security_group.id
#  ]
#  tags = {
#    Name = "ansible"
#  }
#
#}


####Security Groups############################################################################################################


resource "aws_security_group" "bastion" {
  name        = "bastion"
  vpc_id      = "${aws_vpc.cloudx.id}"
  description = "allows access to bastion"
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [
      "0.0.0.0/0"
    ]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [
      "0.0.0.0/0"
    ]
  }
  tags = {
    Name = "bastion"
  }
}

resource "aws_security_group" "ec2_pool" {
  name        = "ec2_pool"
  vpc_id      = "${aws_vpc.cloudx.id}"
  description = "allows access to ec2 instances"
  ingress {
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.bastion.id]
  }
  ingress {
    from_port   = 2049
    to_port     = 2049
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.cloudx.cidr_block]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [
      "0.0.0.0/0"
    ]
  }
  tags = {
    Name = "ec2_pool"
  }
}

resource "aws_security_group_rule" "ec2_pool_rule" {
  from_port                = 2368
  protocol                 = "tcp"
  security_group_id        = aws_security_group.ec2_pool.id
  source_security_group_id = aws_security_group.alb.id
  to_port                  = 2368
  type                     = "ingress"
}


resource "aws_security_group" "alb" {
  name        = "alb"
  vpc_id      = "${aws_vpc.cloudx.id}"
  description = "allows access to alb"
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [
      "0.0.0.0/0"
    ]
  }

  tags = {
    Name = "alb"
  }
}

resource "aws_security_group_rule" "alb_pool_rule" {
  from_port                = "-1"
  protocol                 = "-1"
  security_group_id        = aws_security_group.alb.id
  source_security_group_id = aws_security_group.ec2_pool.id
  to_port                  = "-1"
  type                     = "egress"
}

resource "aws_security_group" "efs" {
  name        = "efs"
  vpc_id      = "${aws_vpc.cloudx.id}"
  description = "defines access to efs mount points"
  ingress {
    from_port       = 2049
    to_port         = 2049
    protocol        = "tcp"
    security_groups = [aws_security_group.ec2_pool.id]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [aws_vpc.cloudx.cidr_block]
  }
  tags = {
    Name = "efs"
  }
}


####VPC#############################################################################################################

resource "aws_vpc" "cloudx" {
  cidr_block           = "10.10.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags                 = {
    Name = "cloudx"
  }

}

resource "aws_subnet" "public_a" {
  vpc_id                  = "${aws_vpc.cloudx.id}"
  cidr_block              = "10.10.1.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "eu-central-1a"
  tags                    = {
    Name = "public_a"
  }
}

resource "aws_subnet" "public_b" {
  vpc_id                  = "${aws_vpc.cloudx.id}"
  cidr_block              = "10.10.2.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "eu-central-1b"
  tags                    = {
    Name = "public_b"
  }
}

resource "aws_subnet" "public_c" {
  vpc_id                  = "${aws_vpc.cloudx.id}"
  cidr_block              = "10.10.3.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "eu-central-1c"
  tags                    = {
    Name = "public_c"
  }
}

resource "aws_internet_gateway" "cloudx-igw" {
  vpc_id = "${aws_vpc.cloudx.id}"
  tags   = {
    Name = "cloudx-igw"
  }
}

resource "aws_route_table" "public_rt" {
  vpc_id = "${aws_vpc.cloudx.id}"
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.cloudx-igw.id}"
  }
  tags = {
    Name = "public_rt"
  }
}

resource "aws_route_table_association" "public_rt_subnet_a" {
  subnet_id      = "${aws_subnet.public_a.id}"
  route_table_id = "${aws_route_table.public_rt.id}"
}
resource "aws_route_table_association" "public_rt_subnet_b" {
  subnet_id      = "${aws_subnet.public_b.id}"
  route_table_id = "${aws_route_table.public_rt.id}"
}
resource "aws_route_table_association" "public_rt_subnet_c" {
  subnet_id      = "${aws_subnet.public_c.id}"
  route_table_id = "${aws_route_table.public_rt.id}"
}


#####iam################################################################################################################

#resource "aws_iam_role" "kube_control_plane_role" {
#  name = "kubernetes-undrey-master"
#
#  assume_role_policy = <<EOF
#{
#  "Version": "2012-10-17",
#  "Statement": [
#    {
#      "Effect": "Allow",
#      "Action": "sts:AssumeRole",
#      "Principal": {
#        "Service": "ec2.amazonaws.com"
#      }
#      }
#  ]
#}
#EOF
#}

#Add AWS Policies for Kubernetes



#####creating elb#################################


#resource "aws_security_group" "aws-elb" {
#  name   = "kubernetes-undrey-securitygroup-elb"
#  vpc_id = "${aws_vpc.vpc-undrey.id}"
#
#  tags = {
#    Name = "kubernetes-undrey-securitygroup-elb"
#  }
#}
#
#resource "aws_security_group_rule" "aws-allow-api-access" {
#  type              = "ingress"
#  from_port         = 6443
#  to_port           = 6443
#  protocol          = "TCP"
#  cidr_blocks       = ["0.0.0.0/0"]
#  security_group_id = aws_security_group.aws-elb.id
#}
#
#resource "aws_security_group_rule" "aws-allow-api-egress" {
#  type              = "egress"
#  from_port         = 0
#  to_port           = 65535
#  protocol          = "TCP"
#  cidr_blocks       = ["0.0.0.0/0"]
#  security_group_id = aws_security_group.aws-elb.id
#}
#
## Create a new AWS ELB for K8S API
#resource "aws_elb" "aws-elb-api" {
#  name            = "kubernetes-elb-undrey"
#  subnets         = aws_subnet.subnet-undrey-public.*.id
#  security_groups = [aws_security_group.aws-elb.id]
#
#  listener {
#    instance_port     = 6443
#    instance_protocol = "tcp"
#    lb_port           = 6443
#    lb_protocol       = "tcp"
#  }
#
#  health_check {
#    healthy_threshold   = 2
#    unhealthy_threshold = 2
#    timeout             = 3
#    target              = "HTTPS:6443/healthz"
#    interval            = 30
#  }
#
#  cross_zone_load_balancing   = true
#  idle_timeout                = 400
#  connection_draining         = true
#  connection_draining_timeout = 400
#
#  tags = {
#    Name = "kubernetes-undrey-elb-api"
#  }
#}
#
#resource "aws_elb_attachment" "attach_master_nodes" {
#  count    = 1
#  elb      = "${aws_elb.aws-elb-api.id}"
#  instance = "${aws_instance.node1[0].id}"
#}
#
#

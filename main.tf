provider "aws" {
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
  region     = "eu-central-1"
}


resource "aws_key_pair" "ghost-ec2-pool" {
  key_name   = "ghost-ec2-pool"
  public_key = var.aws_public_key
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


resource "aws_subnet" "private_db_a" {
  vpc_id                  = "${aws_vpc.cloudx.id}"
  cidr_block              = "10.10.20.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "eu-central-1a"
  tags                    = {
    Name = "private_db_a"
  }
}

resource "aws_subnet" "private_db_b" {
  vpc_id                  = "${aws_vpc.cloudx.id}"
  cidr_block              = "10.10.21.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "eu-central-1b"
  tags                    = {
    Name = "private_db_b"
  }
}

resource "aws_subnet" "private_db_c" {
  vpc_id                  = "${aws_vpc.cloudx.id}"
  cidr_block              = "10.10.22.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "eu-central-1c"
  tags                    = {
    Name = "private_db_c"
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

####Security Groups#####################################################################################################


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

resource "aws_security_group" "mysql" {
  name        = "mysql"
  vpc_id      = "${aws_vpc.cloudx.id}"
  description = "defines access to ghost db"
  ingress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.ec2_pool.id]
  }
  tags = {
    Name = "mysql"
  }
}


#####Role###############################################################################################################

resource "aws_iam_role" "ghost_app_role" {
  name = "ghost_app_role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      }
      }
  ]
}
EOF
}

resource "aws_iam_role_policy" "ghost_app_policy" {
  name = "ghost_app_policy"
  role = aws_iam_role.ghost_app_role.id

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": "ec2:Describe*",
      "Resource": ["*"]
    },
    {
      "Effect": "Allow",
      "Action": "elasticfilesystem:DescribeFileSystems",
      "Resource": ["*"]
    },
    {
      "Effect": "Allow",
      "Action": "elasticfilesystem:ClientMount",
      "Resource": ["*"]
    },
    {
      "Effect": "Allow",
      "Action": "elasticfilesystem:ClientWrite",
      "Resource": ["*"]
    }
  ]
}
EOF
}


resource "aws_iam_instance_profile" "ghost_app" {
  name = "ghost_app"
  role = aws_iam_role.ghost_app_role.name
}

#####EFS################################################################################################################
resource "aws_efs_file_system" "ghost_content" {
  tags = {
    Name = "ghost_content"
  }
}
resource "aws_efs_access_point" "efs_access_point" {
  file_system_id = aws_efs_file_system.ghost_content.id
}

#resource "aws_efs_file_system_policy" "policy" {
#  file_system_id = aws_efs_file_system.ghost_content.id
## The EFS System Policy allows clients to mount, read and perform
## write operations on File system
## The communication of client and EFS is set using aws:secureTransport Option
#  policy = <<POLICY
#{
#    "Version": "2012-10-17",
#    "Id": "Policy01",
#    "Statement": [
#        {
#            "Sid": "Statement",
#            "Effect": "Allow",
#            "Principal": {
#                "AWS": "*"
#            },
#            "Resource": "${aws_efs_file_system.ghost_content.arn}",
#            "Action": [
#                "elasticfilesystem:ClientMount",
#                "elasticfilesystem:ClientRootAccess",
#                "elasticfilesystem:ClientWrite"
#            ],
#            "Condition": {
#                "Bool": {
#                    "aws:SecureTransport": "false"
#                }
#            }
#        }
#    ]
#}
#POLICY
#}

resource "aws_efs_mount_target" "efs_mount_subnet_a" {
  file_system_id  = aws_efs_file_system.ghost_content.id
  subnet_id       = aws_subnet.public_a.id
  security_groups = [aws_security_group.efs.id]
}
resource "aws_efs_mount_target" "efs_mount_subnet_b" {
  file_system_id  = aws_efs_file_system.ghost_content.id
  subnet_id       = aws_subnet.public_b.id
  security_groups = [aws_security_group.efs.id]
}
resource "aws_efs_mount_target" "efs_mount_subnet_c" {
  file_system_id  = aws_efs_file_system.ghost_content.id
  subnet_id       = aws_subnet.public_c.id
  security_groups = [aws_security_group.efs.id]
}

#####creating alb#######################################################################################################

resource "aws_lb" "ghost_lb" {
  name               = "ghost-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb.id]
  subnets            = [aws_subnet.public_a.id, aws_subnet.public_b.id, aws_subnet.public_c.id]

}

resource "aws_lb_target_group" "ghost-ec2" {
  name     = "ghost-ec2"
  port     = 2368
  protocol = "HTTP"
  vpc_id   = aws_vpc.cloudx.id
}

resource "aws_lb_listener" "front_end" {
  load_balancer_arn = aws_lb.ghost_lb.arn
  port              = "80"
  default_action {
    type = "forward"
    forward {
      target_group {
        arn    = aws_lb_target_group.ghost-ec2.arn
        weight = 100
      }
    }
  }
}


#####creating template##################################################################################################
resource "aws_launch_template" "ghost" {
  name = "ghost"
  iam_instance_profile {
    name = aws_iam_instance_profile.ghost_app.name
  }
  image_id      = "ami-0e2031728ef69a466"
  instance_type = "t2.micro"
  key_name      = "ghost-ec2-pool"
  network_interfaces {
    #subnet_id       = aws_subnet.public_a.id
    security_groups = [aws_security_group.ec2_pool.id]
  }
  user_data = base64encode(templatefile("initial_script.tpl",
    {
      LB_DNS_NAME = "${aws_lb.ghost_lb.dns_name}"
    }
  ))

}

#####creating asg#######################################################################################################
resource "aws_autoscaling_group" "ghost_ec2_pool" {
  name                = "ghost_ec2_pool"
  vpc_zone_identifier = [aws_subnet.public_a.id, aws_subnet.public_b.id, aws_subnet.public_c.id]
  #availability_zones = [aws_subnet.public_a.availability_zone,aws_subnet.public_b.availability_zone,aws_subnet.public_c.availability_zone]
  desired_capacity    = 1
  max_size            = 1
  min_size            = 1
  target_group_arns   = [aws_lb_target_group.ghost-ec2.arn]
  launch_template {
    id      = aws_launch_template.ghost.id
    version = "$Latest"
  }
}

#####creating bastion###################################################################################################
resource "aws_instance" "bastion" {
  count                       = 1
  ami                         = "ami-0e2031728ef69a466"
  associate_public_ip_address = true
  instance_type               = "t2.micro"
  key_name                    = "ghost-ec2-pool"
  subnet_id                   = aws_subnet.public_a.id
  vpc_security_group_ids      = [
    aws_security_group.bastion.id
  ]
  iam_instance_profile = aws_iam_instance_profile.ghost_app.name
  tags                 = {
    Name = "bastion"
  }
}
#####creating rds#######################################################################################################
resource "aws_db_instance" "ghost" {
  allocated_storage    = 20
  db_name              = "ghost"
  engine               = "mysql"
  engine_version       = "8.0"
  instance_class       = "db.t2.micro"
  username             = "foo"
  password             = "foobarbaz"
  db_subnet_group_name = aws_db_subnet_group.ghost.name
  vpc_security_group_ids = [aws_security_group.mysql.id]
  skip_final_snapshot  = true
}

resource "aws_db_subnet_group" "ghost" {
  name        = "ghost"
  description = "ghost database subnet group"
  subnet_ids  = [aws_subnet.private_db_a.id, aws_subnet.private_db_b.id, aws_subnet.private_db_c.id]
  tags        = {
    Name = "ghost"
  }
}
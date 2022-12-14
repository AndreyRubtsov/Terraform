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
    Name    = "cloudx",
    Project = "CloudX"
  }

}

resource "aws_subnet" "public_a" {
  vpc_id                  = aws_vpc.cloudx.id
  cidr_block              = "10.10.1.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "eu-central-1a"
  tags                    = {
    Name    = "public_a",
    Project = "CloudX"
  }
}

resource "aws_subnet" "public_b" {
  vpc_id                  = aws_vpc.cloudx.id
  cidr_block              = "10.10.2.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "eu-central-1b"
  tags                    = {
    Name    = "public_b",
    Project = "CloudX"
  }
}

resource "aws_subnet" "public_c" {
  vpc_id                  = aws_vpc.cloudx.id
  cidr_block              = "10.10.3.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "eu-central-1c"
  tags                    = {
    Name    = "public_c",
    Project = "CloudX"
  }
}


resource "aws_subnet" "private_db_a" {
  vpc_id                  = aws_vpc.cloudx.id
  cidr_block              = "10.10.20.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "eu-central-1a"
  tags                    = {
    Name    = "private_db_a",
    Project = "CloudX"
  }
}

resource "aws_subnet" "private_db_b" {
  vpc_id                  = aws_vpc.cloudx.id
  cidr_block              = "10.10.21.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "eu-central-1b"
  tags                    = {
    Name    = "private_db_b",
    Project = "CloudX"
  }
}

resource "aws_subnet" "private_db_c" {
  vpc_id                  = aws_vpc.cloudx.id
  cidr_block              = "10.10.22.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "eu-central-1c"
  tags                    = {
    Name    = "private_db_c",
    Project = "CloudX"
  }
}

resource "aws_subnet" "private_a" {
  vpc_id                  = aws_vpc.cloudx.id
  cidr_block              = "10.10.10.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "eu-central-1a"
  tags                    = {
    Name    = "private_a",
    Project = "CloudX"
  }
}
resource "aws_subnet" "private_b" {
  vpc_id                  = aws_vpc.cloudx.id
  cidr_block              = "10.10.11.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "eu-central-1b"
  tags                    = {
    Name    = "private_b",
    Project = "CloudX"
  }
}
resource "aws_subnet" "private_c" {
  vpc_id                  = aws_vpc.cloudx.id
  cidr_block              = "10.10.12.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "eu-central-1c"
  tags                    = {
    Name    = "private_c",
    Project = "CloudX"
  }
}


resource "aws_internet_gateway" "cloudx-igw" {
  vpc_id = aws_vpc.cloudx.id
  tags   = {
    Name    = "cloudx-igw",
    Project = "CloudX"
  }
}

resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.cloudx.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.cloudx-igw.id
  }
  tags = {
    Name    = "public_rt",
    Project = "CloudX"
  }
}

resource "aws_route_table_association" "public_rt_subnet_a" {
  subnet_id      = aws_subnet.public_a.id
  route_table_id = aws_route_table.public_rt.id
}
resource "aws_route_table_association" "public_rt_subnet_b" {
  subnet_id      = aws_subnet.public_b.id
  route_table_id = aws_route_table.public_rt.id
}
resource "aws_route_table_association" "public_rt_subnet_c" {
  subnet_id      = aws_subnet.public_c.id
  route_table_id = aws_route_table.public_rt.id
}


resource "aws_route_table" "private_rt" {
  vpc_id = aws_vpc.cloudx.id
  tags   = {
    Name    = "private_rt",
    Project = "CloudX"
  }
}
resource "aws_route_table_association" "private_rt_subnet_a" {
  subnet_id      = aws_subnet.private_a.id
  route_table_id = aws_route_table.private_rt.id
}

resource "aws_route_table_association" "private_rt_subnet_b" {
  subnet_id      = aws_subnet.private_b.id
  route_table_id = aws_route_table.private_rt.id
}
resource "aws_route_table_association" "private_rt_subnet_c" {
  subnet_id      = aws_subnet.private_c.id
  route_table_id = aws_route_table.private_rt.id
}
resource "aws_route_table_association" "private_rt_db_subnet_a" {
  subnet_id      = aws_subnet.private_db_a.id
  route_table_id = aws_route_table.private_rt.id
}
resource "aws_route_table_association" "private_rt_db_subnet_b" {
  subnet_id      = aws_subnet.private_db_b.id
  route_table_id = aws_route_table.private_rt.id
}
resource "aws_route_table_association" "private_rt_db_subnet_c" {
  subnet_id      = aws_subnet.private_db_c.id
  route_table_id = aws_route_table.private_rt.id
}
####Security Groups#####################################################################################################


resource "aws_security_group" "bastion" {
  name        = "bastion"
  vpc_id      = aws_vpc.cloudx.id
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
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name    = "bastion",
    Project = "CloudX"
  }
}

resource "aws_security_group" "ec2_pool" {
  name        = "ec2_pool"
  vpc_id      = aws_vpc.cloudx.id
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
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name    = "ec2_pool",
    Project = "CloudX"
  }
}

resource "aws_security_group_rule" "ec2_pool_rule" {
  from_port                = 2368
  to_port                  = 2368
  protocol                 = "tcp"
  security_group_id        = aws_security_group.ec2_pool.id
  source_security_group_id = aws_security_group.alb.id
  type                     = "ingress"
}


resource "aws_security_group" "alb" {
  name        = "alb"
  vpc_id      = aws_vpc.cloudx.id
  description = "allows access to alb"
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name    = "alb",
    Project = "CloudX"
  }
}

resource "aws_security_group_rule" "alb_pool_rule1" {
  from_port                = "-1"
  protocol                 = "-1"
  security_group_id        = aws_security_group.alb.id
  source_security_group_id = aws_security_group.ec2_pool.id
  to_port                  = "-1"
  type                     = "egress"
}

resource "aws_security_group_rule" "alb_pool_rule2" {
  from_port                = "-1"
  protocol                 = "-1"
  security_group_id        = aws_security_group.alb.id
  source_security_group_id = aws_security_group.fargate_pool.id
  to_port                  = "-1"
  type                     = "egress"
}


resource "aws_security_group" "efs" {
  name        = "efs"
  vpc_id      = aws_vpc.cloudx.id
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
    Name    = "efs",
    Project = "CloudX"
  }
}

resource "aws_security_group_rule" "efs_pool_rule" {
  from_port                = "2049"
  to_port                  = "2049"
  protocol                 = "tcp"
  security_group_id        = aws_security_group.efs.id
  source_security_group_id = aws_security_group.fargate_pool.id
  type                     = "ingress"
}

resource "aws_security_group" "mysql" {
  name        = "mysql"
  vpc_id      = aws_vpc.cloudx.id
  description = "defines access to ghost db"
  ingress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.ec2_pool.id]
  }
  ingress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.fargate_pool.id]
  }
  tags = {
    Name    = "mysql",
    Project = "CloudX"
  }
}

resource "aws_security_group" "fargate_pool" {
  name        = "fargate_pool"
  vpc_id      = aws_vpc.cloudx.id
  description = "Allows access for Fargate instances"
  ingress {
    from_port       = 2049
    to_port         = 2049
    protocol        = "tcp"
    security_groups = [aws_security_group.efs.id]
  }
  ingress {
    from_port       = 2368
    to_port         = 2368
    protocol        = "tcp"
    security_groups = [aws_security_group.alb.id]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name    = "fargate_pool",
    Project = "CloudX"
  }
}

resource "aws_security_group" "vpc_endpoint" {
  name        = "vpc_endpoint"
  vpc_id      = aws_vpc.cloudx.id
  description = "allows access to vpc endpoints"
  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name    = "vpc_endpoint",
    Project = "CloudX"
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
      "Action": [
                "ec2:Describe*",
                "elasticfilesystem:DescribeFileSystems",
                "elasticfilesystem:ClientMount",
                "ssm:GetParameter*",
                "secretsmanager:GetSecretValue",
                "kms:Decrypt",
                "elasticfilesystem:ClientWrite"
      ],
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


resource "aws_iam_role" "ghost_ecs_role" {
  name = "ghost_ecs_role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": [
        "ecs.amazonaws.com",
        "ecs-tasks.amazonaws.com"
        ]
      }
      }
  ]
}
EOF
}

resource "aws_iam_role_policy" "ghost_ecs_policy" {
  name = "ghost_ecs_policy"
  role = aws_iam_role.ghost_ecs_role.id

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
            "Action": [
                "ecr:GetAuthorizationToken",
                "ecr:BatchCheckLayerAvailability",
                "ecr:GetDownloadUrlForLayer",
                "ecr:BatchGetImage",
                "elasticfilesystem:DescribeFileSystems",
                "elasticfilesystem:ClientMount",
                "elasticfilesystem:ClientWrite",
                "logs:CreateLogStream",
                "logs:PutLogEvents"
            ],
      "Resource": ["*"]
    }
  ]
}
EOF
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
resource "aws_lb_target_group" "ghost-fargate" {
  name        = "ghost-fargate"
  port        = 2368
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = aws_vpc.cloudx.id
}


resource "aws_lb_listener" "front_end" {
  load_balancer_arn = aws_lb.ghost_lb.arn
  port              = "80"
  default_action {
    type = "forward"
    forward {
      target_group {
        arn    = aws_lb_target_group.ghost-ec2.arn
        weight = 50
      }
      target_group {
        arn    = aws_lb_target_group.ghost-fargate.arn
        weight = 50
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
    security_groups = [aws_security_group.ec2_pool.id]
  }
  user_data = base64encode(templatefile("initial_script.tpl",
    {
      LB_DNS_NAME = aws_lb.ghost_lb.dns_name
      DB_URL      = aws_db_instance.ghost.address
      DB_USER     = var.db_user
      DB_NAME     = var.db_name
    }
  ))

}

#####creating asg#######################################################################################################
resource "aws_autoscaling_group" "ghost_ec2_pool" {
  name                = "ghost_ec2_pool"
  vpc_zone_identifier = [aws_subnet.public_a.id, aws_subnet.public_b.id, aws_subnet.public_c.id]
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
  allocated_storage      = 20
  db_name                = var.db_name
  engine                 = "mysql"
  engine_version         = "8.0"
  instance_class         = "db.t2.micro"
  username               = var.db_user
  password               = var.db_password
  db_subnet_group_name   = aws_db_subnet_group.ghost.name
  vpc_security_group_ids = [aws_security_group.mysql.id]
  skip_final_snapshot    = true
}

resource "aws_db_subnet_group" "ghost" {
  name        = "ghost"
  description = "ghost database subnet group"
  subnet_ids  = [aws_subnet.private_db_a.id, aws_subnet.private_db_b.id, aws_subnet.private_db_c.id]
  tags        = {
    Name = "ghost"
  }
}
#####creating ssm parameter store#######################################################################################
resource "aws_ssm_parameter" "dbsecret" {
  name        = "/ghost/dbpassw"
  description = "Password for mysql"
  type        = "SecureString"
  value       = var.db_password
}

#####creating ECR#######################################################################################################
#resource "aws_ecr_repository" "ghost" {
#  name = "ghost"
#  image_scanning_configuration {
#    scan_on_push = false
#  }
#}
#####creating VPC Endpoint##############################################################################################

resource "aws_vpc_endpoint" "s3" {
  vpc_id          = aws_vpc.cloudx.id
  service_name    = "com.amazonaws.eu-central-1.s3"
  route_table_ids = [aws_route_table.private_rt.id]
  tags            = {
    Name = "s3g"
  }
}
resource "aws_vpc_endpoint" "s3i" {
  vpc_id             = aws_vpc.cloudx.id
  service_name       = "com.amazonaws.eu-central-1.s3"
  vpc_endpoint_type  = "Interface"
  subnet_ids         = [aws_subnet.private_a.id, aws_subnet.private_b.id, aws_subnet.private_c.id]
  security_group_ids = [
    aws_security_group.vpc_endpoint.id,
  ]
  tags = {
    Name = "s3i"
  }
}
resource "aws_vpc_endpoint" "ssm" {
  vpc_id             = aws_vpc.cloudx.id
  service_name       = "com.amazonaws.eu-central-1.ssm"
  vpc_endpoint_type  = "Interface"
  subnet_ids         = [aws_subnet.private_a.id, aws_subnet.private_b.id, aws_subnet.private_c.id]
  security_group_ids = [
    aws_security_group.vpc_endpoint.id,
  ]
  tags = {
    Name = "ssm"
  }
  private_dns_enabled = true
}
resource "aws_vpc_endpoint" "ecr" {
  vpc_id             = aws_vpc.cloudx.id
  service_name       = "com.amazonaws.eu-central-1.ecr.api"
  vpc_endpoint_type  = "Interface"
  subnet_ids         = [aws_subnet.private_a.id, aws_subnet.private_b.id, aws_subnet.private_c.id]
  security_group_ids = [
    aws_security_group.vpc_endpoint.id,
  ]
  tags = {
    Name = "ecr"
  }
  private_dns_enabled = true
}
resource "aws_vpc_endpoint" "ecrd" {
  vpc_id             = aws_vpc.cloudx.id
  service_name       = "com.amazonaws.eu-central-1.ecr.dkr"
  vpc_endpoint_type  = "Interface"
  subnet_ids         = [aws_subnet.private_a.id, aws_subnet.private_b.id, aws_subnet.private_c.id]
  security_group_ids = [
    aws_security_group.vpc_endpoint.id,
  ]
  tags = {
    Name = "ecrd"
  }
  private_dns_enabled = true
}
resource "aws_vpc_endpoint" "efs" {
  vpc_id             = aws_vpc.cloudx.id
  service_name       = "com.amazonaws.eu-central-1.elasticfilesystem"
  vpc_endpoint_type  = "Interface"
  subnet_ids         = [aws_subnet.private_a.id, aws_subnet.private_b.id, aws_subnet.private_c.id]
  security_group_ids = [
    aws_security_group.vpc_endpoint.id,
  ]
  tags = {
    Name = "efs"
  }
  private_dns_enabled = true
}
resource "aws_vpc_endpoint" "efsf" {
  vpc_id             = aws_vpc.cloudx.id
  service_name       = "com.amazonaws.eu-central-1.elasticfilesystem-fips"
  vpc_endpoint_type  = "Interface"
  subnet_ids         = [aws_subnet.private_a.id, aws_subnet.private_b.id, aws_subnet.private_c.id]
  security_group_ids = [
    aws_security_group.vpc_endpoint.id,
  ]
  tags = {
    Name = "efsf"
  }
  private_dns_enabled = true
}
resource "aws_vpc_endpoint" "logs" {
  vpc_id             = aws_vpc.cloudx.id
  service_name       = "com.amazonaws.eu-central-1.logs"
  vpc_endpoint_type  = "Interface"
  subnet_ids         = [aws_subnet.private_a.id, aws_subnet.private_b.id, aws_subnet.private_c.id]
  security_group_ids = [
    aws_security_group.vpc_endpoint.id,
  ]
  tags = {
    Name = "cw logs"
  }
  private_dns_enabled = true
}

#####creating ECS#######################################################################################################
resource "aws_ecs_cluster" "ghost" {
  name = "ghost"
  setting {
    name  = "containerInsights"
    value = "enabled"
  }
}

resource "aws_ecs_task_definition" "task_def_ghost" {
  family                   = "task_def_ghost"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = 256
  memory                   = 1024
  task_role_arn            = aws_iam_role.ghost_ecs_role.arn
  execution_role_arn       = aws_iam_role.ghost_ecs_role.arn

  container_definitions = <<TASK_DEFINITION
[
    {
    "name": "ghost_container",
    "image": "${var.ecr_image}",
    "essential": true,
    "environment": [
        { "name" : "database__client", "value" : "mysql"},
        { "name" : "database__connection__host", "value" : "${aws_db_instance.ghost.address}"},
        { "name" : "database__connection__user", "value" : "${var.db_user}"},
        { "name" : "database__connection__password", "value" : "${var.db_password}"},
        { "name" : "database__connection__database", "value" : "${var.db_name}"}
    ],
    "mountPoints": [
        {
            "containerPath": "/var/lib/ghost/content",
            "sourceVolume": "ghost_volume"
        }
    ],
    "portMappings": [
        {
        "containerPort": 2368,
        "hostPort": 2368
        }
    ]
    }
]
TASK_DEFINITION
  volume {
    name = "ghost_volume"
    efs_volume_configuration {
      file_system_id     = aws_efs_file_system.ghost_content.id
      root_directory     = "/"
      transit_encryption = "ENABLED"
      authorization_config {
        access_point_id = aws_efs_access_point.efs_access_point.id
      }
    }
  }

}

resource "aws_ecs_service" "ghost" {
  name            = "ghost"
  cluster         = aws_ecs_cluster.ghost.id
  task_definition = aws_ecs_task_definition.task_def_ghost.arn
  launch_type     = "FARGATE"
  desired_count   = 1
  load_balancer {
    target_group_arn = aws_lb_target_group.ghost-fargate.arn
    container_name   = "ghost_container"
    container_port   = 2368
  }
  network_configuration {
    assign_public_ip = false
    subnets          = [aws_subnet.private_a.id, aws_subnet.private_b.id, aws_subnet.private_c.id]
    security_groups  = [aws_security_group.fargate_pool.id]
  }
}
#####creating cloudwatch dashboards#####################################################################################
resource "aws_cloudwatch_dashboard" "dashboard" {
  dashboard_name = "undrey-dashboard"

  dashboard_body = <<EOF
{
  "widgets": [
    {
      "type": "metric",
      "x": 6,
      "y": 0,
      "width": 12,
      "height": 6,
      "properties": {
        "metrics": [
          [
            "AWS/EC2",
            "CPUUtilization",
            "AutoScalingGroupName",
            "${aws_autoscaling_group.ghost_ec2_pool.id}"
          ]
        ],
        "period": 300,
        "stat": "Average",
        "region": "eu-central-1",
        "title": "EC2 Average CPU Utilization"
      }
    },
    {
      "type": "metric",
      "x": 0,
      "y": 7,
      "width": 12,
      "height": 6,
      "properties": {
        "metrics": [
          [
            "AWS/ECS",
            "CPUUtilization",
            "ClusterName",
            "${aws_ecs_cluster.ghost.name}",
            "ServiceName",
            "${aws_ecs_service.ghost.name}"
          ]
        ],
        "period": 60,
        "stat": "Average",
        "region": "eu-central-1",
        "title": "ECS Service CPU Utilization"
      }
    },
    {
      "type": "metric",
      "x": 14,
      "y": 7,
      "width": 12,
      "height": 6,
      "properties": {
        "metrics": [
          [
            "AWS/ECS",
            "CPUUtilization",
            "ClusterName",
            "${aws_ecs_cluster.ghost.name}",
            "ServiceName",
            "${aws_ecs_service.ghost.name}"
          ]
        ],
        "period": 60,
        "stat": "SampleCount",
        "region": "eu-central-1",
        "title": "ECS Running Tasks Count"
      }
    },
    {
      "type": "metric",
      "x": 0,
      "y": 14,
      "width": 12,
      "height": 6,
      "properties": {
        "metrics": [
          [
            "AWS/EFS",
            "StorageBytes",
            "StorageClass",
            "Total",
            "FileSystemId",
            "${aws_efs_file_system.ghost_content.id}"
          ]
        ],
        "period": 60,
        "stat": "Average",
        "region": "eu-central-1",
        "title": "EFS Storage Bytes in Mb"
      }
    },
    {
      "type": "metric",
      "x": 14,
      "y": 14,
      "width": 12,
      "height": 6,
      "properties": {
        "metrics": [
          [
            "AWS/EFS",
            "ClientConnections",
            "FileSystemId",
            "${aws_efs_file_system.ghost_content.id}"
          ]
        ],
        "period": 60,
        "stat": "Average",
        "region": "eu-central-1",
        "title": "EFS Client connections"
      }
    },
    {
      "type": "metric",
      "x": 0,
      "y": 21,
      "width": 12,
      "height": 6,
      "properties": {
        "metrics": [
          [
            "AWS/RDS",
            "CPUUtilization",
            "DBInstanceIdentifier",
            "${aws_db_instance.ghost.id}"
          ]
        ],
        "period": 60,
        "stat": "Average",
        "region": "eu-central-1",
        "title": "RDS CPU Utilization"
      }
    },
    {
      "type": "metric",
      "x": 14,
      "y": 21,
      "width": 12,
      "height": 6,
      "properties": {
        "metrics": [
          [
            "AWS/RDS",
            "DatabaseConnections",
            "DBInstanceIdentifier",
            "${aws_db_instance.ghost.id}"
          ]
        ],
        "period": 60,
        "stat": "Average",
        "region": "eu-central-1",
        "title": "RDS DB connections"
      }
    },
    {
      "type": "metric",
      "x": 0,
      "y": 28,
      "width": 12,
      "height": 6,
      "properties": {
        "metrics": [
          [
            "AWS/RDS",
            "WriteIOPS",
            "DBInstanceIdentifier",
            "${aws_db_instance.ghost.id}"
          ]
        ],
        "period": 60,
        "stat": "Average",
        "region": "eu-central-1",
        "title": "RDS Storage Read/Write IOPS"
      }
    },
    {
      "type": "metric",
      "x": 14,
      "y": 28,
      "width": 12,
      "height": 6,
      "properties": {
        "metrics": [
          [
            "AWS/RDS",
            "ReadIOPS",
            "DBInstanceIdentifier",
            "${aws_db_instance.ghost.id}"
          ]
        ],
        "period": 60,
        "stat": "Average",
        "region": "eu-central-1",
        "title": "RDS Storage Read/Write IOPS"
      }
    }
  ]
}
EOF
}
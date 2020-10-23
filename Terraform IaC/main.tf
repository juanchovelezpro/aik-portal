provider "aws" {
  region = "us-east-2"

}

#VPC AIK
resource "aws_vpc" "aik-vpc" {
  cidr_block = var.vpc_cidr

  tags = {
    Name = "automatizacion-est1-vpc"
  }
}

#IGW
resource "aws_internet_gateway" "aik-igw" {
  vpc_id = aws_vpc.aik-vpc.id
}

# Create an ElasticIP
resource "aws_eip" "nat-eip" {
  vpc = true

  tags = {
    Name = "IP for NAT gateway"
  }
}


# Create NAT
resource "aws_nat_gateway" "aik-nat" {

  allocation_id = aws_eip.nat-eip.id
  subnet_id     = aws_subnet.aik-subnet-public1.id
  depends_on    = [aws_internet_gateway.aik-igw]
}



#Create public route table

resource "aws_route_table" "rtb-public" {
  vpc_id = aws_vpc.aik-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.aik-igw.id
  }

  tags = {
    Name = "automatizacion-est1-public"
  }
}

resource "aws_route_table" "rtb-private" {

  vpc_id = aws_vpc.aik-vpc.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.aik-nat.id
  }

  tags = {
    Name = "PrivateRoute"
  }
}

#Create and associate public subnets with a route table

resource "aws_subnet" "aik-subnet-public1" {

  vpc_id                  = aws_vpc.aik-vpc.id
  cidr_block              = cidrsubnet(var.vpc_cidr, 8, 1)
  availability_zone       = element(split(",", var.aws_availability_zones), 0)
  map_public_ip_on_launch = true

  tags = {
    Name = "automatizacion-est1-subPublic1"
  }
}

resource "aws_subnet" "aik-subnet-public2" {

  vpc_id                  = aws_vpc.aik-vpc.id
  cidr_block              = cidrsubnet(var.vpc_cidr, 8, 3)
  availability_zone       = element(split(",", var.aws_availability_zones), 1)
  map_public_ip_on_launch = true

  tags = {
    Name = "automatizacion-est1-subPublic2"
  }
}

# Create and associate private subnets with a route table
resource "aws_subnet" "private" {

  vpc_id            = aws_vpc.aik-vpc.id
  cidr_block        = cidrsubnet(var.vpc_cidr, 8, 3)
  availability_zone = element(split(",", var.aws_availability_zones), 2)

  tags = {
    Name = "automatizacion-est1-private"
  }
}

resource "aws_route_table_association" "private" {
  subnet_id      = aws_subnet.private.id
  route_table_id = aws_route_table.rtb-private.id
}

resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.aik-subnet-public1.id
  route_table_id = aws_route_table.rtb-public.id
}
resource "aws_route_table_association" "public2" {
  subnet_id      = aws_subnet.aik-subnet-public2.id
  route_table_id = aws_route_table.rtb-public.id
}

resource "aws_security_group" "aik-sg-portal" {

  name        = "portal"
  description = "Sg for allow traffic to portal"
  vpc_id      = "${aws_vpc.aik-vpc.id}"

  ingress {
    from_port   = "3030"
    to_port     = "3030"
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = "22"
    to_port     = "22"
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

resource "aws_autoscaling_group" "aik_autoscaling" {
  launch_configuration = aws_launch_configuration.aik-lcfg.name
  min_size             = 2
  max_size             = 3
  vpc_zone_identifier  = [aws_subnet.aik-subnet-public1.id, aws_subnet.aik-subnet-public2.id]
  target_group_arns    = [aws_lb_target_group.asg.arn]

  tag {

    key                 = "Name"
    value               = "aik-asg1"
    propagate_at_launch = true

  }

}

resource "aws_launch_configuration" "aik-lcfg" {
  name            = "placeholder_launch_config1"
  image_id        = var.aik_ami_id
  instance_type   = var.aik_instance_type
  security_groups = [aws_security_group.aik-sg-portal.id]
  key_name        = var.aik_key_name
  user_data       = <<EOF
        #!/bin/bash
        sudo yum install -y git 
        #Clone salt repo
        git clone https://github.com/juanchovelezpro/aik-portal /app/
        sudo chmod -R 777 /app/
        curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.34.0/install.sh | bash
        . ~/.nvm/nvm.sh
        export NVM_DIR="$HOME/.nvm"
        nvm install node
        cd /app/aik-app-ui
        npm install
        node server.js
        #Install Node
        EOF
}


# Bucket S3 to save artifacts 

resource "aws_s3_bucket" "bucket-aik-artifacts" {
  bucket = "aik-app-artifacts"
  acl    = "private"
  force_destroy = true
  tags = {
    Name        = "Bucket Artifacts"
  }
}

resource "aws_s3_bucket" "bucket-aik-files" {
  bucket = "aik-app-files"
  acl    = "private"
  force_destroy = true
  tags = {
    Name        = "Bucket Files"
  }
}

/**
* ### Create Database RDS to save data ###
*/


 resource "aws_db_instance" "aik-rds" {
   allocated_storage    = 20
   storage_type         = "gp2"
   engine               = "mysql"
   engine_version       = "5.7"
   instance_class       = "db.t2.micro"
   name                 = "aik-database"
   username             = var.db_username
   password             = var.db_password
   parameter_group_name = "default.mysql5.7"
}



#Create Application Load Balancer
resource "aws_security_group" "sg_lb" {

  name   = var.alb_security_group_name
  vpc_id = aws_vpc.aik-vpc.id

  # Allow inbound HTTP requests
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow all outbound requests
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_lb" "aik_lb" {

  name               = var.alb_name
  load_balancer_type = "application"
  subnets            = [aws_subnet.aik-subnet-public1.id, aws_subnet.aik-subnet-public2.id]
  security_groups    = ["${aws_security_group.sg_lb.id}"]

}

resource "aws_lb_listener" "http" {

  load_balancer_arn = aws_lb.aik_lb.arn
  port              = 80
  protocol          = "HTTP"


  default_action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/plain"
      message_body = "404: page not found"
      status_code  = 404
    }
  }
}

resource "aws_lb_listener_rule" "asg" {
  listener_arn = aws_lb_listener.http.arn
  priority     = 100

  condition {
    path_pattern {
      values = ["*"]
    }

  }

  action {
    type             = "forward"
    target_group_arn = "${aws_lb_target_group.asg.arn}"
  }

}

resource "aws_lb_target_group" "asg" {

  name     = var.alb_name
  port     = "${var.server_port}"
  protocol = "HTTP"
  vpc_id   = "${aws_vpc.aik-vpc.id}"

  health_check {
    path                = "/"
    protocol            = "HTTP"
    matcher             = "200"
    interval            = 15
    timeout             = 3
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }

}

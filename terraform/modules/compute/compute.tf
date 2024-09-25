resource "aws_security_group" "sg_elb" {
  name   = "sg_elb"
  vpc_id = var.vpc_id_imput_compute
    egress { 
        from_port   = var.egress_from_port_elb
        to_port     = var.egress_to_port_elb
        protocol    = var.egress_protocol_elb
        cidr_blocks = var.egress_cidr_blocks_elb       
    }
    ingress {
        from_port   = var.ingress_from_port_elb
        to_port     = var.ingress_to_port_elb
        protocol    = var.ingress_protocol_elb
        cidr_blocks = var.ingress_cidr_blocks_elb
    }
}

resource "aws_security_group" "sg_ec2" {
    vpc_id = var.vpc_id_imput_compute
    egress {
        from_port   = var.egress_from_port_ec2
        to_port     = var.egress_to_port_ec2
        protocol    = var.egress_protocol_ec2
        cidr_blocks = var.egress_cidr_blocks_ec2
    }
    ingress {
        from_port   = var.ingress_from_port_ec2
        to_port     = var.ingress_to_port_ec2
        protocol    = var.ingress_protocol_ec2
        cidr_blocks = var.ingress_cidr_blocks_ec2
    }
}

resource "aws_lb_target_group" "tg-ec2-elb" {
  name     = "tg-ec2-elb"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id_imput_compute
}

resource "aws_lb" "ec2-elb" {
  name               = "ec2-elb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.sg_elb.id]
  subnets            = [var.sn-priv-az1a_id_imput_compute, var.sn-priv-az1c_id_imput_compute]
}

resource "aws_lb_listener" "elb_listener" {
  load_balancer_arn = aws_lb.ec2-elb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg-ec2-elb.arn
  }
}

data "template_file" "userdata" {
  template = file("./modules/compute/scripts/userdata.sh")
}


resource "aws_launch_template" "ec2-launch-template" {
  name_prefix   = "app-dynamicsite"
  image_id      = "ami-02e136e904f3da870"
  instance_type = "t2.micro"
  key_name      = "vockey"
  vpc_security_group_ids =  [aws_security_group.sg_ec2.id]
  user_data = base64encode(data.template_file.userdata.rendered)
}

resource "aws_autoscaling_group" "ec2-asg" {
  desired_capacity     = 4
  max_size             = 8
  min_size             = 2
  launch_template {
    id = aws_launch_template.ec2-launch-template.id
    version = "$Latest"
  }
  target_group_arns = [aws_lb_target_group.tg-ec2-elb.arn]
  vpc_zone_identifier = [var.sn-priv-az1a_id_imput_compute, var.sn-priv-az1c_id_imput_compute]
}



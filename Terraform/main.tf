
resource "aws_security_group" "database_sg" {
  name   = "${var.project_name}-${var.project_environment}-databaseSG"
  vpc_id = data.aws_vpc.default_vpc.id
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    "Name" = "${var.project_name}-${var.project_environment}-databaseSG"
  }

}

resource "aws_security_group" "app_sg" {
  name   = "${var.project_name}-${var.project_environment}-appSG"
  vpc_id = data.aws_vpc.default_vpc.id
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    "Name" = "${var.project_name}-${var.project_environment}-appSG"
  }

}

locals {
  sg_map = {
    "app" = aws_security_group.app_sg.id
    "db"  = aws_security_group.database_sg.id
  }
}

resource "aws_security_group_rule" "ingress_rule_ssh" {
  for_each = local.sg_map

  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = each.value
  description       = "Allow SSH to ${each.key} SG"
}

resource "aws_security_group_rule" "DB-ingress-rule" {
  type              = "ingress"
  from_port         = 3306
  to_port           = 3306
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.database_sg.id
}

resource "aws_security_group_rule" "app-ingress-rule" {
  type              = "ingress"
  from_port         = 8081
  to_port           = 8081
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.app_sg.id
}

resource "aws_instance" "db_server" {
  ami                    = var.ami_id
  key_name               = "bastion"
  instance_type          = var.instance_type
  vpc_security_group_ids = [aws_security_group.database_sg.id]
  user_data              = file("db_userdata.sh")

  tags = {
    "Name" = "${var.project_name}-${var.project_environment}-dbserver"
  }
}

resource "aws_instance" "nodejsapp" {
  ami                    = var.ami_id
  key_name               = "bastion"
  instance_type          = var.instance_type
  vpc_security_group_ids = [aws_security_group.app_sg.id]
  user_data              = file("node_app_userdata.sh")

  tags = {
    "Name" = "${var.project_name}-${var.project_environment}-webserver"
  }
}

resource "aws_route53_record" "db_record" {
  zone_id = data.aws_route53_zone.my_domain.zone_id
  name    = "dbinstance.${var.domain_name}"
  type    = "A"
  ttl     = 300
  records = [aws_instance.db_server.private_ip]
}

resource "aws_route53_record" "app-url" {
  zone_id = data.aws_route53_zone.my_domain.zone_id
  name    = "${var.project_name}.${var.domain_name}"
  type    = "A"
  ttl     = 300
  records = [aws_instance.nodejsapp.public_ip]
}
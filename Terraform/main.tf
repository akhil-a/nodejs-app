resource "aws_instance" "db_server" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  vpc_security_group_ids = ["sg-07de75b80af3dc8fa"]
  user_data              = file("db_userdata.sh")

  tags = {
    "Name" = "${var.project_name}-${var.project_environment}-dbserver"
  }
}


resource "aws_instance" "nodejsapp" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  vpc_security_group_ids = ["sg-07de75b80af3dc8fa"]
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
  records = [aws_instance.db_server.public_ip]
}

resource "aws_route53_record" "app-url" {
  zone_id = data.aws_route53_zone.my_domain.zone_id
  name    = "${var.project_name}.${var.domain_name}"
  type    = "A"
  ttl     = 300
  records = [aws_instance.nodejsapp.public_ip]
}


output "App_URL" {
  value = "http://${var.project_name}.${var.domain_name}:8081"
}

output "db_public_ip" {
  value = aws_instance.db_server.public_ip

}

output "app_public_ip" {
  value = aws_instance.nodejsapp.public_ip

}

output "route_53_db" {
  value = aws_route53_record.db_record.records
}
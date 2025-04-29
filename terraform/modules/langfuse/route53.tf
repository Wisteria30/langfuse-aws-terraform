resource "aws_route53_record" "langfuse" {
  name    = "langfuse.${var.custom_domain_name}"
  zone_id = var.custom_domain_id
  type    = "CNAME"
  records = [aws_apprunner_service.langfuse_web.service_url]
  ttl     = 300
}

resource "aws_route53_record" "grafana" {
  name    = "grafana.${var.custom_domain_name}"
  zone_id = var.custom_domain_id
  type    = "CNAME"
  records = [aws_apprunner_service.grafana.service_url]
  ttl     = 300
}
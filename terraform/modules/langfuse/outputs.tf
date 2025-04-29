output "langfuse_service_url" {
  description = "Langfuse Service URL"
  value       = aws_apprunner_service.langfuse_web.service_url
}

output "grafana_service_url" {
  description = "Grafana Service URL"
  value       = aws_apprunner_service.grafana.service_url
}
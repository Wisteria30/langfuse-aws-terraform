resource "aws_apprunner_service" "langfuse_web" {
  service_name = "langfuse_web"
  tags = {
    Name = "langfuse_web"
  }

  observability_configuration {
    observability_configuration_arn = aws_apprunner_observability_configuration.langfuse.arn
    observability_enabled           = true
  }

  source_configuration {
    authentication_configuration {
      access_role_arn = aws_iam_role.apprunner_service_role.arn
    }
    image_repository {
      image_configuration {
        port = "3000"
        runtime_environment_variables = {
          NEXTAUTH_URL                                  = "https://langfuse.${var.custom_domain_name}"
          NEXTAUTH_SECRET                               = var.web_next_secret
          SALT                                          = var.web_salt
          ENCRYPTION_KEY                                = var.encryption_key
          HOSTNAME                                      = "0.0.0.0"
          S3_BUCKET_NAME                                = aws_s3_bucket.langfuse_blob.id
          LANGFUSE_S3_MEDIA_UPLOAD_ENABLED              = "true"
          LANGFUSE_S3_MEDIA_UPLOAD_BUCKET               = aws_s3_bucket.langfuse_blob.id
          LANGFUSE_S3_MEDIA_DOWNLOAD_URL_EXPIRY_SECONDS = "604800" # 1 week

          CLICKHOUSE_MIGRATION_URL   = "clickhouse://${aws_service_discovery_service.clickhouse.name}.${aws_service_discovery_private_dns_namespace.langfuse.name}:9000"
          CLICKHOUSE_URL             = "http://${aws_service_discovery_service.clickhouse.name}.${aws_service_discovery_private_dns_namespace.langfuse.name}:8123"
          CLICKHOUSE_USER            = local.clickhouse_user
          CLICKHOUSE_CLUSTER_ENABLED = "false"

          LANGFUSE_S3_EVENT_UPLOAD_BUCKET = aws_s3_bucket.langfuse_event.id
          LANGFUSE_S3_EVENT_UPLOAD_REGION = var.region
          REDIS_AUTH                      = aws_elasticache_replication_group.langfuse_cache.auth_token
          LANGFUSE_S3_EVENT_UPLOAD_PREFIX = "events/"

          REDIS_HOST = aws_elasticache_replication_group.langfuse_cache.primary_endpoint_address
          REDIS_PORT = "6379"

          TELEMETRY_ENABLED                       = "true"
          LANGFUSE_ENABLE_EXPERIMENTAL_FEATURES   = "true"
          LANGFUSE_SDK_CI_SYNC_PROCESSING_ENABLED = "false"
          LANGFUSE_READ_FROM_POSTGRES_ONLY        = "false"
          LANGFUSE_READ_FROM_CLICKHOUSE_ONLY      = "true"
          LANGFUSE_RETURN_FROM_CLICKHOUSE         = "true"
        }
        runtime_environment_secrets = {
          DATABASE_URL        = aws_secretsmanager_secret.langfuse_database_url.arn
          CLICKHOUSE_PASSWORD = aws_secretsmanager_secret.clickhouse_password.arn
        }
      }
      image_identifier      = "${aws_ecr_repository.langfuse_web.repository_url}:latest"
      image_repository_type = "ECR"
    }
  }
  network_configuration {
    egress_configuration {
      egress_type       = "VPC"
      vpc_connector_arn = aws_apprunner_vpc_connector.connector.arn
    }
    ingress_configuration {
      is_publicly_accessible = true
    }
  }
  instance_configuration {
    instance_role_arn = aws_iam_role.apprunner_langfuse_instance_role.arn
  }
  depends_on = [aws_rds_cluster_instance.serverless_v2_instance, aws_rds_cluster.langfuse_aurora_cluster]
}

resource "aws_apprunner_observability_configuration" "langfuse" {
  observability_configuration_name = "langfuse"
  tags = {
    Name = "langfuse_observability"
  }

  trace_configuration {
    vendor = "AWSXRAY"
  }
}

resource "aws_apprunner_vpc_connector" "connector" {
  vpc_connector_name = "langfuse_vpc_connector"
  subnets            = var.private_subnet_ids
  security_groups    = [aws_security_group.apprunner_vpc_connector.id]
  tags = {
    Name = "langfuse_vpc_connector"
  }
}

resource "aws_apprunner_custom_domain_association" "langfuse" {
  domain_name = "langfuse.${var.custom_domain_name}"
  service_arn = aws_apprunner_service.langfuse_web.arn
}

resource "aws_apprunner_service" "grafana" {
  service_name = "grafana"
  tags = {
    Name = "grafana"
  }

  observability_configuration {
    observability_configuration_arn = aws_apprunner_observability_configuration.langfuse.arn
    observability_enabled           = true
  }

  source_configuration {
    authentication_configuration {
      access_role_arn = aws_iam_role.apprunner_service_role.arn
    }

    image_repository {
      image_configuration {
        port = "3000"
        runtime_environment_variables = {
          GF_AUTH_ANONYMOUS_ENABLED = "false"
          GF_INSTALL_PLUGINS        = "vertamedia-clickhouse-datasource"
          GF_SERVER_ROOT_URL        = "https://grafana.${var.custom_domain_name}"
          CLICKHOUSE_HOST           = "${aws_service_discovery_service.clickhouse.name}.${aws_service_discovery_private_dns_namespace.langfuse.name}"
          CLICKHOUSE_USER           = local.clickhouse_user
        }
        runtime_environment_secrets = {
          GF_SECURITY_ADMIN_PASSWORD = aws_secretsmanager_secret.grafana_admin_password.arn
          CLICKHOUSE_PASSWORD        = aws_secretsmanager_secret.clickhouse_password.arn
        }
      }
      image_identifier      = "${aws_ecr_repository.grafana.repository_url}:latest"
      image_repository_type = "ECR"
    }
  }

  network_configuration {
    egress_configuration {
      egress_type       = "VPC"
      vpc_connector_arn = aws_apprunner_vpc_connector.connector.arn
    }
    ingress_configuration {
      is_publicly_accessible = true
    }
  }

  instance_configuration {
    instance_role_arn = aws_iam_role.apprunner_langfuse_instance_role.arn
  }
}

resource "aws_apprunner_custom_domain_association" "grafana" {
  domain_name = "grafana.${var.custom_domain_name}"
  service_arn = aws_apprunner_service.grafana.arn
}

data "aws_route53_zone" "custom_domain" {
  name = "${var.custom_domain_name}."
}

resource "aws_route53_record" "certificate_validation_grafana" {
  # for_each = {
  #   for record in aws_apprunner_custom_domain_association.grafana.certificate_validation_records : record.name => {
  #     name   = record.name
  #     record = record.value
  #   }
  # }

  count = 3
  zone_id = data.aws_route53_zone.custom_domain.zone_id
  name    = tolist(
    aws_apprunner_custom_domain_association.grafana
    .certificate_validation_records
  )[count.index].name
  type    = tolist(
    aws_apprunner_custom_domain_association.grafana
    .certificate_validation_records
  )[count.index].type
  records = [
    tolist(
      aws_apprunner_custom_domain_association.grafana
      .certificate_validation_records
    )[count.index].value
  ]
  ttl     = "300"
  # name    = each.value.name
  # type    = "CNAME"
  # records = [each.value.record]
}

resource "aws_route53_record" "certificate_validation_langfuse" {
  # for_each = {
  #   for record in aws_apprunner_custom_domain_association.langfuse.certificate_validation_records : record.name => {
  #     name   = record.name
  #     record = record.value
  #   }
  # }

  count = 3
  zone_id = data.aws_route53_zone.custom_domain.zone_id
  name    = tolist(
    aws_apprunner_custom_domain_association.langfuse
    .certificate_validation_records
  )[count.index].name
  type    = tolist(
    aws_apprunner_custom_domain_association.langfuse
    .certificate_validation_records
  )[count.index].type
  ttl     = "300"
  records = [
    tolist(
      aws_apprunner_custom_domain_association.langfuse
      .certificate_validation_records
    )[count.index].value
  ]
  # records = [each.value.record]
}
  

data "aws_caller_identity" "current" {}

module "network" {
  source = "../modules/network"
  region = var.region
}

module "langfuse" {
  source             = "../modules/langfuse"
  env                = var.env
  identity_name      = var.identity_name
  region             = var.region
  availability_zones = var.availability_zones
  web_next_secret    = var.web_next_secret
  web_salt           = var.web_salt
  encryption_key     = var.encryption_key

  vpc_id             = module.network.vpc_id
  private_subnet_ids = module.network.private_subnet_ids

  custom_domain_id   = data.aws_route53_zone.custom_domain.zone_id
  custom_domain_name = data.aws_route53_zone.custom_domain.name
}

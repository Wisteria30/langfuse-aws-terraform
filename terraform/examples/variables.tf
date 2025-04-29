variable "identity_name" {
  type    = string
}

variable "env" {
  type    = string
}

variable "region" {
  type    = string
}

variable "availability_zones" {
  type        = list(string)
}

# variable "custom_domain_name" {
#   type        = string
# }

# variable "custom_domain_id" {
#   type        = string
# }

variable "web_next_secret" {
  type        = string
  description = "openssl rand -base64 32"
}

variable "web_salt" {
  type        = string
  description = "openssl rand -base64 32"
}

variable "encryption_key" {
  type        = string
  description = "openssl rand -hex 32"
}
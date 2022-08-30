terraform {
  required_providers {
    scaleway = {
      source = "scaleway/scaleway"
    }
  }
  required_version = ">= 0.13"
}

variable "access_key" {
  description = "Access Key"
  type        = string
  sensitive   = true
}

variable "secret_key" {
  description = "Secret Key"
  type        = string
  sensitive   = true
}

variable "project_id" {
  description = "Project ID"
  type        = string
  sensitive   = true
}

variable "zone" {
  description = "Zone"
  type        = string
  sensitive   = true
}

variable "region" {
  description = "Region"
  type        = string
  sensitive   = true
}

provider "scaleway" {
  access_key      = var.access_key
  secret_key      = var.secret_key
  project_id      = var.project_id
  zone            = var.zone
  region          = var.region
}

resource "scaleway_instance_security_group" "default_security_group" {
  name = "Default security group"
  description = "Auto generated security group."
  external_rules = false
  stateful = false
#  inbound_default_policy  = "drop"
#  outbound_default_policy = "accept"

#  inbound_rule {
#    action = "accept"
#    port   = "22"
#    ip     = "212.47.225.64"
#  }
}

resource "scaleway_instance_ip" "vade2splunk_public_ip" {
}

resource "scaleway_instance_server" "vade2splunk" {
  name       = "vade2splunk"
  type       = "DEV1-M"

  tags = ["vade", "splunk"]

  additional_volume_ids = []
  bootscript_id = "fdfe150f-a870-4ce4-b432-9f56b5b995c1"
  ip_id = scaleway_instance_ip.vade2splunk_public_ip.id
  image = "fr-par-1/881d7a33-4cfa-4046-b5cf-c33cb9c62fb6"
  enable_ipv6 = false

  root_volume {
    size_in_gb = 40
    delete_on_termination = true
    volume_id = "fr-par-1/53f85da2-de3e-4479-a678-0b94fa36a66a"
    volume_type = "l_ssd"
  }

  security_group_id = scaleway_instance_security_group.default_security_group.id
}

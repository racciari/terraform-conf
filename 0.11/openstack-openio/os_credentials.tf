### Openstack credentials

variable "openstack_username" {
  description = "Openstack username for the project."
  default  = "racciari"
}

variable "openstack_password" {
  description = "User's password."
  default  = "OS_PASSWORD"
}

variable "openstack_project_name" {
  description = "Openstack project name."
  default  = "test"
}

variable "openstack_auth_url" {
  description = "Endpoint url to connect to the OpenStack API."
  default  = "http://192.168.1.99:5000/"
}

variable "openstack_keypair" {
  description = "Keypair to access instances."
  default  = "racciari"
}

variable "openstack_region" {
  description = "Region to use for project."
  default = "RegionOne"
}


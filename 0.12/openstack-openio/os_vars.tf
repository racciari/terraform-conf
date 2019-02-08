### Variables defaults

variable "num-nodes" {
  default = "2"
}

variable "num-vol-add" {
  default = "2"
}

variable "use_floating_ip" {
  default = "0"
}

variable "openstack_compute_instance_default_flavor_name" {
  description = "Flavor to use for instances."
  default = "c2.m2"
}

variable "openstack_blockstorage_volume_root_size" {
  default = 8
}

variable "openstack_blockstorage_volume_add_size" {
  default = 2
}

variable "openstack_compute_instance_openio_name" {
  default = "myinstance"
}

# No need to modify pass this point
variable "openstack_network_default_name" {
  description = "Network to use for instances."
  default  = "private_network"
}

variable "openstack_blockstorage_volume_centos_7_x86_64_image_id" {
  default = "daf13788-97b3-47ff-8b54-614cde0fc23d"
}

variable "openstack_networking_subnet_private_subnet_dns_nameservers" {
  default = ["8.8.8.8","8.8.4.4"]
}

variable "openstack_networking_subnet_private_subnet_allocation_pools" {
  default = [{
    start = "10.0.0.2"
    end   = "10.255.255.254"
  }]
}

variable "openstack_networking_subnet_private_subnet_cidr" {
  default = "10.0.0.0/8"
}

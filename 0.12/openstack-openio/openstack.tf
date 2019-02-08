### Configure the OpenStack Provider

### Provider
provider "openstack" {
  user_name   = "${var.openstack_username}"
  password    = "${var.openstack_password}"
  tenant_name = "${var.openstack_project_name}"
  auth_url    = "${var.openstack_auth_url}"
  region      = "${var.openstack_region}"
}

### Project
resource "openstack_identity_project_v3" "tf_project" {
  name = "test"
  #description = "Test project"

#  lifecycle {
#    prevent_destroy = "true"
#  }
}

### Imports
# Register the external_network
resource "openstack_networking_network_v2" "tf_external_network" {
  name           = "external_network"
}

### Network
# Create a network
resource "openstack_networking_network_v2" "tf_private_network" {
  name           = "${var.openstack_network_default_name}"
  admin_state_up = "true"
}

resource "openstack_networking_subnet_v2" "tf_private_subnet" {
  name         = "private_subnet"
  network_id   = "${openstack_networking_network_v2.tf_private_network.id}"
  cidr         = "${var.openstack_networking_subnet_private_subnet_cidr}"
  ip_version   = 4

  enable_dhcp      = "true"
  gateway_ip       = "10.0.0.1"
  allocation_pools = "${var.openstack_networking_subnet_private_subnet_allocation_pools}"

  dns_nameservers = "${var.openstack_networking_subnet_private_subnet_dns_nameservers}"

}

### Router
resource "openstack_networking_port_v2" "tf_router1" {
  name           = "router1-privip"
  network_id     = "${openstack_networking_network_v2.tf_private_network.id}"
  admin_state_up = "true"
  device_owner   = "network:router_interface"
  fixed_ip = {
    subnet_id  = "${openstack_networking_subnet_v2.tf_private_subnet.id}"
    ip_address = "10.0.0.1"
  }
}

resource "openstack_networking_router_v2" "tf_router1" {
  name                = "router1"
  admin_state_up      = true
  external_network_id = "${openstack_networking_network_v2.tf_external_network.id}"
}

resource "openstack_networking_router_interface_v2" "tf_router_interface_1" {
  router_id = "${openstack_networking_router_v2.tf_router1.id}"
  port_id   = "${openstack_networking_port_v2.tf_router1.id}"
  #subnet_id = "${openstack_networking_subnet_v2.tf_private_subnet.id}"
}

### Instances
#resource "openstack_compute_floatingip_v2" "tf_fip" {
#  count = "${var.use_floating_ip > 0 ? var.num-nodes : 0}"
#  pool  = "external_network"
#}

# Port for the instance
resource "openstack_networking_port_v2" "tf_instance" {
  count          = "${var.num-nodes}"
  name           = "${var.openstack_compute_instance_openio_name}${format("%02d", count.index+1)}-privip"
  network_id     = "${openstack_networking_network_v2.tf_private_network.id}"
  admin_state_up = "true"

  fixed_ip       = {
    subnet_id = "${openstack_networking_subnet_v2.tf_private_subnet.id}"
  }

}

# Root volume for the instance
resource "openstack_blockstorage_volume_v3" "tf_instance_volume_root" {
  count       = "${var.num-nodes}"
  name        = "${var.openstack_compute_instance_openio_name}${format("%02d", count.index+1)}-rootvol"
  description = "root volume for instance ${var.openstack_compute_instance_openio_name}${format("%02d", count.index+1)}."
  size        = "${var.openstack_blockstorage_volume_root_size}"
  image_id    = "${var.openstack_blockstorage_volume_centos_7_x86_64_image_id}"
}

# Additionnal volume for the instance
resource "openstack_blockstorage_volume_v3" "tf_instance_volume_add" {
  count       = "${var.num-nodes * var.num-vol-add}"
  #name        = "${var.openstack_compute_instance_openio_name}${format("%02d", (count.index / var.num-nodes) + 1 )}-vol${format("%02d", (count.index % var.num-nodes) % var.num-vol-add + 1 )}"
  name        = "${var.openstack_compute_instance_openio_name}${format("%02d", count.index % var.num-nodes + 1)}-vol${format("%02d", count.index / var.num-nodes + 1 )}"
  #description = "Additionnal volume ${format("%02d", (count.index % var.num-nodes) % var.num-vol-add + 1 )} for instance ${var.openstack_compute_instance_openio_name}${format("%02d", (count.index / var.num-nodes) + 1)}."
  size        = "${var.openstack_blockstorage_volume_add_size}"
}

# Create a server
resource "openstack_compute_instance_v2" "tf_instance" {
  count           = "${var.num-nodes}"
  name            = "${var.openstack_compute_instance_openio_name}${format("%02d", count.index+1)}"
  flavor_name     = "${var.openstack_compute_instance_default_flavor_name}"
  key_pair        = "${var.openstack_keypair}"
  security_groups = ["default"]

  block_device {
    uuid                  = "${openstack_blockstorage_volume_v3.tf_instance_volume_root[count.index].id}"
    source_type           = "volume"
    boot_index            = 0
    destination_type      = "volume"
    delete_on_termination = true
  }

  network {
    port = "${openstack_networking_port_v2.tf_instance[count.index].id}"
  }

}

resource "openstack_compute_volume_attach_v2" "tf_attach_volume_add" {
  count       = "${var.num-nodes * var.num-vol-add}"
  instance_id = "${openstack_compute_instance_v2.tf_instance[count.index % var.num-nodes].id}"
  volume_id   = "${openstack_blockstorage_volume_v3.tf_instance_volume_add[count.index].id}"
}

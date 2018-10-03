variable "gcp_credentials" {
  description = "GCP credentials needed by google provider"
}

variable "gcp_project" {
  description = "GCP project name"
}

variable "gcp_region" {
 description = "GCP region"
 default = "us-east1"
}

// Google Provider Configuration
provider "google" {
  credentials = "${var.gcp_credentials}"
  project     = "${var.gcp_project}"
  region      = "${var.gcp_region}"
}

variable "compute_instance_count" {}
variable "compute_instance_disk_image" {}
variable "compute_instance_disk_size" {}
variable "compute_instance_machine_type" {}




//--------------------------------------------------------------------
// Modules
module "compute_instance" {
  source  = "app.terraform.io/GCPDemo/compute-instance/google"
  version = "1.0.0"

  count = "${var.compute_instance_count}"
  disk_image = "${var.compute_instance_disk_image}"
  disk_size = "${var.compute_instance_disk_size}"
  machine_type = "${var.compute_instance_machine_type}"
  name_prefix = "demo"
  subnetwork = "${module.network_subnet.self_link}"
}

module "network_firewall" {
  source  = "app.terraform.io/GCPDemo/network-firewall/google"
  version = "1.0.0"

  name = "allow-80"
  network = "${module.network.name}"
  ports = [80]
  protocol = "http"
  source_ranges = ["0.0.0.0/0"]
}

module "network_subnet" {
  source  = "app.terraform.io/GCPDemo/network-subnet/google"
  version = "1.0.0"

  description = "darnold demo network"
  ip_cidr_range = "172.16.0.0/16"
  name = "demo-subnet"
  vpc = "${module.network.self_link}"
}

module "network" {
  source  = "app.terraform.io/GCPDemo/network/google"
  version = "1.0.0"

  auto_create_subnetworks = "false"
  description = "Darnold Demo Network"
  name = "gcp-demo"
}
  
// Terraform outputs
output "network_name" {
  value = "${module.network.name}"
}
  
output "subnet_gateway_address" {
  value = "${module.network_subnet.gateway_address}"
} 
  
output "firewall_self_link" {
  value = "${module.network_firewall.self_link}"
}
  
output "compute_instance_addresses" {
  value = "${module.compute_instance.addresses}"




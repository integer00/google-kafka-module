locals {

  local_tags = ["kafka"]
}


data "template_file" "init_kafka" {
  count = var.instance_count
  template = file("${path.module}/templates/install_kafka.sh")

  vars = {
    ip_address = google_compute_address.kafka_vm_external_address[count.index].address
    broker_id = count.index
    zookeeper_address = var.zookeeper_address

    zookeeper_only = var.zookeeper_only
    kafka_only = var.kafka_only
  }
}

data "google_compute_network" "data_network" {
  project = var.project_id
  name    = var.network
}

data "google_compute_subnetwork" "data_subnetwork" {
  project = var.project_id
  name    = var.subnetwork
  region  = var.instance_region
}

resource "google_compute_instance" "kafka_vm" {
  project      = var.project_id
  name         = "${var.instance_name}${count.index}"
  count        = var.instance_count
  machine_type = var.instance_machine_type
  zone         = var.instance_zone
  tags = concat(
  var.tags,
  local.local_tags
  )

  allow_stopping_for_update = true

  boot_disk {
    source = google_compute_disk.kafka_vm_disk[count.index].name
  }

  metadata = merge(
          var.metadata,
  {
    startup-script = data.template_file.init_kafka[count.index].rendered
  })

  network_interface {
    subnetwork = data.google_compute_subnetwork.data_subnetwork.self_link
    network_ip = google_compute_address.kafka_vm_internal_address[count.index].address

    access_config {
      nat_ip = google_compute_address.kafka_vm_external_address[count.index].address
    }
  }
}


resource "google_compute_disk" "kafka_vm_disk" {
  project = var.project_id
  name    = "${var.instance_name}${count.index}-disk"
  count   = var.instance_count
  type    = var.disk_type
  size    = var.disk_size
  zone    = var.instance_zone
  image   = var.instance_image

  physical_block_size_bytes = 4096
}

resource "google_compute_address" "kafka_vm_external_address" {
  project    = var.project_id
  count      = var.instance_count
  name       = "${var.instance_name}${count.index}-external-address"
  region     = var.instance_region
}

resource "google_compute_address" "kafka_vm_internal_address" {
  project    = var.project_id
  count      = var.instance_count
  name       = "${var.instance_name}${count.index}-internal-address"
  region     = var.instance_region
  subnetwork = data.google_compute_subnetwork.data_subnetwork.name

  address_type = "INTERNAL"
}


resource "google_compute_firewall" "kafka_vm_allow_external" {
  project = var.project_id
  name    = "${var.instance_name}-firewall-rule"
  network = data.google_compute_network.data_network.name

  allow {
    protocol = "tcp"
    ports    = var.ports
  }

  target_tags = ["kafka"]
}
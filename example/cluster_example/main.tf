module "zookeeper" {
  source = "../../"

  project_id = var.project_id
  instance_name = "zookeeper"
  instance_machine_type = "g1-small"
  zookeeper_only = true

  ports = ["2181"]

  metadata = {
    sshKeys = "int:${file("~/.ssh/id_rsa.pub")}"
  }
}

module "kafka" {
  source = "../../"

  project_id = var.project_id
  instance_name = "kafka-cluster"
  zookeeper_address = module.zookeeper.zookeeper_address
  kafka_only = true

  instance_count = 3
  ports = ["9092","9308"]

  metadata = {
    sshKeys = "int:${file("~/.ssh/id_rsa.pub")}"
  }
}
output "project_id" {
  value = var.project_id
}

output "zookeeper" {
  value = {
    name = module.zookeeper.simple_vm_name,
    ip   = module.zookeeper.simple_external_ip,
  }
}
output "kafka" {
  value = {
    name = module.kafka.simple_vm_name,
    ip   = module.kafka.simple_external_ip,
  }
}
output "zk_address" {
  value = module.zookeeper.zookeeper_address
}
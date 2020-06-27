output "kafka" {
  value = {
    name = module.simple_example.simple_vm_name,
    ip   = module.simple_example.simple_external_ip,
  }
}
output "project_id" {
  value = var.project_id
}
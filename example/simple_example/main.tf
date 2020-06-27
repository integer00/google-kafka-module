module "simple_example" {
  source = "../../"

  project_id = var.project_id
  ports = ["9092","2181"]

  metadata = {
    sshKeys = "int:${file("~/.ssh/id_rsa.pub")}"
  }
}
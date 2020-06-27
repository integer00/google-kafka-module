variable "project_id" {
  description = "The ID of the google project"
  type        = string
}

variable "tags" {
  default = []
  type    = list(string)
}
variable "metadata" {
  type    = map(string)
  default = {}
}
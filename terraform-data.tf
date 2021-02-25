locals {
  terraform-data = {
    id   = var.id
    name = var.name
    tags = var.tags
  }
}

resource "local_file" "terraform-data" {
  filename = "${path.module}/.terraform-data.json"
  content  = jsonencode(local.terraform-data)
}


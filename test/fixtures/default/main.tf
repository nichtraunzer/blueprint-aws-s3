locals {
  name = "blueprint-aws-s3-test-default"

  tags = {
    Name = "${local.name}-${local.id}"
  }
}

module "blueprint-aws-s3-test-default" {
  source = "../../.."

  id   = local.id
  name = local.name

  force_destroy = true
  tags          = local.tags
}


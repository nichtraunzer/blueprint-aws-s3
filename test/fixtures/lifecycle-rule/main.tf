locals {
  name = "blueprint-aws-s3-test-default-lifecycle"

  tags = {
    Name = "${local.name}-${local.id}"
  }
}

module "blueprint-aws-s3-test-default-lifecycle" {
  source = "../../.."

  id   = local.id
  name = local.name

  lifecycle_rule_enabled                       = true
  lifecycle_rule_expiration_days               = "1095"
  lifecycle_rule_noncurrent_version_expiration = "1095"

  force_destroy = true
  tags          = local.tags
}


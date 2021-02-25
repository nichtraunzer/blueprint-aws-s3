output "inputs2outputs" {
  description = "all inputs passed to outputs"
  value = [{
    block_public_acls                            = var.block_public_acls
    block_public_policy                          = var.block_public_policy
    bucket_acl                                   = var.bucket_acl
    bucket_policy                                = var.bucket_policy
    bucket_versioning                            = var.bucket_versioning
    force_destroy                                = var.force_destroy
    id                                           = var.id
    kms_master_key_id                            = var.kms_master_key_id
    lifecycle_rule_enabled                       = var.lifecycle_rule_enabled
    lifecycle_rule_expiration_days               = var.lifecycle_rule_expiration_days
    lifecycle_rule_noncurrent_version_expiration = var.lifecycle_rule_noncurrent_version_expiration
    name                                         = var.name
    tags                                         = var.tags
    use_bucket_policy                            = var.use_bucket_policy
  }]
}

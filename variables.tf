# -----------------------------------------------------------------------------
# ENVIRONMENT VARIABLES
# This blueprint supports the following secrets as environment variables.
# -----------------------------------------------------------------------------

# AWS_ACCESS_KEY_ID
# AWS_SECRET_ACCESS_KEY
# AWS_DEFAULT_REGION

# -----------------------------------------------------------------------------
# REQUIRED PARAMETERS
# The following blueprint parameters require a value.
# Documentation: https://www.terraform.io/docs/configuration/variables.html
# -----------------------------------------------------------------------------

variable "id" {
  description = "A unique identifier."
  type        = string
}

variable "name" {
  description = "The name of the bucket."
  type        = string
}

# -----------------------------------------------------------------------------
# OPTIONAL PARAMETERS
# The following blueprint parameters are optional with sensible defaults.
# Documentation: https://www.terraform.io/docs/configuration/variables.html
# -----------------------------------------------------------------------------

variable "tags" {
  description = "A map of tag key-value pairs."
  type        = map(string)
  default     = {}
}

variable "bucket_policy" {
  description = "A bucket policy which is applied to the bucket."
  type        = string
  default     = "{}"
}

variable "force_destroy" {
  description = "Defines if all objects in the bucket shall be destroyed so that the bucket can be deleted, or not (for testing)."
  default     = false
}

variable "use_bucket_policy" {
  description = "Defines if a bucket policy shall be applied, or not."
  default     = false
}

variable "bucket_acl" {
  description = "Setup the bucket ACL to private or not. The [canned ACL](https://docs.aws.amazon.com/AmazonS3/latest/dev/acl-overview.html#canned-acl) to apply."
  type        = string
  default     = "private"
}

variable "kms_master_key_id" {
  description = "The AWS KMS master key ID used for the SSE-KMS encryption. This can only be used when you set the value of sse_algorithm as aws:kms. The default aws/s3 AWS KMS master key is used by default."
  type        = string
  default     = ""
}

variable "block_public_acls" {
  description = "Whether Amazon S3 should block public ACLs for this bucket. Defaults to true. Enabling this setting does not affect existing policies or ACLs. When set to true causes the following behavior: PUT Bucket acl and PUT Object acl calls will fail if the specified ACL allows public access. PUT Object calls will fail if the request includes an object ACL."
  type        = string
  default     = true
}

variable "block_public_policy" {
  description = "Whether Amazon S3 should block public bucket policies for this bucket. Defaults to true. Enabling this setting does not affect the existing bucket policy. When set to true causes Amazon S3 to: Reject calls to PUT Bucket policy if the specified bucket policy allows public access."
  type        = string
  default     = true
}

variable "bucket_versioning" {
  description = "Setup the bucket versioninig to be true or false."
  default     = false
}

# lifecycle_rule

variable "lifecycle_rule_enabled" {
  description = "Specifies lifecycle rule status."
  default     = false
}

variable "lifecycle_rule_expiration_days" {
  description = "Specifies the number of days after object creation when the specific rule action takes effect."
  default     = "1095"
}

variable "lifecycle_rule_noncurrent_version_expiration" {
  description = "Specifies when noncurrent object versions expire."
  default     = "1095"
}
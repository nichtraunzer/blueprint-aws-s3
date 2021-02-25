# -----------------------------------------------------------------------------
# OUTPUTS
# This blueprint supports the following output values.
# Documentation: https://www.terraform.io/docs/configuration/outputs.html
# -----------------------------------------------------------------------------

output "id" {
  description = "The id of the bucket."
  value       = aws_s3_bucket.bucket.id
}

output "arn" {
  description = "The ARN of the bucket."
  value       = aws_s3_bucket.bucket.arn
}

output "tags" {
  description = "A map of tag key-value pairs."
  value       = var.tags
}


locals {
  name       = "blueprint-aws-s3-test-bucket-policy"
  bucket_arn = module.blueprint-aws-s3-test-bucket-policy.arn

  tags = {
    Name = "${local.name}-${local.id}"
  }
}


data "aws_iam_policy_document" "bucket_policy_test" {
  statement {
    sid    = "DenyIPCondition"
    effect = "Deny"
    principals {
      type        = "AWS"
      identifiers = ["*"]
    }
    actions   = ["s3:*", ]
    resources = ["${local.bucket_arn}/*", ]
    condition {
      test     = "IpAddress"
      variable = "aws:SourceIp"
      values   = ["192.168.0.1/32"]
    }
  }
  statement {
    sid    = "denyGetPut"
    effect = "Deny"
    principals {
      type        = "AWS"
      identifiers = ["*"]
    }
    actions   = ["s3:GetObject", "s3:PutObject"]
    resources = ["${local.bucket_arn}/*", "${local.bucket_arn}"]
  }
}
module "blueprint-aws-s3-test-bucket-policy" {
  source = "../../.."

  id   = local.id
  name = local.name

  force_destroy     = true
  use_bucket_policy = true

  # Use copy / paste within IAM-Policy to pre-validate the policy
  bucket_policy = data.aws_iam_policy_document.bucket_policy_test.json

  tags = local.tags
}

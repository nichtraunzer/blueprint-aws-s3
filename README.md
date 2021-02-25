# Blueprint: AWS S3

This blueprint describes the deployment of an AWS Simple Storage Service (S3) bucket with:
 * Default encryption on.
 * Default public access off.

## What is a Blueprint?

A blueprint is a configurable and reusable infrastructure-as-code artefact. In line with the [UNIX philosophy](https://en.wikipedia.org/wiki/Unix_philosophy), a blueprint should [do one thing and do it well](https://en.wikipedia.org/wiki/Unix_philosophy#Do_One_Thing_and_Do_It_Well). Practical examples include foundational infrastructure services, such as *networking*, *compute* and *storage*, but may as well be of arbitrary higher-level nature.

Every blueprint supports a set of *inputs* and a set of *outputs*, where an output of one blueprint may serve as the input of a dependent blueprint. This way, several blueprints can be composed into an arbitrarily complex system, or as we call it: a [*stack*](https://bitbucket.biscrum.com/projects/INFIAAS/repos/stack-aws-skeleton/browse).

## How to use this Blueprint?

The behavior of a blueprint is determined by its purpose and the set of input parameters. Here is an overview of the *inputs* and *outputs* available for this blueprint. Please refer to this [example](test/fixtures/default/main.tf) on how to include this blueprint in a stack.

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| terraform | >= 0.12 |

## Providers

| Name | Version |
|------|---------|
| aws | n/a |
| local | n/a |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| block\_public\_acls | Whether Amazon S3 should block public ACLs for this bucket. Defaults to true. Enabling this setting does not affect existing policies or ACLs. When set to true causes the following behavior: PUT Bucket acl and PUT Object acl calls will fail if the specified ACL allows public access. PUT Object calls will fail if the request includes an object ACL. | `string` | `true` | no |
| block\_public\_policy | Whether Amazon S3 should block public bucket policies for this bucket. Defaults to true. Enabling this setting does not affect the existing bucket policy. When set to true causes Amazon S3 to: Reject calls to PUT Bucket policy if the specified bucket policy allows public access. | `string` | `true` | no |
| bucket\_acl | Setup the bucket ACL to private or not. The [canned ACL](https://docs.aws.amazon.com/AmazonS3/latest/dev/acl-overview.html#canned-acl) to apply. | `string` | `"private"` | no |
| bucket\_policy | A bucket policy which is applied to the bucket. | `string` | `"{}"` | no |
| bucket\_versioning | Setup the bucket versioninig to be true or false. | `bool` | `false` | no |
| force\_destroy | Defines if all objects in the bucket shall be destroyed so that the bucket can be deleted, or not (for testing). | `bool` | `false` | no |
| id | A unique identifier. | `string` | n/a | yes |
| kms\_master\_key\_id | The AWS KMS master key ID used for the SSE-KMS encryption. This can only be used when you set the value of sse\_algorithm as aws:kms. The default aws/s3 AWS KMS master key is used by default. | `string` | `""` | no |
| lifecycle\_rule\_enabled | Specifies lifecycle rule status. | `bool` | `false` | no |
| lifecycle\_rule\_expiration\_days | Specifies the number of days after object creation when the specific rule action takes effect. | `string` | `"1095"` | no |
| lifecycle\_rule\_noncurrent\_version\_expiration | Specifies when noncurrent object versions expire. | `string` | `"1095"` | no |
| name | The name of the bucket. | `string` | n/a | yes |
| tags | A map of tag key-value pairs. | `map(string)` | `{}` | no |
| use\_bucket\_policy | Defines if a bucket policy shall be applied, or not. | `bool` | `false` | no |

## Outputs

| Name | Description |
|------|-------------|
| arn | The ARN of the bucket. |
| id | The id of the bucket. |
| inputs2outputs | all inputs passed to outputs |
| tags | A map of tag key-value pairs. |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

## How to test this Blueprint?

Testing the functionality of this blueprint requires the following dependencies: `make`, `tee`, `ruby`, [`bundler`](https://bundler.io/), and [`terraform`](https://www.terraform.io/). Once installed, run `make test` from the command line.

![asciinema - How to test this Blueprint?](https://bitbucket.biscrum.com/projects/INFIAAS/repos/blueprint-aws-skeleton/raw/asciinema-how-to-test-this-blueprint.gif?at=refs%2Fheads%2Fmedia)

Note that, when running tests, blueprints will interact with some cloud provider, such as *AWS*, *Azure* or *VMware*. It is up to you to provide sufficient configuration to enable these interactions, which differs between vendors. Here is an example for *AWS* that uses environment variables (via [Configuring the AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-getting-started.html)):

```
$ export AWS_ACCESS_KEY_ID=...
$ export AWS_SECRET_ACCESS_KEY=...
$ export AWS_DEFAULT_REGION=us-east-1
$ make test
```

## How to develop a Blueprint?

Developing a blueprint basically involves cloning the blueprint skeleton project available at [infiaas/blueprint-aws-skeleton](https://bitbucket.biscrum.com/projects/INFIAAS/repos/blueprint-aws-skeleton/browse) into your workspace and adapting it to suit your needs.

Setting up blueprint development guardrails requires the following dependencies: `make`, `tee`, `ruby`, [`bundler`](https://bundler.io/), `python`, [`pre-commit`](https://pre-commit.com/) [`terraform`](https://www.terraform.io/), and [`terraform-docs`](https://github.com/segmentio/terraform-docs). Once installed, run `make install-dev-deps` to install a set of quality improving *pre-commit hooks* into your local Git repository. Upon a `git commit`, these hooks will make sure that your code is both syntactically and functionally correct and that your `README.md` contains up-to-date documentation of your blueprint's supported set of *inputs* and *outputs*.

More information on the development flow is available in [Confluence](https://confluence.biscrum.com/display/MIGITINF/Blueprints).

## Problems? Questions? Suggestions?

In case of problems, questions or suggestions, feel free to file an issue with the respective project's repository. Thanks!

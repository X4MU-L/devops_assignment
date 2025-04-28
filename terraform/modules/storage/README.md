
# S3 Storage Module

This module creates an AWS S3 bucket with versioning, lifecycle policies, encryption, and public access blocking.

## Usage

```hcl
module "s3_storage" {
  source = "./terraform/modules/storage"

  bucket_name_prefix = "example-bucket"
  resource_suffix = "dev01"
  environment = "dev"
  purpose = "storage-example"
  enable_versioning = true

  lifecycle_rules = [
    {
      id                        = "expire-old-objects"
      status                    = "Enabled"
      prefix                    = "logs/"
      expiration_days           = 30
      noncurrent_expiration_days = 90
    }
  ]

  tags = {
    Project = "ExampleProject"
    Owner   = "DevOpsTeam"
  }
}
```

## Inputs

| Name | Description | Type | Default | Required |
|:---- |:----------- |:---- |:------- | --------:|
| bucket_name_prefix | Prefix for S3 bucket name | string | n/a | yes |
| resource_suffix | Suffix to ensure uniqueness | string | n/a | yes |
| environment | Environment tag | string | n/a | yes |
| purpose | Purpose tag | string | n/a | yes |
| enable_versioning | Enable S3 bucket versioning | bool | n/a | yes |
| lifecycle_rules | List of lifecycle rules | list(object) | [] | no |
| tags | Tags map | map(string) | n/a | yes |

## Outputs

| Name | Description |
|:-----|:---------- |
| bucket_id | The ID of the S3 bucket |
| bucket_arn | The ARN of the S3 bucket |
| bucket_name | The name of the S3 bucket |
| bucket_versioning_status | Versioning status of the bucket |
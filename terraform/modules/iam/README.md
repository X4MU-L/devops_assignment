# IAM Module

This module creates an AWS IAM user with optional access keys and attaches either a new or existing policy.

## Usage

```hcl
module "iam_user" {
  source = "terraform/modules/iam"

  iam_user_name_prefix = "example-user"
  iam_policy_name_prefix = "example-policy"
  resource_suffix = "dev01"
  environment = "dev"
  purpose = "example-usage"
  policy_description = "Policy for S3 access"
  create_access_key = true

   policy_statements = [
    {
      Action = [
        "s3:PutObject",
        "s3:GetObject",
        "s3:DeleteObject",
        "s3:ListBucket",
      ],
      Effect = "Allow",
      Resource = [
        resource_arn,
        "${module.jenkins_backup_bucket.bucket_arn}/*"
      ],
    }
  ]

  tags = {
    Project = "ExampleProject"
    Owner   = "DevOpsTeam"
  }
}
```

## Inputs

| Name     | Description |Type      | Default | Required |
|:-------- |:----------- |:-------- |:------- | --------:|
| iam_user_name_prefix | Prefix for IAM username | string | n/a | yes |
| iam_policy_name_prefix | Prefix for IAM policy name | string | n/a | yes |
| resource_suffix | Suffix to ensure uniqueness | string | n/a | yes |
| environment | Environment tag | string | n/a | yes |
| purpose | Purpose tag | string | n/a | yes |
| policy_description | IAM policy description | string | n/a | yes |
| policy_statements | List of policy statements | list(object) | n/a | yes |
| tags | Tags map | map(string) | n/a | yes |
| create_access_key | Whether to create an access key | bool | true | no |
| existing_policy_arn | ARN of an existing IAM policy | string | null | no |

## Outputs

| Name | Description |
|:-----|:---------- |
| iam_user_name | The IAM user's name |
| iam_user_arn | The IAM user's ARN |
| access_key_id | Access key ID (if created) |
| secret_access_key | Secret access key (if created) |
| policy_arn | IAM Policy ARN (created or existing) |
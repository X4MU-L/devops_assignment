# 10. Write a Terraform configuration snippet to provision an S3 bucket and restrict its access to a specific IAM user

When you're starting with Terraform, it’s tempting to just throw resources directly into a `.tf` file: a user here, a bucket there, a policy here. But as your infrastructure grows, so does the chaos. That's where modules come in. My best approach, I always take the `"hard-painful-easy"` approach

Today, let's look at a practical example: provisioning an IAM user who can access a private S3 bucket — and how using modules makes our life significantly better... as matter of fact if i be very honest, i am answering this question with a module i had once written

I'll also walk us through a real-world example you might recognize if you've worked with AWS.

I have created an [s3 module](/terraform/modules/storage) and [iam module](/terraform/modules/iam)

```hcl
module "storage" {
  source = "./terraform/modules/storage"

  bucket_name_prefix = "my-app-prod-bucket"
  resource_suffix    = "prod01"
  environment        = "prod"
  purpose            = "AppBucket"
  enable_versioning  = true

  lifecycle_rules = [
    {
      id                         = "expire-logs"
      status                     = "Enabled"
      prefix                     = "logs/"
      expiration_days            = 60
      noncurrent_expiration_days = 180
    }
  ]

  tags = {
    Project = "MyApp"
    Owner   = "PlatformTeam"
  }
}

module "iam_user" {
  source = "../../modules/iam"

  iam_user_name_prefix   = "appuser"
  iam_policy_name_prefix = "apppolicy"
  resource_suffix        = "prod01"
  environment            = "prod"
  purpose                = "AppUserForProd"
  policy_description     = "Policy granting access to specific S3 bucket"
  create_access_key      = true

  policy_statements = [
    {
      Effect = "Allow"
      Action = [
        "s3:ListBucket"
      ]
      Resource = module.storage.bucket_arn
    },
    {
      Effect = "Allow"
      Action = [
        "s3:GetObject",
        "s3:PutObject",
        "s3:DeleteObject"
      ]
      Resource = "${module.storage.bucket_arn}/*"
    }
  ]

  tags = {
    Project = "MyApp"
    Owner   = "PlatformTeam"
  }
}

```

We provision the bucket first (doesn't really matter the other in the file, terraform will provision each according to dependency), then reference its ARN when building IAM policies.

`module.storage.bucket_arn` gives us the ARN of the bucket, and `"${module.s3_bucket.bucket_arn}/*"` targets all objects inside.

By parameterizing Action, Resource, and Effect, our IAM module can handle any permission case you throw at it and can be can be used for any other resource.

## Why Using Modules Here Is the Right Move

1. **Reusability**: You can provision many buckets and users by simply reusing your modules with different variables.

2. **Maintainability**: If AWS changes something (say, adds a new field to S3 configuration), you only update the module once, not in every project.

3. **Separation of Concerns**: 
    - IAM logic stays in iam/
    - S3 logic stays in storage/ This keeps teams focused and code clean.

4. **Security**: We’re enforcing least privilege with tightly scoped policies at module level — no accidentally wide-open S3 access.

5. **Scalability**: Tomorrow, we could wrap these modules with environment layers (dev, staging, prod) using workspaces or any other tool.

## Final Thought

Infrastructure isn't just about writing Terraform. It's about designing it like real software.
When you use modules, you treat your cloud resources like reusable components, not one-off scripts.
And that is the foundation of scalable DevOps practices.

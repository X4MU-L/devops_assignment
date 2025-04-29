# 8. Explain the purpose of terraform init, plan, and apply. What is the significance of the state file?

When you're managing cloud infrastructure, you don't want to click around manually.
You want to define your infrastructure in code — that's where Terraform comes in.

But once you write that code... how does Terraform know what to do with it?
That's where commands like `terraform init`, `plan`, and `apply `— and the mysterious `terraform.tfstate` file — come into play.

Let's break everything down clearly, with examples!

## `terraform init` — Getting Ready

Before you can do anything with Terraform, you have to run:

```bash
terraform init
```

What does it do?

Downloads the right providers — for example, if you want to create AWS resources, Terraform downloads the AWS provider plugin automatically.

Sets up backends — if you're storing your state remotely (e.g., in AWS S3), init configures that too.

Prepares the working directory — creating a hidden .terraform/ folder where it keeps internal stuff.

e.g

Suppose you have this very simple Terraform configuration file (`main.tf`):

```hcl
provider "aws" {
    region = "us-east-1"
}

resource "aws_s3_bucket" "my_bucket" {
    bucket = "my-terraform-demo-bucket"
}
```

Running `terraform init` will:

Download the AWS provider.

Set up your project so you can actually start working.

You must run init before anything else — think of it like "installing dependencies" when working on a software project.

## `terraform plan` — Preview the Future

After initialization, you run:

```bash
terraform plan
```

This command does not change anything yet!
Instead, it shows you what Terraform would do if you applied the changes.

It compares:

- _What your code says you want_

- _What currently exists (based on the state file)_

- _What actions are needed to sync the two_

You get a nice color-coded output:

- _Green ➔ to create_

- _Yellow ➔ to update_

- _Red ➔ to destroy_

Example output

```bash
Plan: 1 to add, 0 to change, 0 to destroy.
```

It tells you exactly what it's planning to create.

`terraform plan` is your chance to catch mistakes before Terraform actually touches anything!

## `terraform apply` — Make It Real

Once you're happy with the plan, you can move forward with:

```bash
terraform apply
```

Terraform will:

Prompt you to confirm (unless you use -auto-approve)

Create, update, or destroy resources based on the plan

Update the state file to reflect the new reality

Example workflow:

```bash
terraform plan -out=tfplan
terraform apply tfplan
```

Here, you first save the plan to a file (tfplan), and then apply that exact plan later.
This is useful for auditing or approval processes — the plan you apply cannot differ from what was reviewed.

## The Terraform State File (`terraform.tfstate`)

Terraform does not "ask AWS" (or any provider) every time it wants to know the state of your infrastructure, what you have.
Instead, it maintains its own state file — a snapshot of your infrastructure.

**Why the state file is critical:**

**Mapping**: It keeps track of what resources Terraform created (e.g., "this S3 bucket belongs to this resource block").

**Efficient Planning**: It speeds up terraform plan because it doesn’t need to query everything from scratch.

**Detecting Drift**: If something is changed outside Terraform, the state helps detect that the real infrastructure has "drifted" from the desired state.

> [! CAUTION]
> Sensitive Information Sometimes, the state contains secrets (like passwords or access keys), so it must be protected!

Example of a statefile

```json
{
  "resources": [
    {
      "type": "aws_s3_bucket",
      "name": "my_bucket",
      "instances": [
        {
          "attributes": {
            "bucket": "my-terraform-demo-bucket"
          }
        }
      ]
    }
  ]
}
```

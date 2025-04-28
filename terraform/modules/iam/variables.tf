variable "iam_user_name_prefix" {
  description = "Prefix for the IAM user name"
  type        = string
}

variable "iam_policy_name_prefix" {
  description = "Prefix for the IAM policy name"
  type        = string
}

variable "resource_suffix" {
  description = "Suffix to ensure resource name uniqueness"
  type        = string
}

variable "environment" {
  description = "Environment (e.g., dev, staging, prod)"
  type        = string
}

variable "purpose" {
  description = "Purpose of the IAM user"
  type        = string
}

variable "policy_description" {
  description = "Description for the IAM policy"
  type        = string
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
}

variable "policy_statements" {
  description = "List of IAM policy statements"
  type = list(object({
    Action    = list(string)
    Effect    = string
    Resource  = any
    Condition = optional(map(map(any)))
    Principal = optional(map(any))
    Sid       = optional(string)
  }))
}

variable "create_access_key" {
  description = "Whether to create an access key for the IAM user"
  type        = bool
  default     = true
}

variable "existing_policy_arn" {
  description = "If provided, attaches an existing policy instead of creating a new one"
  type        = string
  default     = null
}

variable "bucket_name_prefix" {
  description = "Prefix for the S3 bucket name"
  type        = string
}

variable "environment" {
  description = "Environment (e.g., dev, staging, prod)"
  type        = string
}

variable "purpose" {
  description = "Purpose of the bucket"
  type        = string
}

variable "enable_versioning" {
  description = "Enable versioning for the bucket"
  type        = bool
}

variable "lifecycle_rules" {
  description = "List of lifecycle rules"
  type = list(object({
    id                         = string
    status                     = string
    prefix                     = string
    expiration_days            = number
    noncurrent_expiration_days = number
  }))
  default = []
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
}

variable "resource_suffix" {
  description = "Suffix to ensure resource name uniqueness"
  type        = string
}

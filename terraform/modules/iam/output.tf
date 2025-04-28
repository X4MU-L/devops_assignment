output "iam_user_name" {
  description = "The name of the IAM user"
  value       = aws_iam_user.user.name
}

output "iam_user_arn" {
  description = "The ARN of the IAM user"
  value       = aws_iam_user.user.arn
}

output "access_key_id" {
  description = "The access key ID"
  value       = aws_iam_access_key.access_key.id
}

output "secret_access_key" {
  description = "The secret access key"
  value       = aws_iam_access_key.access_key.secret
  sensitive   = true
}

output "policy_arn" {
  description = "The ARN of the created IAM policy"
  value       = aws_iam_policy.policy.arn
}

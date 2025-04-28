resource "aws_iam_user" "user" {
  name = "${var.iam_user_name_prefix}-${var.resource_suffix}"

  tags = merge(
    var.tags,
    {
      Name        = "${var.iam_user_name_prefix}-${var.resource_suffix}"
      Environment = var.environment
      Purpose     = var.purpose
    }
  )
}

resource "aws_iam_access_key" "access_key" {
  count = var.create_access_key ? 1 : 0
  user  = aws_iam_user.user.name
}


resource "aws_iam_policy" "policy" {
  count       = var.existing_policy_arn == null ? 1 : 0
  name        = "${var.iam_policy_name_prefix}-${var.resource_suffix}"
  description = var.policy_description

  # Modified policy definition to ensure proper JSON structure
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      for stmt in var.policy_statements : {
        Action   = stmt.Action
        Effect   = stmt.Effect
        Resource = stmt.Resource
      }
    ]
  })
}


resource "aws_iam_user_policy_attachment" "policy_attachment" {
  user       = aws_iam_user.user.name
  policy_arn = var.existing_policy_arn != null ? var.existing_policy_arn : aws_iam_policy.policy[0].arn
}

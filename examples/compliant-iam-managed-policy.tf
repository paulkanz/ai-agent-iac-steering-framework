# Example: NIST SP 800-53 Compliant IAM Architecture
# Conformance Pack Rule: iam-no-inline-policy-check (AC-2, AC-3, AC-6)

# ------------------------------------------------------------------------------
# ❌ ANTI-PATTERN (What unconstrained AI agents typically generate):
# Inline role policies cannot be audited independently, lack version control,
# and cause conformance pack check regressions.
# ------------------------------------------------------------------------------
# resource "aws_iam_role_policy" "bad_inline_example" {
#   name = "bad-inline-policy"
#   role = aws_iam_role.app_task.id
#   policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [{
#       Effect   = "Allow"
#       Action   = "s3:*"
#       Resource = "*"  # CRITICAL: Wildcard permission!
#     }]
#   })
# }

# ------------------------------------------------------------------------------
# ✅ COMPLIANT PATTERN (What this steering framework enforces):
# 1. Standalone, customer-managed aws_iam_policy.
# 2. Attached via aws_iam_role_policy_attachment.
# 3. Explicit ARN resource scoping (no wildcards).
# ------------------------------------------------------------------------------

resource "aws_iam_role" "app_task" {
  name = "enterprise-app-task-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Action    = "sts:AssumeRole"
      Principal = { Service = "ecs-tasks.amazonaws.com" }
    }]
  })

  tags = {
    Compliance = "NIST-800-53-Rev5"
  }
}

resource "aws_iam_policy" "s3_vault_access" {
  name        = "enterprise-app-s3-vault-access"
  description = "Scoped read/write access to application document vault only"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "ScopedS3VaultBucketAccess"
        Effect = "Allow"
        Action = [
          "s3:ListBucket",
          "s3:GetBucketLocation"
        ]
        Resource = "arn:aws:s3:::enterprise-document-vault"
      },
      {
        Sid    = "ScopedS3VaultObjectAccess"
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject"
        ]
        Resource = "arn:aws:s3:::enterprise-document-vault/*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "s3_vault_access" {
  role       = aws_iam_role.app_task.name
  policy_arn = aws_iam_policy.s3_vault_access.arn
}

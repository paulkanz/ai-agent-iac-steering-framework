# Antigravity / Gemini CLI Agent Rules: IaC Guardrails

You are assisting with enterprise-grade Infrastructure as Code. Adhere strictly to these architectural guardrails:

## 1. Compliance Baseline (NIST SP 800-53 Rev 5)
* Customer-managed IAM policies only (`aws_iam_policy`). No inline role policies.
* Scoped ARNs; no wildcard `*` permissions on sensitive actions.
* KMS Customer Managed Keys with annual rotation on all datastores.

## 2. Infrastructure Patterns
* Break security group cycles with standalone ingress/egress rule resources.
* Workload isolation: Private subnets, `assign_public_ip = false`.
* OpenTofu / Terraform lock hygiene: Keep provider origin pinned to `registry.terraform.io`.

## 3. Verification Protocol
* Execute `terraform fmt -recursive` scoped strictly to target files.
* Confirm zero syntax errors via `terraform validate`.
* Execute native `terraform test` suites where available.

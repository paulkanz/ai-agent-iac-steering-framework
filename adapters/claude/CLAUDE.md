# Claude Code Project Guidelines: Enterprise Infrastructure as Code

## Architecture & Scope
* **Cloud Partition:** AWS Commercial & AWS GovCloud (`us-gov-west-1`).
* **Compliance Standards:** NIST SP 800-53 Rev. 5 (Moderate), CIS AWS Foundations Benchmark v3.0, SOC 2 Type II.

## Non-Negotiable Agent Rules:
1. **Never inline IAM Role Policies:**
   * Conformance pack rule `iam-no-inline-policy-check` flags inline role policies.
   * Generate customer-managed `aws_iam_policy` and attach via `aws_iam_role_policy_attachment`.
2. **Break Security Group Dependency Cycles:**
   * Use independent `aws_vpc_security_group_ingress_rule` and `_egress_rule` resources.
3. **Provider Lock Protection:**
   * Maintain `registry.terraform.io` pinning in `.terraform.lock.hcl`. Never allow OpenTofu init to re-point to `registry.opentofu.org`.
4. **Encryption Mandatory:**
   * KMS CMK with annual rotation on all storage and log groups.
   * TLS 1.2+ mandatory in transit.
5. **Verification Pipeline:**
   * Always run `terraform fmt -check`, `terraform validate`, and `terraform test` before presenting code diffs.

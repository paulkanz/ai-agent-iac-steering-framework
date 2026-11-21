# The OpenTofu vs. Terraform Provider Registry Lock Trap

## The Architectural Failure Mode

When engineering teams run **OpenTofu** in environments where legacy states or pipelines were initialized with **HashiCorp Terraform**, a catastrophic silent failure mode frequently occurs if AI coding agents run unguided `init` commands.

### How the Trap Occurs:
1. Committed `.terraform.lock.hcl` files pin provider origins to the HashiCorp registry:
   ```hcl
   provider "registry.terraform.io/hashicorp/aws" {
     version     = "5.50.0"
     constraints = "~> 5.0"
     hashes = [ ... ]
   }
   ```
2. OpenTofu CLI natively queries `registry.opentofu.org`.
3. If an unguided AI agent executes `tofu init` or `terraform init` without strict lock preservation flags, OpenTofu silently re-writes the lock file to:
   ```hcl
   provider "registry.opentofu.org/hashicorp/aws" { ... }
   ```
4. When CI/CD or another engineer attempts a `terraform plan` against the existing remote state, the execution aborts with:
   ```text
   Error: Move Resource State Not Supported
   State contains resources managed by registry.terraform.io/hashicorp/aws,
   but provider configuration pins registry.opentofu.org/hashicorp/aws.
   ```

---

## The Enforced Agent Guardrail

In [`tech.md`](../.kiro/steering/tech.md), this framework imposes a hard constraint on all autonomous agents:

1. **Lock Immutability:** Agents must NEVER commit lock file diffs where provider namespaces flip between registries.
2. **State Remediation Pattern:** If state drift occurs, agents must resolve it using explicit provider replacement:
   ```bash
   terraform state replace-provider registry.opentofu.org/hashicorp/aws registry.terraform.io/hashicorp/aws
   ```
3. **CI Gate Validation:** CI pipeline linters assert that `.terraform.lock.hcl` files consistently point to the canonical registry.

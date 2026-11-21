# Repository Structure & State Management

> **Purpose:** Guides AI coding agents on directory navigation, state key conventions, environment variables, and preventing monorepo state corruption.

---

## 1. Directory Layout

```text
.                                 # Core SaaS Platform root (Terraform config + state)
├── backend-<env>.hcl             # Environment remote state backends (dev, staging, prod)
├── environments/                 # Centralized tfvars for ALL roots
│   ├── dev.tfvars
│   ├── staging.tfvars
│   ├── prod.tfvars
│   ├── data-platform-prod.tfvars
│   └── ai-platform-prod.tfvars
├── modules/                      # Shared reusable library modules
│   ├── networking/               # Multi-AZ VPC, subnets, route tables, Flow Logs
│   ├── security/                 # WAFv2, Security Groups, IAM Roles
│   ├── compute/                  # ECS Fargate clusters, task definitions
│   ├── database/                 # Aurora Serverless v2 PostgreSQL/MySQL
│   ├── cache/                    # ElastiCache Redis / Valkey with SSM AUTH
│   ├── kms/                      # Customer Managed Keys with annual rotation
│   └── storage/                  # Encrypted S3 buckets with Object Lock
├── data-platform/                # Data Enclave root (independent state)
├── ai-platform/                  # AI Gateway root (independent state)
│   └── tests/                    # Native Terraform 1.6+ tests (*.tftest.hcl)
├── deploy.sh                     # Orchestrated multi-root CLI entrypoint
└── docs/                         # System Design Documents (SDD) & Compliance Specs
```

---

## 2. Multi-Root State Key Conventions

All states are stored in an encrypted remote S3 backend with DynamoDB locking. State keys must strictly adhere to prefix isolation:

| Platform Root | Remote S3 State Key Pattern |
| :--- | :--- |
| **Core SaaS Platform** | `s3://${STATE_BUCKET}/core-platform/${ENV}/terraform.tfstate` |
| **Data Platform** | `s3://${STATE_BUCKET}/data-platform/${ENV}/terraform.tfstate` |
| **AI Gateway Platform** | `s3://${STATE_BUCKET}/ai-gateway/${ENV}/terraform.tfstate` |

---

## 3. Agent Rules for Shared Modules

* **Shared Module Immutability:** When modifying shared modules in `modules/`, agents must never introduce breaking changes or mandatory new variables without defaults, as doing so breaks CI plans across unrelated platforms.
* **Non-Overlapping CIDR Map:** Agents allocating new subnets or VPC peerings must strictly verify against the global non-overlapping CIDR map:
  * `10.30.0.0/16` — Core Platform Staging
  * `10.40.0.0/16` — Core Platform Production
  * `10.41.0.0/16` — Data Platform Production
  * `10.50.0.0/16` — AI Gateway Platform Production
  * `10.200.0.0/16` — Shared Tooling & CI/CD Runners

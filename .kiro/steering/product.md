# Product Context & Scope Boundary

> **Purpose:** Grounds autonomous AI coding agents (Kiro, Cursor, Claude Code, Antigravity) in the exact operational scope, architecture topology, and regulatory standards of the enterprise infrastructure.

---

## 1. Environment & Regulatory Baseline

* **Target Cloud:** AWS Commercial (`us-east-1`, `us-west-2`) & AWS GovCloud (`us-gov-west-1`).
* **Compliance Baseline:** **NIST SP 800-53 Rev. 5 (Moderate / FedRAMP High)** and **CIS AWS Foundations Benchmark v3.0**.
* **Zero-Trust Rule:** No workload in this infrastructure may bypass encryption at rest (KMS CMK), transit encryption (TLS 1.2+), or network perimeter micro-segmentation.

---

## 2. Multi-Root Architecture Topology

This repository orchestrates three independent platform root configurations, each maintaining its own segregated Terraform state file to prevent catastrophic blast-radius cascade:

| Root Directory | Platform Subsystem | Scope & Blast-Radius Boundary |
| :--- | :--- | :--- |
| **`./` (Top-level)** | **Core SaaS Platform** | Multi-tier application cluster (ECS Fargate, ALB, Aurora Multi-AZ, Redis). |
| **`data-platform/`** | **Data & Analytics Enclave** | Event-driven ingestion pipelines, S3 data lake, and analytics clusters. |
| **`ai-platform/`** | **Shared AI Gateway** | Centralized LiteLLM proxy, Bedrock PrivateLink egress lock, and Arize Phoenix observability. |

---

## 3. Autonomous Agent Guardrails

1. **Never Merge Roots:** Agents must NEVER attempt to merge the independent platform roots into a single monolithic state file.
2. **Respect Blast-Radius Isolation:** Modifying files in `modules/` affects multiple downstream environments. Agents must verify changes against all dependent roots before proposing edits.
3. **Verify GovCloud Parity:** When generating infrastructure for AWS GovCloud partitions (`arn:aws-us-gov:...`), agents must verify that requested service endpoints and model ARNs exist in GovCloud before referencing them (never assume commercial AWS parity).

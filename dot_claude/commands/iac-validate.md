---
description: Validate Terraform code (fmt, validate, tflint, checkov) and report findings
---

Run a full IaC validation pass on the current Terraform code.

Steps:
1. `terraform fmt -check -recursive` — report formatting drift, do not auto-fix unless asked.
2. `terraform validate` in each module root.
3. `tflint --recursive` if tflint is installed; otherwise note it as missing.
4. `checkov -d .` if checkov is installed; surface HIGH/CRITICAL findings only.
5. Summarize findings as a table: tool | severity | resource | issue | suggested fix.
6. Do NOT run `terraform plan` or `apply` — read-only validation only.
7. End with: pass/fail verdict and a prioritized fix list.

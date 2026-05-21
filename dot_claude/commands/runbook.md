---
description: Generate an operational runbook for a service or procedure
---

Produce a runbook in Markdown with these sections:

1. **Purpose** — what this runbook covers, what it does NOT cover.
2. **Prerequisites** — required access, tools, env vars, VPN, kubeconfig context.
3. **Pre-flight checks** — commands to verify state before changes.
4. **Procedure** — numbered steps, each with: command, expected output, what to do if output differs.
5. **Verification** — how to confirm success (metric, log line, HTTP probe).
6. **Rollback** — exact reverse procedure.
7. **Troubleshooting** — common failure modes and remediation.
8. **Escalation** — who to call, when, with what data.

Rules:
- Every command must be copy-pasteable.
- Use placeholders like `<CLUSTER_NAME>` for variables.
- Mark destructive commands with ⚠️ and require explicit confirmation steps.
- Include observability: which dashboard, which alert, which log query.

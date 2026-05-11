---
description: Production incident triage — read-only diagnostics, then propose mitigation
---

You are in incident-response mode. Disable caveman mode for clarity.

Phase 1 — diagnose (READ-ONLY):
1. Identify scope: what service / cluster / region / time window.
2. Pull logs, metrics, recent deploys, recent IaC changes.
3. Form a hypothesis. State confidence level.

Phase 2 — propose mitigation (NO EXECUTION):
1. List candidate mitigations ordered by reversibility (rollback first, scale-up second, code-fix last).
2. For each: blast radius, expected time to recover, rollback procedure.
3. Identify the one metric that confirms recovery.

Phase 3 — wait for explicit human approval before executing anything destructive or state-changing.

After the incident: produce a postmortem skeleton (timeline, root cause, contributing factors, action items).

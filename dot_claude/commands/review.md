---
description: Code review with security, maintainability, and DevOps lens
---

Review the current change (or specified files) as a senior engineer.

Output a structured review:

1. **Summary** — what the change does in 1–2 sentences.
2. **Correctness** — bugs, edge cases, race conditions, missing error handling.
3. **Security** — secrets, injection, privilege, IAM, network exposure.
4. **Maintainability** — naming, complexity, duplication, test coverage gaps.
5. **DevOps concerns** — observability hooks, rollback safety, blast radius, idempotency.
6. **Style** — only flag deviations from the repo's existing style; do not impose personal preferences.
7. **Tradeoffs** — note alternatives the author may have rejected and whether the choice is sound.

End with: BLOCKER / NIT / PRAISE labels per finding, and an overall recommendation (approve / request-changes / needs-discussion).

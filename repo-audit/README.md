# Repo Audit

Audits a repository for correctness, security, architecture, performance, maintainability, and operational risk.

Use this skill when you want a broader codebase health check instead of a review limited to the current diff.

Works well with `architecture-standards` when you want audit findings and remediation plans grounded in cleaner system boundaries and design tradeoffs.

## Folder Contents

- `SKILL.md` contains the full skill instructions and trigger rules.
- `agents/openai.yaml` defines the agent configuration for the skill.
- `references/` contains stack-specific audit guidance plus calibration, severity, and audit-process references used during investigation.
- `scripts/audit-preflight.sh` collects repo and audit context before a medium/high-risk audit.

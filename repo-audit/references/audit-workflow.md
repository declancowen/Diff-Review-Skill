# Audit Workflow

Use this for full-codebase audits and re-audits.

## Start

1. Run `scripts/audit-preflight.sh` from repo root when the audit is broad, medium/high risk, long-running, includes external findings, or context is fragmented.
2. Create `.audits/` if needed.
3. Read every `.audits/*.md` file; they are the audit history and hotspot context.
4. If `.reviews/*.md` exists, scan relevant files for escaped-finding and hotspot context.
5. Determine audit scope. Default to full codebase unless the user asked for a focused scope.

Useful commands:

```bash
mkdir -p .audits
rg --files . -g '!node_modules' -g '!.git' -g '!.next' -g '!dist' -g '!build'
git status --short
git rev-parse --short HEAD
```

## Turn 1

1. Detect repo structure and stack; load relevant stack references.
2. Read foundational config and entry points: package/config, routing/API, schema/migrations, auth, data access, CI, deployment.
3. Build a repo-total audit map by capability/layer.
4. Prioritize risk areas: auth/tenancy, data ownership, contracts, async jobs, persistence/migrations, shared abstractions, infra.
5. Build audit graphs for risky/shared surfaces: producers, validators, transformers, persistors, consumers, read-side helpers, tests.
6. Assign health rating, risk score, and archetype tags.
7. Run relevant verification.
8. Write the audit file with findings, validation, residual risks, score/health, and recommendations.

## Turn 2+

1. Read all existing audit files.
2. Collect current-turn delta and current repo state.
3. Update cumulative scope and hotspot ledger.
4. Triage prior and external findings against current tree.
5. Re-read current delta files, prior open finding files, nearby resolved finding files, hotspot families, sibling surfaces, and remediation impact paths.
6. Apply resolution gate before marking anything resolved.
7. Re-run verification that proves fixes and relevant non-primary/bypass paths.
8. Audit the current repo state for new findings, not only latest patches.
9. Append newest turn at the top of the audit body and update header counts.

## Scope Guidance

For full audit, prioritize:

1. entry points and configuration
2. core business logic
3. API layer and data access
4. authentication and authorization
5. shared utilities/types/components
6. background jobs and integrations
7. infrastructure and deployment
8. tests and CI

For focused audit, stay scoped but still trace surrounding context enough to understand blast radius.

## Code Context Standard

For each high-risk area:

- read the full file
- trace dependencies, callers, consumers, and downstream handlers
- inspect shared types, schemas, validators, permissions, config, and tests
- follow the flow end to end
- review deletions/moved code/removed guards like additions
- search for sibling patterns once a risk is found

## MCP / External Context

Use connected MCP/app context read-only when it materially improves audit quality: GitHub PRs/CI, docs, database schema/RLS, architecture docs, linked issues, or production configuration. If unavailable but needed, record the gap.

## External Findings

When findings are pasted from GitHub/Devin/CI/security tools/users:

- load `external-finding-import.md`
- classify current-tree status
- load `bug-class-taxonomy.md`
- write a miss retrospective if a prior audit should have caught it

## Recertification

Every 5 turns or after a major fix cluster, do a repo-risk recertification:

- what remains highest risk?
- what bug family is most likely under-audited?
- what previously fixed area should be rechecked?
- what has not been re-verified recently enough?

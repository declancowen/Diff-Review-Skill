# Architecture Scorecard

Use this for whole-repo architecture reviews or repo audits. It helps produce a governance-quality assessment without turning the skill into a documentation exercise.

Score each area:

- **0:** absent or actively harmful
- **1:** inconsistent, mostly convention-based
- **2:** mostly sound, some gaps
- **3:** strong and enforceable

## Score Areas

### Capability Boundaries

- modules map to business capabilities or clear platform responsibilities
- public interfaces are narrow
- cross-boundary reach-through is rare or impossible

### Dependency Direction

- inner policy does not depend on frameworks, transport, vendor SDKs, or UI
- imports reflect intended layers
- cycles are absent or contained

### Data Ownership

- each data model has a clear owner
- authoritative writes are centralized
- caches/read models/fallbacks are not shadow sources of truth

### Contract Ownership

- API/event/schema contracts have clear owners
- create/update/import/direct mutation paths are aligned
- compatibility is explicit where old clients/data exist

### Security And Tenancy

- authn/authz are enforced server-side
- tenant/scope boundaries are explicit in lookups and mutations
- secrets and sensitive data stay at safe boundaries

### Async And Reliability

- retries are idempotent
- partial failure is handled
- important jobs/streams have visibility and recovery

### Operability

- critical flows have useful logs, metrics, traces, status, or alerts
- failure ownership is clear
- rollout/rollback paths are realistic

### Testability

- core rules are testable without full stack
- boundary and compatibility tests exist where risk justifies them
- tests protect architectural invariants, not only happy paths

### Evolvability

- architecture debt is visible enough to manage
- exceptions have cleanup paths
- new features can follow existing patterns without guessing

## Output Format

```markdown
| Area | Score | Evidence | Main risk | Next action |
|------|-------|----------|-----------|-------------|
| Data ownership | 2 | writes mostly centralized, fallback path drift exists | stale read model authority | add reconciliation guard/test |
```

## Interpretation

- Any `0` in security, data ownership, contract ownership, or async reliability is a high-priority architecture risk.
- Repeated `1`s indicate governance drift: the architecture relies on humans remembering rules.
- A `3` should have enforcement evidence, not just tidy folders.

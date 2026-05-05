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
- duplication/refactor evidence does not show the same capability concept scattered across unrelated modules

### Dependency Direction

- inner policy does not depend on frameworks, transport, vendor SDKs, or UI
- imports reflect intended layers
- cycles are absent or contained
- static/import checks or architecture tests protect important boundaries when drift has happened before

### Data Ownership

- each data model has a clear owner
- authoritative writes are centralized
- caches/read models/fallbacks are not shadow sources of truth
- bootstrap, seed, fixture, recovery, and migration paths preserve the same ownership rules as normal writes

### Contract Ownership

- API/event/schema contracts have clear owners
- create/update/import/direct mutation paths are aligned
- compatibility is explicit where old clients/data exist
- CLI, webhook, docs/import/export, and generated-client contracts are not duplicated in unowned shapes

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
- shared test helpers preserve runtime semantics and do not hide unclear architecture

### Evolvability

- architecture debt is visible enough to manage
- exceptions have cleanup paths
- new features can follow existing patterns without guessing
- broad analyzer inventories are classified into fixed, deferred, accepted, policy-modeled, deployment-gated, and inventory-only states

### Current-State Fitness

- actual code shape matches the claimed architecture
- duplication, complexity, churn, and module-size signals do not contradict the score
- target-state plans include transition slices and containment gates
- accepted baselines, suppressions, and allowlists have owners and revisit triggers

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
- A high target-state score is not credible if current-state fitness is low. Diagnose why the target architecture is not being expressed in the code before declaring the repo architecturally healthy.

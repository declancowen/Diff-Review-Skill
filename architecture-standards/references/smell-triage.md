# Architecture Smell Triage

Use this when reviewing a repo or deciding whether a local code smell deserves architectural action.

## Triage Buckets

### Must Fix Now

Use when the smell is actively causing or likely to cause correctness, security, data, operability, or high-change-cost problems.

Signals:

- business rule exists in multiple inconsistent places
- auth/tenancy/permission rule is only enforced in UI or transport
- shared state has multiple writers with no authority
- async workflow has no idempotency/recovery and handles important work
- persistence constraint is missing for a true invariant
- direct/bypass path violates the intended architecture

Action:

- fix the boundary or authoritative rule now
- add a prevention artifact: test, schema, guard, static rule, or dependency boundary

### Should Fix If Cheap/Safe

Use when the smell is not a live bug but is near active work and cheap to correct.

Signals:

- local duplication around a rule already being touched
- small helper extraction would remove repeated risky logic
- missing test for an invariant being modified
- unclear module placement causing repeated small confusion

Action:

- fix only if scope stays bounded and risk is low
- otherwise record as follow-up

### Defer

Use when the issue is real architecture debt but broad remediation would distract from current work.

Signals:

- large module split with unclear payoff
- broad renaming/reorganization
- idealized layering refactor without immediate risk
- replacing an architecture that is ugly but stable

Action:

- do not smuggle into a feature fix
- record the trigger condition that would make it worth doing

## Common Smells And Proper Response

### Business Logic In UI/Route

Question:

- Is it just presentation/shape validation, or a durable business invariant?

Response:

- move durable policy inward
- keep UI helper validation only as user guidance

### Generic Shared Helper

Question:

- Is this truly cross-cutting, or a hidden business rule?

Response:

- if business-specific, move to owning capability/domain
- if cross-cutting, keep API narrow and behavior explicit

### Multiple Sources Of Truth

Question:

- Which state is authoritative, and what reconciles the rest?

Response:

- centralize writes
- add reconciliation/invalidations
- prevent fallback/cache from becoming authority

### Boundary Bypass

Question:

- Who can mutate or read around the intended interface?

Response:

- route bypasses through the same application/domain rule
- add static/import checks when bypass is likely to recur

### God Service

Question:

- Is the service mixing orchestration, policy, persistence, transport mapping, and infrastructure?

Response:

- extract by responsibility only where it reduces live risk or current change cost
- do not split mechanically by pattern name

### Premature Abstraction

Question:

- What variation point does the abstraction protect?

Response:

- inline if there is one implementation and no boundary reason
- keep abstraction if it protects vendor/framework/test boundary

### Missing Operational Owner

Question:

- Who sees and repairs failures?

Response:

- add status, logs, metrics, DLQ, retry policy, or runbook only where the workflow is important enough

## Final Check

Before recommending architectural work, answer:

- what concrete risk does this remove?
- why is now the right time?
- what is the smallest safe boundary improvement?
- how will code prevent the smell from returning?

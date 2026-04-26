# Decision Framework

Use this when choosing architecture shape or explaining a meaningful implementation decision.

## Operating Stance

- Start from business capability, user journey, data sensitivity, failure consequence, and ownership, not framework preference.
- Prefer the simplest design that keeps a clean upgrade path.
- Separate policy from mechanism: business rules belong inward; frameworks, vendors, protocols, storage, and UI belong at edges.
- Respect coherent existing architecture. Improve incrementally unless it is actively causing harm.
- Optimize for evolvability: clear ownership, safe change, testability, and operability under expected growth.

## Frame The Problem

Before designing, identify:

- business capability being implemented
- actors, systems, and teams that depend on it
- greenfield vs extension vs refactor
- critical user journeys and failure consequences
- throughput, latency, concurrency, data volume, and growth expectations
- data sensitivity, compliance, auditability, and tenancy model
- operational expectations: uptime, recovery, support, on-call
- integration surface: modules, queues, third-party APIs, reporting, search, storage, background work

If information is missing, state minimal assumptions. Do not design around speculative complexity.

## Proportionality Rule

Increase rigor when:

- failure has financial, legal, operational, security, or reputational cost
- sensitive/regulated data or tenancy is involved
- code sits on a hot path or supports high scale/low latency
- rules are complex, cross-cutting, or likely to change
- multiple teams need clear ownership
- external systems or async workflows are involved
- operability, auditability, or resiliency matter as much as delivery

Reduce ceremony when:

- the change is local, low risk, and short-lived
- code is a thin adapter over an established core
- rules are simple enough that extra layers add mostly indirection

Even in small work, keep boundary clarity, data correctness, and testability intact.

## Decision Output

For material decisions, make these clear through code or final answer:

- **Decision:** what shape was chosen
- **Owner:** which module/layer owns the invariant
- **Reason:** requirement, risk, or constraint driving it
- **Tradeoff:** simpler option rejected and why
- **Enforcement:** tests, types, schemas, guards, boundaries, or tooling
- **Revisit trigger:** assumption that would change the design

Avoid vague "best practice" claims. Name the concrete boundary or risk.

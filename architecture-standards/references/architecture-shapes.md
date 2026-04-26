# Architecture Shapes

Use this when choosing the structural shape of a system, subsystem, or major feature.

## Modular Monolith vs Microservices

Default to a modular monolith with strong internal boundaries.

Use a modular monolith when:

- domain boundaries are still evolving
- one team or aligned teams own most of the system
- transactional consistency across capabilities matters
- operational simplicity is more valuable than deployment independence
- clean seams for later extraction are enough today

Escalate to microservices only when several are true:

- parts need materially different scaling characteristics
- teams need independent release cadence
- boundaries and data ownership are already well understood
- fault isolation has real business value
- runtime, compliance, or availability needs differ by capability

Avoid microservices when services share a database, chat synchronously constantly, or the team lacks observability/deployment/incident maturity.

## Sync vs Async

Default to synchronous request-response for short, interactive flows.

Use async workflows, queues, streams, or jobs when:

- work is long-running, bursty, failure-prone, or fan-out heavy
- the user does not need immediate completion
- retries, replay, backpressure, or decoupling materially improve robustness

If async is chosen, define:

- delivery guarantees
- idempotency
- retry/dead-letter behavior
- ordering assumptions
- visibility into stuck, repeated, or poisoned work

Avoid async when immediate correctness/feedback matters or the team cannot operate the async system.

## CRUD/Transaction Script vs Richer Domain Model

Default to straightforward service/transaction-script style when rules are simple.

Use richer domain modeling when:

- invariants must hold across many entrypoints
- policies/calculations/workflows are central and durable
- business language should be explicit in code
- the same rules must be reused consistently

Avoid rich modeling when it wraps trivial CRUD or creates pseudo-DDD ceremony.

## Single Model vs Read Models/CQRS

Default to one model unless read/write needs diverge materially.

Use read models, projections, or CQRS when:

- query workloads are heavier or structurally different from writes
- search/reporting/dashboards need different shapes
- write model is being distorted for read performance

If split, define freshness guarantees, ownership, rebuild strategy, and failure/reconciliation behavior.

## REST vs GraphQL vs RPC

Choose the simplest contract style matching the interaction model.

- **REST:** resources and state transitions map well; HTTP semantics and predictability matter.
- **GraphQL:** clients need flexible graph traversal and tailored payloads; team can manage resolver performance and authorization.
- **RPC/action APIs:** operations are action-centric or internal commands benefit from explicit method semantics.

Avoid exposing persistence shapes or proliferating ad hoc actions without contract governance.

## One Datastore vs Polyglot Persistence

Default to one primary source of truth.

Add specialized stores when they solve a distinct problem:

- search/ranking
- document-shaped access
- ephemeral fast lookup
- analytics/reporting projections

Avoid duplicating truth without ownership, synchronization, rebuild, and consistency rules.

## Inline vs Queue-Backed Jobs

Keep work inline when it reliably fits request budgets and user-visible completion matters.

Move to jobs when:

- request budget may be exceeded
- spikes need smoothing
- retries/backoff are important
- fan-out or batch handling improves resilience

Do not background user-critical work without delivery guarantee, idempotency, status visibility, and recovery path.

## Abstractions And Indirection

Introduce abstractions at real seams:

- vendor/framework independence
- policy/mechanism boundary
- environment/provider variation
- meaningful testability boundary
- repeated stable variation point

Avoid wrappers that hide ownership or abstract a single concrete call without a real seam.

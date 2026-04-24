---
name: architecture-standards
description: Use this skill when designing system architecture, scaffolding a new application, service, or feature, refactoring toward cleaner boundaries, or reviewing code for architectural quality. It provides practical standards and concrete patterns across presentation, application, domain/business, data, infrastructure, and API layers, including when to use or avoid common patterns so solutions remain secure, scalable, operable, and maintainable without over-engineering.
---

# Architecture Standards

Use this skill to guide architecture design, solution scaffolding, implementation choices, and code review when the goal is to build software that can survive real scale, changing requirements, operational pressure, and team growth.

Everything this skill needs is in this file. Apply it proportionally. Be opinionated about boundaries, quality attributes, and operational realities, but do not cargo-cult patterns just to make code look "enterprise".

## How to apply this skill

When this skill is triggered:

1. Frame the problem in business and operational terms.
2. Choose an architecture shape that is proportionate to the problem.
3. Define module boundaries and dependency direction.
4. Apply the appropriate patterns by layer.
5. Check cross-cutting concerns: security, performance, resilience, observability, testability, and cost.
6. State the main tradeoffs, rejected options, and assumptions that could change the design later.

When writing code, prefer the simplest design that keeps a clean upgrade path. When reviewing code, prioritize boundary violations, risky coupling, operational blind spots, and patterns that will fail under growth.

## Operating stance

- Start from business capability, user journeys, data sensitivity, and failure consequences, not frameworks.
- Favor a horses-for-courses approach. Tighten rigor for high-risk, high-scale, compliance-sensitive, or cross-team work. Stay lighter for small, local changes, but never relax core security, correctness, or ownership.
- Separate policy from mechanism. Business rules belong inward; frameworks, vendors, protocols, and storage engines belong at the edges.
- Favor cohesion before distribution. A well-structured modular monolith is usually better than premature microservices.
- Prefer explicit tradeoffs over hand-wavy generalities. If a decision matters to scale, security, reliability, or maintainability, explain why it was chosen.
- Respect an existing coherent architecture. Improve it incrementally unless it is actively causing harm.
- Optimize for evolvability, not theoretical purity. The best architecture is the one that is easy to understand, safe to change, and credible under expected load and team growth.

## Frame the problem first

Before designing, scaffolding, or refactoring, identify:

- What business capability is being implemented.
- Which actors, systems, or teams depend on it.
- Whether the work is greenfield, an extension, or a refactor.
- The main user journeys, critical paths, and failure consequences.
- Expected throughput, latency, concurrency, data volume, and growth rate.
- Data sensitivity, compliance obligations, auditability needs, and tenancy model.
- Operational expectations: uptime, recovery expectations, support burden, on-call impact.
- Ownership model: one team, several teams, or several independently releasing teams.
- Integration surface: internal modules, queues, third-party APIs, reporting, search, storage, and background processing.

If information is missing, state the minimum assumptions necessary. Avoid locking the design to speculative complexity.

## Proportionality rule

Increase architectural rigor when one or more of these are true:

- Failure has high financial, legal, operational, or reputational cost.
- Sensitive or regulated data is involved.
- The code sits on a hot path or must support high scale or low latency.
- Business rules are complex, cross-cutting, or likely to change often.
- Multiple teams need clear ownership and independent evolution.
- The solution depends on several external systems or asynchronous workflows.
- Operability, auditability, or resiliency matter as much as raw feature delivery.

Reduce ceremony when one or more of these are true:

- The change is tightly local and low risk.
- The code is a thin adapter over an established core.
- The lifetime is short and the blast radius is genuinely small.
- The rules are simple enough that additional layers would mostly add indirection.

Even for smaller work, keep boundary clarity, data correctness, and testability intact.

## Choose the architecture shape

Use the lightest architecture that keeps the system correct, operable, and evolvable.

### Modular monolith vs microservices

Default:

- Prefer a modular monolith with strong internal boundaries.

Use a modular monolith when:

- The domain is still evolving.
- One team or a small number of aligned teams owns most of the system.
- Transactional consistency across capabilities matters.
- Operational simplicity is more valuable than deployment independence.
- You want clean seams for later extraction without distributed-systems overhead today.

Escalate to microservices only when several of these are true:

- Parts of the system need materially different scaling characteristics.
- Teams need strong ownership with independent release cadences.
- Boundaries and data ownership are already well understood.
- Fault isolation has real business value.
- Runtime, compliance, or availability requirements differ by capability.

Avoid or defer microservices when:

- Services would share a database.
- The system would rely on heavy synchronous chat between services.
- The team lacks maturity in observability, deployment automation, incident handling, and contract governance.
- Distribution is being chosen for fashion, not a real constraint.

Common failure modes:

- Slicing by technical layer instead of business capability.
- Creating services that are operationally independent only on paper.
- Using network calls to replace what should have been local module calls.

### Synchronous flows vs asynchronous workflows

Default:

- Prefer synchronous request-response for short, interactive, easy-to-reason-about flows.

Use asynchronous messaging, queues, or jobs when:

- Work is long-running, bursty, or failure-prone.
- The user does not need immediate completion.
- Retries, replay, backpressure, or fan-out materially improve robustness.
- Side effects should be decoupled from the request path.

Avoid async by default when:

- The workflow is simple and immediate feedback matters.
- The team cannot support the operational model of queues, retries, dead letters, and replay.
- Eventual consistency would materially degrade user experience or business correctness.

If async is chosen, define:

- Delivery guarantees.
- Idempotency rules.
- Retry and dead-letter behavior.
- Ordering assumptions.
- Visibility into stuck, repeated, or poisoned work.

Common failure modes:

- Using async to look advanced rather than to solve a concrete problem.
- Publishing events without ownership, schema governance, or consumer expectations.
- Ignoring duplicate delivery and replay.

### CRUD/service style vs richer domain model

Default:

- Prefer straightforward service or transaction-script style when rules are simple.

Use a simple CRUD or service style when:

- Most work is create, read, update, delete.
- Validation is local and straightforward.
- Business logic is limited and low-risk.
- The code benefits more from clarity than from modeling sophistication.

Use richer domain modeling when:

- Invariants must hold across many entrypoints.
- Policies, calculations, or workflows are central and durable.
- Business language should be explicit in code.
- The same rules must be reused consistently across several use cases.

Avoid rich modeling when:

- The domain is trivial and the model would mostly be wrapper boilerplate.
- Teams would use domain terminology incorrectly and create pseudo-DDD theater.

Common failure modes:

- Anemic "entities" that are really just records.
- Business rules spread across controllers, SQL, jobs, and UI code.
- Over-modeling small CRUD features into needless indirection.

### Single model vs CQRS and read models

Default:

- Keep a single model unless read and write needs diverge materially.

Use separate read models, projections, or CQRS when:

- Query workloads are much heavier or structurally different from write workloads.
- Search, reporting, or dashboards need different shapes from transactional writes.
- The write model becomes brittle because it is being bent to satisfy read performance.

Avoid CQRS when:

- It mostly adds operational complexity without solving an actual mismatch.
- Freshness requirements are unclear.
- Teams are not ready to reason about eventual consistency.

Common failure modes:

- Splitting reads and writes too early.
- Failing to define freshness guarantees.
- Creating duplicated models with unclear ownership.

### REST vs GraphQL vs RPC

Default:

- Prefer the simplest contract style that matches the interaction model.

Use REST when:

- Resources and state transitions map well to endpoints.
- Standard HTTP semantics, caching, and broad interoperability matter.
- Simplicity and predictability are priorities.

Use GraphQL when:

- Clients need flexible graph traversal and tailored payloads.
- Many UI surfaces need different slices of related data.
- The team can manage schema governance, resolver performance, and authorization rigor.

Use RPC or action-oriented APIs when:

- Operations are naturally action-centric rather than resource-centric.
- Internal service contracts benefit from explicit method semantics.

Avoid choosing an API style purely for trendiness. Pick the one that keeps contracts clear, secure, operable, and appropriately evolvable.

Common failure modes:

- REST endpoints that are really ad hoc RPC.
- GraphQL schemas that leak backend complexity or create resolver N+1 problems.
- RPC methods that proliferate without coherent contract governance.

### One datastore vs polyglot persistence

Default:

- Prefer one primary system of record and add specialized stores only when they solve a distinct problem.

Use a relational store by default when:

- Transactions, integrity, structured queries, and consistency matter.

Use specialized stores when:

- Search engines are needed for search, ranking, or analytics-style querying.
- Document stores better match document-shaped access and flexible schema needs.
- Key-value stores or caches solve fast lookup or ephemeral acceleration problems.

Avoid polyglot persistence when:

- It is compensating for poor schema or query design in the primary store.
- Data would be duplicated without clear ownership or synchronization strategy.

Common failure modes:

- Treating a cache or search index as the source of truth.
- Spreading domain truth across several stores without consistency rules.
- Choosing exotic storage before measuring the real bottleneck.

### Inline processing vs queue-backed jobs

Default:

- Keep work inline when it reliably fits the request budget and the user needs immediate completion.

Move work to jobs when:

- Processing may exceed request time budgets.
- Spikes need smoothing.
- Retries and backoff are important.
- Fan-out or batch handling improves throughput or resilience.

Avoid background jobs when:

- The workflow must commit atomically with the user-visible action.
- The team lacks monitoring and recovery paths for job failures.

Common failure modes:

- Backgrounding work without a delivery guarantee or idempotent handler.
- Hiding user-critical failure behind "eventual completion" with no status visibility.

### Abstractions and indirection

Default:

- Introduce abstractions at real architectural seams, policy boundaries, or repeated variation points.

Use interfaces, ports, adapters, or pluggable strategies when:

- Inner layers need to stay independent of vendors or frameworks.
- Behavior varies by environment or provider.
- Testability materially improves by isolating the mechanism from policy.

Avoid abstraction when:

- It merely wraps a single concrete call without protecting any meaningful boundary.
- It obscures behavior more than it generalizes it.

Common failure modes:

- "Enterprise" wrappers around everything.
- Generic helpers, managers, and services that hide ownership.
- Adding interfaces for code that has only one stable implementation and no architectural reason to vary.

## Module and dependency rules

- Define modules around business capability, ownership, and change boundaries, not only around technical file types.
- A good default is: split by capability first, then by layer within the capability where that adds clarity.
- Outer layers may depend inward. Inner layers must not depend outward.
- Frameworks, SDKs, transport types, and vendor APIs belong at the edges.
- Define interfaces in the layer that owns the policy, not in the adapter layer.
- Cross-module access should go through published interfaces, application services, or deliberate events, not direct reach-through into another module's internals.
- One service should not read or mutate another service's private datastore directly.
- Shared libraries are acceptable only for truly cross-cutting primitives, not as a dumping ground for business logic.
- Avoid catch-all `services`, `helpers`, `managers`, and `utils` directories that mix unrelated responsibilities under vague names.

Healthy internal structures often look like this, even if folder names differ:

```text
capability/
  presentation/
  application/
  domain/
  data/
  infrastructure/
```

For frontend-heavy work, an equivalent might be:

```text
feature/
  ui/
  application/
  domain/
  data/
```

The exact folders matter less than responsibility clarity.

## Patterns and standards by layer

### Presentation layer

Responsibilities:

- Handle transport and delivery concerns: HTTP, GraphQL, RPC, CLI, UI, message entrypoints.
- Validate request shape and basic contract constraints.
- Translate transport input into application commands or queries.
- Format responses, views, emitted messages, or user-facing state.

Default patterns:

- Thin controllers, handlers, and route modules.
- UI components focused on rendering and interaction.
- Transport DTOs or view models at the edge.
- Route- or page-level composition that delegates real work inward.
- Server-side enforcement for authn and authz, even if the client also hides or disables actions.

Use when:

- Use container vs presentational separation when the UI has complex orchestration and presentational reuse would otherwise suffer.
- Use a Backend for Frontend when client-specific aggregation, auth mediation, or payload shaping materially reduces client complexity or chattiness.
- Use optimistic UI only when failure handling and reconciliation are designed deliberately.
- Parallelize independent data fetches at the composition boundary when latency matters and the calls are truly independent.

Avoid when:

- Business policy, pricing rules, entitlement logic, or workflow state transitions start living in components, controllers, or route handlers.
- UI code directly talks to the database or low-level infrastructure clients.
- Parallelization would violate ordering, increase rate-limit pressure, or make errors harder to reason about.

Common failure modes:

- Controllers that call several repositories directly.
- Waterfall fetching that creates avoidable latency.
- Authorization implemented only in the UI.
- DTO, API, and domain types collapsed into one shape for convenience.

### Application layer

Responsibilities:

- Own use cases, workflow orchestration, transaction boundaries, authorization decisions, idempotency, and coordination across ports.
- Call domain logic and infrastructure through deliberate boundaries.

Default patterns:

- Use-case handlers, application services, command handlers, or transaction scripts.
- A clear command path for mutations and a query path for reads when that improves clarity.
- Explicit transaction boundaries around consistency-sensitive work.
- Deliberate orchestration for side effects, retries, and background handoff.

Use when:

- Use command/query separation when write-side invariants and read-side optimization differ, even if you do not adopt full CQRS.
- Parallelize independent downstream reads or remote calls when latency matters, dependencies are independent, and bounded concurrency is acceptable.
- Use idempotency keys or dedupe tokens on retried or externally-triggered operations.
- Use a workflow engine, state machine, or process manager when a business process is long-lived, stateful, or spans several steps that must remain coherent over time.
- Use saga or compensating action patterns when a distributed workflow cannot be made atomic and failures must be unwound or repaired.

Avoid when:

- Application services start owning durable business policy that belongs in the domain.
- Handlers turn into giant god classes that own transport mapping, validation, persistence, and business rules all at once.
- Parallelization would race on shared mutable state, exceed pool limits, or create confusing partial-failure behavior.
- A saga is being proposed for a simple local transaction that should stay synchronous and atomic.

Common failure modes:

- One generic `FooService` per feature that owns everything.
- No clear transaction boundary.
- Side effects triggered before the core state change is durably committed.
- Background work launched opportunistically with no delivery guarantee.

### Domain or business layer

Responsibilities:

- Own invariants, policies, calculations, business language, state transitions, and rules that must stay correct regardless of delivery mechanism.

Default patterns:

- Entities and value objects where behavior and invariants belong with the model.
- Domain services for rules that do not fit naturally on one entity but are still business-level policy.
- Aggregates or consistency boundaries where multiple objects must change coherently.
- Domain events for meaningful business facts inside the domain model.

Use when:

- Use value objects when identity is irrelevant and correctness depends on constraints or behavior attached to a concept such as Money, EmailAddress, DateRange, or Percentage.
- Use aggregates when invariants must be enforced atomically across related state.
- Use domain events when downstream domain behavior should react to a business fact without tight temporal coupling.
- Use specifications or policy objects when complex decision logic needs reuse and explicit naming.

Avoid when:

- Rich domain modeling would mostly wrap simple CRUD.
- Domain types depend on frameworks, ORMs, web request objects, or vendor SDKs.
- Domain events are used as a vague substitute for normal method calls inside a single simple flow.

Common failure modes:

- Anemic domain models that carry data but no rules.
- Business logic implemented only in SQL, controllers, or jobs.
- Aggregates made too large, causing locking, contention, or awkward transactional scope.
- "Domain services" used as a dumping ground for everything hard to place.

### Data layer

Responsibilities:

- Own schema, migrations, indexing, querying, persistence mapping, retention, partitioning, and read/write access patterns for stored data.

Default patterns:

- Repositories for aggregate or write-model persistence when they protect useful boundaries.
- Query services or read repositories for query-heavy views that do not map cleanly to aggregates.
- Explicit migrations and schema evolution strategy.
- Deliberate indexing based on real query patterns.
- Cursor pagination for large, mutable user-facing lists.

Use when:

- Batch related reads or writes when it removes N+1 patterns or reduces network/database roundtrips.
- Use projection or read models when query shapes differ materially from write shapes.
- Use offset pagination for small, stable admin or internal lists where simplicity matters more than absolute scalability.
- Use cursor pagination for large, frequently changing datasets where stable traversal matters.
- Use soft delete only when recovery, legal, or audit requirements justify it, and pair it with purge and indexing strategy.
- Use partitioning, archival, or tiered storage when data volume and retention needs would otherwise degrade core workloads.
- Use read replicas when read scale matters and some staleness is acceptable.
- Use schema-per-tenant or database-per-tenant isolation only when compliance, noisy-neighbor risk, or operational boundaries justify the added cost over row-level tenancy.

Avoid when:

- Persistence models leak directly into APIs or domain logic by default.
- Every module or service queries every table directly.
- Repository abstractions hide important query behavior or make performance impossible to reason about.
- Caching is used to mask a bad schema or poor indexing strategy.

Common failure modes:

- N+1 queries.
- Full-table scans on hot paths.
- Over-fetching entire records when a projection would do.
- Missing unique constraints or indexes for true invariants.
- Unbounded queries, unbounded page sizes, or loading entire datasets into memory.
- Cross-service joins through a shared database.

### Infrastructure layer

Responsibilities:

- Own technical mechanisms for databases, queues, caches, search, object storage, email, third-party APIs, observability, and configuration.

Default patterns:

- Ports and adapters where inner layers define the capability and outer layers implement it.
- Timeouts on outbound calls.
- Retries with backoff and jitter for transient failures.
- Configuration and secrets externalized from code.
- Mapping between vendor models and internal models at the edge of the adapter.

Use when:

- Use circuit breakers or adaptive throttling when an unstable dependency can otherwise create cascading failure.
- Use bulkheads or resource isolation when one dependency or workload should not exhaust shared pools.
- Use an outbox when state changes and event publication must remain consistent without distributed transactions.
- Use idempotent consumers, dedupe tables, or inbox patterns when processing retried or at-least-once messages.
- Use connection pooling, pooling limits, and bounded concurrency to protect downstream systems.

Avoid when:

- Vendor response models, SDK types, or exceptions leak deep into inner layers.
- Retry logic is applied to non-idempotent operations without safeguards.
- Infrastructure adapters start deciding business rules.
- Circuit breakers, retries, and queues are added blindly without operability and tuning.

Common failure modes:

- No timeout on outbound calls.
- Retry storms that amplify outages.
- Events published after commit attempts without a reliable publication mechanism.
- Adapters that hide too much and make failure behavior opaque.

### API and integration layer

Responsibilities:

- Own external contracts, endpoint semantics, event schemas, webhook payloads, versioning, error models, pagination, filtering, rate limits, and compatibility guarantees.

Default patterns:

- Deliberate boundary DTOs, not raw persistence models.
- Consistent error taxonomy and error response shape.
- Stable naming and versioning rules.
- Explicit authn/authz semantics at the contract boundary.
- Idempotency for externally retried unsafe operations.

Use when:

- Use explicit contract versioning when breaking changes cannot be avoided.
- Use additive evolution first where possible.
- Use idempotency keys for create or action endpoints likely to be retried by clients, gateways, or network intermediaries.
- Use signature verification, timestamp checking, and replay protection for webhooks.
- Use rate limiting or quota controls where abuse, accidental fan-out, or cost blowups are realistic.
- Use a BFF for client-specific contract shaping when several clients would otherwise each reconstruct the same orchestration.
- Distinguish commands from events: commands express intent to do something; events record that something has happened.

Avoid when:

- Public contracts expose table shapes, ORM entities, or internal enum names.
- API semantics are inconsistent across endpoints.
- Events are emitted with vague names or without ownership and schema evolution policy.

Common failure modes:

- Offset pagination on large mutable timelines.
- Missing idempotency for retried create operations.
- Error handling that varies arbitrarily across endpoints.
- Webhook consumers that trust unsigned payloads or are not replay-safe.

## Cross-cutting patterns and standards

### Security and privacy

- Enforce authentication and authorization on the server side.
- Prefer least privilege by default for users, services, jobs, and infrastructure roles.
- Default to deny unless access is explicitly allowed where the risk profile justifies it.
- Use RBAC for broad role-based access; add ABAC or relationship-aware policies when access depends on resource attributes, ownership, hierarchy, or tenant context.
- Validate input at the edge for shape and type, then enforce business rules inward.
- Encode or sanitize output where injection risks exist.
- Keep secrets out of code, logs, and client bundles.
- Encrypt sensitive data in transit and at rest where required by risk or compliance.
- Minimize collection and retention of sensitive data.
- Design audit logs deliberately for high-risk actions.
- Make tenancy isolation explicit. Do not rely on convention alone for tenant scoping.

Common failure modes:

- Authorization checks scattered inconsistently across handlers.
- Sensitive fields leaked in logs or analytics.
- Security implemented only in the frontend.
- A multi-tenant system with accidental cross-tenant query paths.

### Performance and scale

- Define latency budgets and throughput expectations for critical paths.
- Remove waterfall and N+1 patterns before adding caches.
- Parallelize only truly independent work, and do it with bounded concurrency.
- Batch reads and writes when it reduces roundtrips materially.
- Use projections, partial selects, and streaming for large payloads.
- Cache only with explicit ownership, invalidation, TTL, warmup, and failure behavior.
- Use CDN or edge caching for cacheable public or semi-public content.
- Push heavy non-critical work off the request path when user experience allows.
- Measure hot paths before introducing high-complexity optimizations.

Common failure modes:

- Caching without an invalidation strategy.
- Parallelizing too much and exhausting downstream pools.
- Optimizing theoretical hot spots while ignoring measured bottlenecks.

### Reliability and resilience

- Time out external calls deliberately.
- Retry only transient failures, with backoff and jitter.
- Make retried operations idempotent.
- Protect against duplicate delivery and partial failure.
- Prefer graceful degradation over total failure when business semantics allow it.
- Use backpressure or admission control when the system can be overwhelmed.
- Keep state changes and emitted side effects consistent through transactional patterns such as the outbox where needed.
- Use compensating actions when distributed work cannot be atomic.

Common failure modes:

- Infinite or aggressive retries.
- Side effects triggered before durable commit.
- Silent data divergence after partial failure.

### Observability and operability

- Emit structured logs with stable keys.
- Capture metrics for traffic, errors, latency, and resource saturation.
- Trace critical paths across service or job boundaries.
- Carry correlation IDs across requests and background work where possible.
- Define health, readiness, and dependency checks for services that need them.
- Use alerts tied to real user or business impact rather than noisy raw thresholds.
- Make operational ownership visible: dashboards, runbooks, and incident hooks should exist for critical systems.
- Prefer feature flags for operationally sensitive rollouts when rollback risk is non-trivial.

Common failure modes:

- Logs that are verbose but not queryable.
- Metrics without actionability.
- Critical background flows with no visibility.

### Maintainability and testability

- Keep responsibilities crisp and public surfaces narrow.
- Put most logic where it can be tested cheaply and deterministically.
- Use unit tests for business rules, integration tests for boundaries, contract tests for integrations where valuable, and end-to-end tests for critical journeys.
- Use architecture tests or linting rules when dependency boundaries are important and repeatedly violated.
- Name modules after business capabilities, not generic technical buckets.
- Prefer explicitness over magic when hidden framework behavior would obscure control flow or data movement.

Common failure modes:

- Too many end-to-end tests covering what should be unit-tested.
- Shared test helpers that hide architecture problems.
- Modules that look layered in folders but are not layered in dependencies.

### Efficiency and cost

- Use infrastructure proportional to the problem.
- Avoid needless service sprawl, duplicated storage, and chatty internal APIs.
- Understand the cost of data retention, indexing, replication, fan-out, and egress.
- Design archival, retention, and purge strategies before large datasets accumulate.
- Favor simpler operational models unless added complexity buys a clear benefit.

Common failure modes:

- Splitting services before the workload justifies the overhead.
- Keeping all historical data forever with no retention policy.
- Excessive internal call chains that add cost and latency with little value.

## Architecture review checklist

Use this checklist when producing or reviewing architecture:

- Is the business capability and failure impact clear?
- Is the chosen architecture proportional, and was a simpler option considered?
- Are module boundaries based on cohesion, ownership, and change patterns?
- Are presentation, application, domain, data, infrastructure, and API concerns clearly separated?
- Are transport DTOs, domain models, and persistence models distinct where the differences matter?
- Is data ownership explicit?
- Are migrations, indexing, pagination, retention, and expensive query paths considered?
- Are authentication, authorization, tenancy isolation, and secrets handling explicit?
- Are hot paths, N+1 risks, batching opportunities, and latency budgets considered?
- Are timeouts, retries, idempotency, duplicate delivery, and partial failure handled?
- Are logging, metrics, traces, dashboards, and runbooks sufficient for critical paths?
- Can the core rules be tested without spinning up the full stack?
- Does the design create clean seams for future extraction or scaling?
- If the workload grows 10x, does the system degrade gracefully or break catastrophically?

## Anti-patterns to flag aggressively

- Business rules embedded in controllers, routes, components, ORMs, or SQL only.
- Presentation code calling databases, repositories, or vendor SDKs directly.
- One giant service class per feature that owns every concern.
- Shared helper libraries that quietly become the real business layer.
- APIs or events shaped directly from tables.
- Caches with no invalidation, TTL, ownership, or fallback behavior.
- Async workflows with no idempotency, replay strategy, status visibility, or dead-letter handling.
- Distributed services coupled through shared databases or constant synchronous chatter.
- Security or observability deferred to "later".
- Folder structures that appear layered while dependency flow remains tangled.
- Indirection added for style rather than for a real seam.

## Decision hygiene

When making or explaining a meaningful architecture decision, make the reasoning legible:

- What requirement, risk, or constraint drove the decision.
- Why the chosen pattern is proportionate.
- What simpler option was considered.
- What complexity was intentionally avoided.
- What assumption would change the design later.

These standards are guardrails, not dogma. Use them to build systems that are clear, secure, performant, operable, reusable, and durable under enterprise-scale expectations.

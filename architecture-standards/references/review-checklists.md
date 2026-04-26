# Review Checklists

Use this when reviewing architecture or implementation for architectural quality.

## Architecture Review Checklist

- Is the business capability and failure impact clear?
- Is the chosen architecture proportional, and was a simpler option considered?
- Are module boundaries based on cohesion, ownership, and change patterns?
- Are presentation, application, domain, data, infrastructure, and API concerns separated where it matters?
- Are transport DTOs, domain models, and persistence models distinct where differences matter?
- Is data ownership explicit?
- Are migrations, indexing, pagination, retention, and expensive query paths considered?
- Are authentication, authorization, tenancy isolation, and secrets handling explicit?
- Are hot paths, N+1 risks, batching opportunities, and latency budgets considered?
- Are timeouts, retries, idempotency, duplicate delivery, and partial failure handled?
- Are logs, metrics, traces, dashboards, and runbooks sufficient for critical paths?
- Can core rules be tested without spinning up the full stack?
- Does the design create clean seams for future extraction or scaling?
- If workload grows 10x, does the system degrade gracefully or break catastrophically?

## Implementation Review Checklist

- Did the code land in the capability/layer that owns the invariant?
- Did the implementation reuse the existing architecture path instead of creating a bypass?
- Is the public surface narrow enough for callers but explicit enough to avoid hidden policy?
- Are framework/vendor/transport details kept at the edge where practical?
- Is authoritative validation enforced server-side or at the owned domain/application boundary?
- Are legacy data, old callers, direct jobs/scripts, and fallback/read-model paths considered where relevant?
- Is the architecture protected by code-level enforcement: tests, types, schemas, runtime guards, lint/static rules, or dependency boundaries?
- If a temporary exception was introduced, is its cleanup path visible in code or final implementation notes?

## Anti-Patterns To Flag

- business rules embedded only in controllers, routes, components, ORMs, or SQL
- presentation code calling databases, repositories, or vendor SDKs directly
- one giant service class per feature
- shared helper libraries that become the hidden business layer
- APIs/events shaped directly from tables
- caches with no invalidation, TTL, ownership, or fallback behavior
- async workflows with no idempotency, replay, status visibility, or dead-letter handling
- distributed services coupled through shared databases or constant synchronous chatter
- security or observability deferred to "later"
- folder structures that look layered while dependencies are tangled
- indirection added for style rather than a real seam

## Decision Hygiene

For meaningful architecture decisions, state:

- requirement, risk, or constraint driving it
- why the chosen pattern is proportionate
- simpler option considered
- complexity intentionally avoided
- assumption that would change the design later
- enforcement mechanism that keeps the decision true in code

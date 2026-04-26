# Layer Standards

Use this when placing code, defining module boundaries, or reviewing dependency direction.

## Module And Dependency Rules

- Define modules around business capability, ownership, and change boundaries.
- Split by capability first, then by layer where it clarifies responsibility.
- Outer layers may depend inward. Inner layers must not depend outward.
- Frameworks, SDKs, transport types, and vendor APIs belong at edges.
- Define interfaces in the layer that owns the policy, not in the adapter layer.
- Cross-module access should go through public interfaces, application services, or deliberate events.
- One capability/service should not read or mutate another capability/service private datastore directly.
- Shared libraries are for true cross-cutting primitives, not business logic dumping grounds.
- Avoid catch-all `services`, `helpers`, `managers`, and `utils` that mix unrelated responsibilities.

Common shape:

```text
capability/
  presentation/
  application/
  domain/
  data/
  infrastructure/
```

Frontend-heavy equivalent:

```text
feature/
  ui/
  application/
  domain/
  data/
```

Folder names matter less than responsibility clarity and dependency direction.

## Presentation Layer

Owns:

- transport/delivery concerns: HTTP, GraphQL, RPC, CLI, UI, message entrypoints
- request shape validation
- mapping input to application commands/queries
- response/view formatting

Should:

- keep controllers, handlers, and route modules thin
- keep UI components focused on rendering and interaction
- enforce authn/authz server-side even if UI hides actions
- delegate real workflow/state transitions inward

Should not:

- own durable business policy
- call low-level infrastructure/database directly
- collapse DTO, API, domain, and persistence types into one shape when differences matter

## Application Layer

Owns:

- use cases and workflow orchestration
- transaction boundaries
- authorization decisions
- idempotency and side-effect coordination
- calls to domain and infrastructure through deliberate boundaries

Should:

- expose clear command/query paths where helpful
- define transaction boundaries around consistency-sensitive work
- coordinate retries, background handoff, and side effects deliberately

Should not:

- become a god service owning transport, policy, persistence, and vendor details
- launch background work without delivery guarantees where correctness matters
- parallelize work that races on shared mutable state or causes confusing partial failure

## Domain / Business Layer

Owns:

- invariants, policies, calculations, business language, state transitions

Use:

- value objects for constrained concepts
- entities/aggregates where behavior and invariants belong with the model
- domain services for business policies spanning entities
- policy/specification objects for complex reusable decisions

Should not:

- depend on frameworks, ORMs, request objects, or vendor SDKs
- hide simple CRUD behind needless modeling
- use domain events as vague substitutes for ordinary method calls

## Data Layer

Owns:

- schema, migrations, indexing, querying, persistence mapping, retention, partitioning, read/write access patterns

Should:

- enforce true invariants with datastore constraints where possible
- use repositories/query services only where they protect meaningful boundaries
- design indexes from real query patterns
- use cursor pagination for large mutable lists
- keep retention, archival, and purge strategies explicit when data volume matters

Should not:

- leak persistence models into APIs/domain by default
- let every module query every table directly
- hide important query behavior behind generic repositories
- use cache to mask poor schema/indexing

## Infrastructure Layer

Owns:

- mechanisms for databases, queues, caches, search, object storage, email, third-party APIs, observability, and config

Should:

- map vendor models/errors at the adapter edge
- use timeouts on outbound calls
- retry only with backoff/jitter and idempotency safeguards
- externalize config/secrets
- isolate vendor SDKs from inner policy layers

Should not:

- decide business rules
- leak vendor exceptions/types into domain/application logic
- hide failure behavior so much it becomes opaque

## API / Integration Layer

Owns:

- external contracts, endpoint semantics, event schemas, webhook payloads, versioning, error models, pagination, filtering, rate limits, compatibility

Should:

- use deliberate boundary DTOs
- keep error taxonomy consistent
- define authn/authz at contract boundary
- use idempotency for retried unsafe operations
- verify webhook signatures, timestamps, and replay protection
- evolve contracts additively where possible

Should not:

- expose table/ORM shapes
- vary semantics arbitrarily across endpoints
- emit vague events with no ownership or evolution policy

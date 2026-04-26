# Implementation Recipes

Use these when building code with architecture standards. They are not templates to copy blindly; they are decision recipes for common implementation shapes.

## Add A New Feature

1. Identify the capability that owns the behavior.
2. Put orchestration in the application/use-case layer or nearest existing equivalent.
3. Put durable business rules in domain/shared domain helpers, not in UI or route handlers.
4. Put persistence mapping and query shape in the data layer or existing store/repository boundary.
5. Keep UI/components focused on interaction and rendering.
6. Add tests at the cheapest layer that proves the invariant, plus one boundary test when integration risk matters.

Avoid:

- adding business rules to the first component or route touched
- creating a generic helper before there is a real variation point
- bypassing existing application/store/service flows for speed

## Add Or Change Validation

1. Decide whether the rule is shape validation, business validation, permission validation, or compatibility validation.
2. Enforce shape at the edge.
3. Enforce business/permission invariants at the authoritative layer.
4. Mirror user-friendly validation in UI, but do not make UI the authority.
5. For update paths, check legacy stored data and partial updates separately from create paths.

Avoid:

- reusing strict create schemas for update/edit paths without checking compatibility
- adding only UI validation for server-critical rules
- spreading the same min/max or enum rule across components without a shared source

## Add Or Change A Shared Component/Hook

1. Confirm it represents a stable repeated concept, not just two similar screens.
2. Define the narrowest props/API that encode behavior without leaking caller internals.
3. Keep policy out of presentational primitives unless the component owns that policy by design.
4. Check all render modes: empty, disabled, read-only, editable, loading, error, nested/transient container.
5. Add at least one consumer-level test for a non-happy-path behavior when the component is shared widely.

Avoid:

- turning screen-specific behavior into a global abstraction too early
- hiding important permission or state differences behind generic props
- creating shared components that still require every caller to duplicate policy

## Add Or Change An API/Route/Action

1. Define the command/query contract explicitly.
2. Keep transport parsing and response mapping at the edge.
3. Delegate business rules and state transitions inward.
4. Check direct/bypass callers: jobs, scripts, store actions, webhooks, imports, tests.
5. Decide idempotency and retry behavior for unsafe operations.
6. Add contract/error tests for invalid input and compatibility-sensitive paths.

Avoid:

- accepting client-controlled authoritative fields
- exposing persistence models directly
- letting route handlers become the only place business rules exist

## Add Or Change Persistence

1. Name the source of truth and ownership boundary.
2. Add schema constraints/indexes for true invariants where the datastore can enforce them.
3. Keep migrations/backfills idempotent when possible.
4. Check read model, cache, search, and projection consistency.
5. Define retention, deletion, and recovery semantics if data lifecycle changes.

Avoid:

- relying only on application code for uniqueness or tenancy invariants
- duplicating truth across stores without sync ownership
- changing stored shape without compatibility or migration strategy

## Add Or Change Background Work

1. Decide why the work is async instead of inline.
2. Define delivery guarantee, idempotency, retry, dead-letter/recovery, and visibility.
3. Ensure state changes and side effects cannot diverge silently.
4. Keep job handlers authoritative for the rules they execute; do not assume UI/route prevalidation.
5. Add tests for retry or duplicate delivery when failure matters.

Avoid:

- backgrounding user-critical work without status visibility
- non-idempotent retries
- fan-out with unclear partial-failure semantics

## Add Or Change A Cache/Fallback/Read Model

1. Name the source of truth.
2. Define freshness, invalidation, and reconciliation rules.
3. Check empty, stale, lost-access, and deleted-source cases.
4. Ensure fallback data cannot outlive the authority indefinitely.
5. Add targeted tests around merge/reconciliation if bugs would persist across refreshes.

Avoid:

- letting fallback state become a shadow source of truth
- applying optimistic overrides indefinitely
- caching without ownership or invalidation

## Add Or Change A Third-Party Integration

1. Put vendor SDK and response types at the edge.
2. Map vendor errors into internal error taxonomy.
3. Define timeout, retry, idempotency, rate-limit, and circuit-breaker behavior where relevant.
4. Keep secrets and credentials out of client bundles and logs.
5. Add contract tests or adapter tests around the mapping.

Avoid:

- leaking vendor types into domain/application layers
- retrying unsafe operations without idempotency
- coupling core business logic to provider-specific quirks

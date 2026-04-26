# Enforcement Patterns

Use this when architecture intent should be protected by code, tests, or tooling.

## Prefer Enforcement In This Order

1. **Structure:** put code in the owning module/layer so the right dependency direction is natural.
2. **Narrow interfaces:** expose commands, queries, adapters, hooks, or components that make misuse difficult.
3. **Types and schemas:** encode valid states and payloads.
4. **Runtime guards:** enforce critical invariants at authoritative boundaries.
5. **Tests:** prove invariants and representative bypass paths.
6. **Static checks:** lint, dependency rules, architecture tests, import restrictions, generated contract checks.
7. **Operational checks:** metrics, alerts, logs, dead-letter queues, migration checks.
8. **Documentation:** use only when the decision cannot be made discoverable through code or the repo already uses ADRs/docs.

## Boundary Enforcement

Use when layers or modules drift.

Options:

- package exports or index files that expose only public APIs
- import restrictions for forbidden dependency direction
- path aliases that make ownership explicit
- module-level tests that import only public surfaces
- dependency-cruiser / eslint boundaries / tsconfig project references where appropriate

Good signal:

- callers cannot reach into internals accidentally
- dependency direction is checked automatically or obvious from file structure

## Contract Enforcement

Use when UI, route, store, backend, workers, and persistence must agree.

Options:

- shared constraint module for constants
- edge schemas for transport shape
- domain validators for business invariants
- contract tests for route/API/event payloads
- generated clients/types when the repo already uses generation
- compatibility tests for update paths and legacy payloads

Good signal:

- create/update/import/direct mutation paths cannot silently diverge

## State Ownership Enforcement

Use when optimistic state, fallback data, read models, caches, or stores can drift.

Options:

- single write API for authoritative mutations
- reconciliation tests for success, failure, retry, and stale server data
- cache key helpers that include tenant/team/project scope
- explicit pending-state lifecycle helpers
- runtime guards against lower-trust authoritative fields

Good signal:

- stale local or fallback state cannot become a second source of truth

## Async/Job Enforcement

Use when work is moved out of the request path.

Options:

- idempotency keys or dedupe tables
- outbox/inbox patterns
- bounded retries with dead-letter handling
- job status records for user-visible workflows
- structured logs and metrics with correlation IDs
- tests for duplicate delivery and partial failure

Good signal:

- a retry, crash, duplicate event, or partial failure does not corrupt state silently

## Compatibility Enforcement

Use when changing schemas, constraints, APIs, feature flags, or stored data.

Options:

- separate create and update schemas when constraints differ
- legacy fixture tests
- migrations/backfills with idempotency checks
- runtime compatibility guards during rollout
- feature flag cleanup tests or static checks

Good signal:

- old records, old clients, and old jobs either work or fail through a planned migration path

## When Not To Add Enforcement

Do not add heavy enforcement when:

- the rule is local, obvious, and low-risk
- the check would be brittle or mostly encode implementation details
- a simple test would prove the behavior better
- the architecture is intentionally in transition and a temporary exception is safer

If you skip enforcement for a meaningful boundary, state why and what signal would justify adding it later.

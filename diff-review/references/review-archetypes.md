# Review Archetypes

Use this to choose mandatory checks for a turn. Assign one or more tags at the top of every turn.

## Tags

- `contract`
- `shared-ui`
- `optimistic-state`
- `parallel-entity`
- `fallback-state`
- `migration`
- `release-safety`
- `infra`
- `security`
- `performance`

On Turn 2+, tags are based on current branch state plus current-turn delta.

## Contract Stack

When payload fields, schemas, validators, typed errors, or public contracts change, check:

- create / update / patch / rename / delete / import / direct mutation
- route-layer validation
- shared schemas and validators
- client/store validation
- server-wrapper mappings and direct callers
- backend handlers and persistence rules
- optimistic paths and reconciliation
- read-side parsing/normalization
- error mapping and compatibility tests

## Shared UI / Local Forks

When a shared component or one screen-local copy changes, check:

- shared component itself
- screen-local forks and duplicated implementations
- alternate consumers and render surfaces
- hooks/selectors/stores feeding it
- tests at shared level and at least one consumer level

## Optimistic vs Persisted State

Check:

- optimistic payload construction
- server defaults/fallbacks
- sync/update wrapper contract
- reconciliation after success
- failure rollback/retry
- read-side normalization/display helpers

## Parallel Entity Parity

When one entity flow changes, search for the same concept in:

- work items, projects, views, docs, users, teams, labels, or peer domain objects
- sibling services/packages
- client and server copies
- primary and fallback implementations

## Fallback vs Persisted Path

When fallback/local-only state exists beside shared/persisted state, check:

- local-only path
- persisted/shared path
- correction/reconciliation layer
- mutation affordances on both
- tests proving no silent drift

## Migration / Compatibility

Check:

- old stored data
- old client payloads
- create vs update constraints
- idempotency and rollback
- generated clients/types
- backfill ordering and partial failure

## Release Safety

For High/Critical risk, review:

- rollout path
- rollback path
- compatibility window
- feature flag defaults and cleanup
- migration/backfill ordering
- observability and operator recovery

## Security

Check:

- authn/authz on server side
- tenant/scope isolation
- secrets and env exposure
- input validation and output encoding
- dependency/config changes
- non-primary callers that bypass UI/route guards

## Performance / Hot Path

Check:

- render frequency and data size
- query/index assumptions
- fan-out and N+1 paths
- cache invalidation and key scope
- repeated serialization/deep comparisons
- bounded concurrency

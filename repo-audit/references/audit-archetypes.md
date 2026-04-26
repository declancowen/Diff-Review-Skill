# Audit Archetypes

Use this to choose mandatory checks for an audit turn. Assign one or more tags at the top of every turn.

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
- `architecture`
- `performance`
- `background-work`

On Turn 2+, tags are based on current repo state plus current-turn delta.

## Contract Stack

Check:

- create / update / patch / rename / delete / import / direct mutation
- route/API validation
- shared schemas and validators
- client/store validation
- server wrappers and direct callers
- backend handlers and persistence
- optimistic/reconciliation paths
- read-side parsing/normalization
- errors, compatibility, and tests

## Shared UI / Local Forks

Check:

- shared component/abstraction
- screen-local forks
- alternate consumers/render surfaces
- hooks/selectors/stores/services feeding it
- tests at shared and consumer level

## Optimistic vs Persisted State

Check:

- optimistic payload construction
- server defaults/fallbacks
- sync/update contracts
- reconciliation after success/failure
- retries and rollbacks
- read-side normalization and fallback seeds

## Parallel Entity / Service Parity

Search peer concepts across:

- domain entities
- sibling services/packages
- client/server copies
- primary/fallback implementations
- jobs/scripts/imports

## Fallback vs Persisted Path

Check:

- local-only/fallback path
- persisted/shared path
- correction/reconciliation layer
- mutation affordances on both
- stale/lost-access/deleted-source behavior

## Migration / Compatibility

Check:

- old stored data
- old client/job payloads
- create vs update constraints
- idempotency and rollback
- generated clients/types
- backfill ordering and partial failure

## Release Safety

Check:

- rollout and rollback
- compatibility window
- feature flag defaults/cleanup
- migration/backfill ordering
- observability/operator recovery

## Security

Check:

- server-side authn/authz
- tenant/scope isolation
- secrets/env exposure
- input/output safety
- dependency/config changes
- bypass paths: jobs, scripts, direct mutation, internal routes

## Performance / Scale

Check:

- hot-path render/query/job frequency
- N+1/fan-out/index assumptions
- cache invalidation/key scope
- repeated serialization/deep comparison
- bounded concurrency
- data growth and retention

## Architecture

Check:

- ownership boundaries
- dependency direction
- source of truth
- enforcement mechanisms
- public contracts
- exception/deprecation paths

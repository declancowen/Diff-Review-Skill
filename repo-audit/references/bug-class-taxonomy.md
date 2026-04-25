# Bug-Class Taxonomy

Use this reference when an audit is high risk, when external findings are supplied, or when a prior audit missed bugs. This is not an exhaustive checklist. It is a compact set of lenses that force auditors to prove behavior across real codebase states.

## How To Use

For each meaningful audit finding or external report:

1. Classify the bug or risk into one or more classes below.
2. Name the invariant that should have caught it.
3. Check at least one sibling, bypass, or variant path for the same class.
4. Add a prevention artifact when practical: regression test, stronger schema, guard, invariant assertion, helper extraction, monitoring, or audit note.
5. If no class fits, add a candidate class to the audit file and recommend adding it here after the audit.

## Core Classes

### Authority

Less-trusted code controls values that should be owned by a more authoritative layer.

Typical signals:

- client-supplied IDs, timestamps, ownership fields, permission fields, or generated document IDs reach persistence
- UI/default code overrides server/domain defaults without validation
- route/schema accepts fields that backend should generate
- scripts, jobs, or direct mutations bypass the intended authority layer

Review proof:

- identify the owner of every generated/authoritative field
- check create, update, direct mutation, import, optimistic sync, scripts, jobs, and reconciliation paths
- prove lower layers reject or overwrite untrusted values

### Preservation

An action changes more state than the user or system intended.

Typical signals:

- regrouping, rename, assign, delete, migration, or sync changes also clear parent/project/team/sort fields
- update patches spread too broadly
- backfills rebuild data instead of preserving existing values
- side effects cascade without confirmation, transactionality, or matching operator/user intent

Review proof:

- list fields/relationships that must stay unchanged
- compare before/after patches for top-level, child, filtered, grouped, legacy, and batch states
- inspect the narrowest patch shape and persistence writes

### Variant State

Code works for the populated happy path but fails under empty, legacy, `null`, `undefined`, duplicate, or mode-specific states.

Typical signals:

- empty value hides the only edit affordance
- `null` and `undefined` have different semantics but are treated the same
- stricter validation blocks legacy records from saving unrelated edits
- empty datasets/lists/groups do not follow non-empty behavior
- same abstraction behaves differently in read-only, editable, create, update, fallback, and worker modes

Review proof:

- build a small variant matrix for value state, mode state, scope state, flow state, and container/runtime state
- explicitly attack the weakest variant
- keep intentional differences documented

### Lifecycle And Transient Ownership

The owner of pending state, cleanup, confirmation, or recovery disappears before the operation completes.

Typical signals:

- menu/popover/route starts an action that may require a later dialog or confirmation
- component unmounts while async work updates local state
- retained/fallback data survives after live access disappears
- jobs, streams, subscriptions, and event listeners do not restart or clean up across scope changes

Review proof:

- identify which component/process owns pending state, cleanup, and follow-up UI/work
- verify confirmations and retries are mounted or owned above transient containers
- inspect route transitions, workspace/team switches, worker restarts, visibility changes, and offline/reconnect paths

### Identity And Uniqueness

The code assumes a value is unique when only its display form or local context is unique.

Typical signals:

- lookup by label/title/key without workspace/team/project scope
- duplicate render surfaces register the same key, draggable ID, cache key, or DOM/control ID
- `.unique()` reads can be corrupted by duplicate persisted domain IDs
- display labels are used as mutation targets
- migrations or imports create duplicate domain identifiers

Review proof:

- identify the real uniqueness boundary
- include tenant/team/project/account scope in reverse lookups
- check duplicated render surfaces, import paths, scripts, jobs, and alternate consumers for ID collisions

### Atomicity And Partial Failure

A batch or multi-step operation can partially apply while reporting failure or leaving stale derived state.

Typical signals:

- `Promise.all`/parallel fan-out mutates many records and aborts on first rejection
- cache/read-model invalidation happens after the batch and can be skipped
- optimistic state updates before server success without rollback
- multi-write workflows lack transaction, idempotency, or compensation

Review proof:

- define expected all-or-nothing vs best-effort semantics
- inspect failure order, retries, idempotency, and derived-state invalidation
- test or reason about one bad item mixed with valid items

### Compatibility And Legacy Data

New validation, code paths, or assumptions reject old stored data, old clients, old jobs, or old payloads.

Typical signals:

- client-side save gate includes newly strict constraints for existing records
- schema changes reinterpret an old field, fallback field, URL, initials, nullable text, or enum
- old clients/workers/jobs still send previous payload shapes
- create schema is reused for update path by accident
- migrations do not backfill or tolerate legacy values

Review proof:

- compare create constraints vs update constraints
- check stored-data defaults, blank strings, old URLs, missing fields, old enum values, and old clients/workers
- provide compatible update behavior, migration/backfill, or explicit release plan

### Optimistic/Persisted Drift

Client optimistic state, server writes, read-side normalization, and fallback seeds disagree.

Typical signals:

- optimistic IDs differ from server IDs
- pending overrides persist after successful mutation
- server defaults are not mirrored or reconciled
- read model refresh can reapply stale local patches forever
- bootstrap/fallback seed and live sync apply different normalization

Review proof:

- trace optimistic construction, server payload, persistence, response, merge, and failure rollback
- check rapid repeated edits, cross-client updates, initial bootstrap, and fallback refresh
- verify pending state clears on success and failure

### Scope And Tenancy

The right-looking object from the wrong scope is selected, exposed, or mutated.

Typical signals:

- `find()` lacks workspace/team/project/member/account constraints
- assignee/project/defaults are globally valid but invalid for selected team
- retained workspace/team/user is served after live access disappears
- filters, group defaults, cache keys, or jobs bleed between scoped screens or tenants

Review proof:

- name the scope boundary for every lookup, cache key, job, permission check, and mutation
- test duplicate names/keys across scopes
- check lost-access, deleted-scope, route-transition, and stale-session behavior

### Affordance And Entrypoint Parity

Different ways to perform the same action have different validation, permissions, side effects, or recovery.

Typical signals:

- button disabled state differs from keyboard shortcut or handler guard
- context menu differs from inline dropdown or detail form
- route path differs from direct store/server call, job, script, import, or webhook
- API and UI validate different constraints

Review proof:

- list all user and programmatic entrypoints for the action
- compare guards, payloads, disabled states, permission checks, confirmations, and error handling
- verify at least one non-primary entrypoint for important actions

### Semantic Regression

The code still runs, but product or system meaning changed unintentionally.

Typical signals:

- sorting changes from activity time to creation time
- default text becomes persisted content instead of placeholder text
- filters hide all useful items on scoped surfaces
- retained/fallback behavior changes navigation or not-found semantics
- keyboard shortcuts, empty states, or grouping semantics change without intent

Review proof:

- compare behavior to stated product/system intent
- inspect deleted fallbacks, changed sort keys, placeholder/default distinctions, and retained data behavior
- classify intentional product changes separately from bugs

### Performance And Scale Hot Path

A correct-looking implementation creates avoidable cost on a high-frequency render, query, job, or stream path.

Typical signals:

- full snapshot serialization or deep comparison on every render/request
- per-row/per-cell hook/dialog or expensive selector instantiation
- fan-out queries inside list rendering or background jobs
- unbounded filtering/sorting without indexes or scope bounds
- stream/subscription churn on common state changes

Review proof:

- identify frequency and data-size scaling
- check whether cost scales with users/items/messages/files/jobs/tenants
- separate low-risk cleanup from production-impacting hot-path regressions

## Escalation Rule

If the same class appears twice in an audit, treat that class as a hotspot. Future clean conclusions must say how the hotspot was rechecked against the current tree.

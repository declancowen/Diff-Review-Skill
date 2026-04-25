# Bug-Class Taxonomy

Use this reference when a review is high risk, when external findings are supplied, or when a prior review missed bugs. This is not an exhaustive checklist. It is a compact set of lenses that force reviewers to prove behavior across real state variants.

## How To Use

For each meaningful change or external finding:

1. Classify the bug or risk into one or more classes below.
2. Name the invariant that should have caught it.
3. Check at least one sibling or variant path for the same class.
4. Add a prevention artifact when practical: regression test, stronger schema, guard, invariant assertion, helper extraction, or review note.
5. If no class fits, add a candidate class to the review file and recommend adding it here after the review.

## Core Classes

### Authority

Less-trusted code controls values that should be owned by a more authoritative layer.

Typical signals:

- client-supplied IDs, timestamps, ownership fields, permission fields, or generated document IDs reach persistence
- UI defaults override server defaults without validation
- route/schema accepts fields that backend should generate
- optimistic payload can diverge from authoritative persisted payload

Review proof:

- identify the owner of every generated/authoritative field
- check create, update, direct mutation, import, optimistic sync, and reconciliation paths
- prove lower layers reject or overwrite untrusted values

### Preservation

An action changes more state than the user intended.

Typical signals:

- drag/drop, regrouping, rename, assign, or filter changes also clear parent/project/team/sort fields
- update patches spread too broadly
- defaults are rebuilt instead of preserving existing values
- side effects cascade without confirmation or without matching the confirmation text

Review proof:

- list fields/relationships that must stay unchanged
- compare before/after patches for top-level, child, filtered, grouped, and legacy states
- test or inspect the narrowest patch shape

### Variant State

Code works for the populated happy path but fails under empty, legacy, `null`, `undefined`, duplicate, or mode-specific states.

Typical signals:

- empty value hides the only edit affordance
- `null` and `undefined` have different semantics but are treated the same
- stricter validation blocks legacy records from saving unrelated edits
- empty lanes/lists/dialogs do not follow non-empty behavior
- same component behaves differently in list, board, detail, child, read-only, or editable mode

Review proof:

- build a small variant matrix for value state, mode state, scope state, flow state, and container state
- explicitly attack the weakest variant
- keep intentional differences documented

### Lifecycle And Transient Containers

The component that starts an operation unmounts before the operation, confirmation, or follow-up UI can complete.

Typical signals:

- menu item triggers an action that may require a dialog after the menu closes
- popover starts async work that updates local state after unmount
- route transition or retained fallback can keep stale data visible
- nested dialogs, toasts, or confirmation flows are owned by a transient child

Review proof:

- identify which component owns pending state and follow-up UI
- verify async confirmations are mounted above transient menus/popovers
- inspect click, keyboard, and context-menu paths separately

### Identity And Uniqueness

The code assumes a value is unique when only its display form or local context is unique.

Typical signals:

- lookup by label/title/key without workspace/team/project scope
- duplicate render surfaces register the same key, draggable ID, cache key, or DOM/control ID
- `.unique()` reads can be corrupted by duplicate persisted domain IDs
- display labels are used as mutation targets

Review proof:

- identify the real uniqueness boundary
- include tenant/team/project scope in reverse lookups
- check duplicated render surfaces and alternate consumers for ID collisions

### Atomicity And Partial Failure

A batch or multi-step operation can partially apply while reporting failure or leaving stale derived state.

Typical signals:

- `Promise.all` mutates many records and aborts on the first rejection
- cache/read-model bump happens after fan-out and can be skipped
- optimistic state updates before server success without rollback
- create-then-edit races on newly generated IDs

Review proof:

- define expected all-or-nothing vs best-effort semantics
- inspect failure order and derived-state invalidation
- test one bad item mixed with valid items when possible

### Compatibility And Legacy Data

New validation or UI gating rejects old stored data or old clients even when the user edits an unrelated field.

Typical signals:

- client-side `canSave` includes newly strict constraints for existing records
- schema changes reinterpret an old field, fallback field, URL, initials, or nullable text
- old clients/workers/jobs still send previous payload shapes
- route accepts update paths but shared create schema is reused by accident

Review proof:

- compare create constraints vs update constraints
- check stored-data defaults, blank strings, old URLs, missing fields, and old clients
- allow compatible update behavior or provide migration/backfill where needed

### Optimistic/Persisted Drift

Client optimistic state, server writes, and read-side reconciliation disagree.

Typical signals:

- optimistic IDs differ from server IDs
- pending overrides persist after successful mutation
- server defaults are not mirrored or reconciled
- read model refresh can reapply stale local patches forever

Review proof:

- trace optimistic construction, server payload, persistence, response, merge, and failure rollback
- check rapid repeated edits and cross-client updates
- verify pending state clears on success and failure

### Scope And Tenancy

The right-looking object from the wrong scope is selected or mutated.

Typical signals:

- `find()` lacks workspace/team/project/member constraints
- assignee/project/defaults are globally valid but invalid for selected team
- retained workspace/team/user is served after live access disappears
- filters or group defaults bleed between scoped screens

Review proof:

- name the scope boundary for every lookup and mutation
- test duplicate names/keys across scopes
- check lost-access, deleted-scope, and route-transition behavior

### Affordance Parity

Different ways to perform the same action have different validation, permissions, or side effects.

Typical signals:

- button disabled state differs from keyboard shortcut or handler guard
- context menu differs from inline dropdown or detail form
- create dialog differs from rename dialog
- route path differs from direct store/server call

Review proof:

- list all user and programmatic entrypoints for the action
- compare guards, payloads, disabled states, permission checks, and confirmations
- test at least one non-primary affordance for important actions

### Semantic Regression

The code still runs, but product meaning changes unintentionally.

Typical signals:

- sorting changes from activity time to creation time
- default description/summary becomes persisted text instead of placeholder text
- type filter removes all visible items on a single-type surface
- transparent/sticky visual behavior changes masking/overlap semantics
- shortcut removal or UI relocation changes user workflow

Review proof:

- compare changed behavior to stated product intent
- inspect deleted fallbacks, changed sort keys, placeholder/default distinctions, and retained data behavior
- classify intentional product changes separately from bugs

### Performance Hot Path

A correct fix creates avoidable cost on a high-frequency render, stream, or query path.

Typical signals:

- full snapshot serialization or deep comparison on every render
- per-row/per-cell hook/dialog instantiation
- fan-out queries inside list rendering
- expensive filtering/sorting repeated without scope bounds

Review proof:

- identify render/query frequency and data size
- check whether the cost scales with users/items/messages/rows
- separate low-risk cleanup from production-impacting hot-path regressions

## Escalation Rule

If the same class appears twice in a branch, treat that class as a hotspot. Future all-clears must say how the hotspot was rechecked against the current tree.

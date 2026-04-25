# Escaped Audit Benchmarks

Use these as calibration cases when improving or validating the repo-audit skill. They are evidence-backed patterns from real missed or externally surfaced findings. They avoid repo-specific checklists; the point is to verify that the audit process discovers the class of issue.

## How To Run A Benchmark Mentally

For each case, a strong audit should:

- identify the bug class from `bug-class-taxonomy.md`
- state the invariant at risk
- name at least one non-happy-path variant
- trace at least one sibling, bypass, or adjacent path
- avoid giving a clean conclusion without direct evidence

## Benchmark Cases

### 1. Server ID Authority During Create

Signal: A create handler, import, script, or sync call accepts optional entity IDs from a less-trusted payload.

Expected catch:

- Bug class: Authority, Optimistic/Persisted Drift, Identity And Uniqueness
- Invariant: persistence owns durable domain IDs unless uniqueness is explicitly checked and reconciled
- Variant: public caller passes an existing ID; optimistic/local ID differs from server-persisted ID
- Sibling search: related document IDs, create vs update schema, scripts/imports, direct backend handlers, reconciliation

### 2. Batch Mutation Partial Success

Signal: Batch archive/read/update/delete handling fans out in parallel with derived-state invalidation after the batch.

Expected catch:

- Bug class: Atomicity And Partial Failure
- Invariant: failed response must not leave partially mutated authoritative state with stale derived/read state
- Variant: one invalid/not-owned/deleted item mixed with valid IDs
- Sibling search: archive, unarchive, markRead, delete, bulk update, retry and read-model invalidation

### 3. Transient Owner Starts Confirmation Flow

Signal: A context menu, popover, route, or short-lived component starts an action that may require follow-up UI.

Expected catch:

- Bug class: Lifecycle And Transient Ownership, Affordance And Entrypoint Parity
- Invariant: confirmation/pending owner must remain mounted or be owned above the transient initiator
- Variant: transient path requires confirmation while inline/detail/API path does not unmount
- Sibling search: all affordances for the same action

### 4. Empty vs Populated Editable Control

Signal: Empty-value UI is hidden or skipped to reduce noise.

Expected catch:

- Bug class: Variant State, Affordance And Entrypoint Parity
- Invariant: hiding empty state must not remove the only valid edit path in another mode
- Variant: editable child/detail row with empty value vs surface/read-only row with empty value
- Sibling search: board/list/detail/sidebar/read-only/editable surfaces

### 5. Scoped Lookup By Display Label

Signal: Defaults or reverse lookups use `find()` with type and display label.

Expected catch:

- Bug class: Scope And Tenancy, Identity And Uniqueness
- Invariant: lookup must use the active scope, not only formatted display text
- Variant: two teams/workspaces/projects have same key/title/name
- Sibling search: grouping defaults, filters, rename flows, mentions, project/team/user lookups

### 6. Legacy Data Blocked By New Validation

Signal: Settings or update path gates on stricter constraints that old stored records may violate.

Expected catch:

- Bug class: Compatibility And Legacy Data, Variant State
- Invariant: update/edit paths should tolerate old persisted records or provide migration/backfill
- Variant: existing blank/short/old-format field while editing unrelated fields
- Sibling search: create vs update schemas, UI save gates, API patch routes, migrations, old clients/jobs

### 7. Undefined vs Null Defaults

Signal: Defaults use both `undefined` and `null` to distinguish inherited default from explicit "none".

Expected catch:

- Bug class: Variant State, Optimistic/Persisted Drift
- Invariant: `undefined` means "not explicitly set"; `null` means "explicitly empty" only if all consumers preserve that distinction
- Variant: explicit "No project" vs inherited parent/default project
- Sibling search: default builders, dialog initialization, server payload, reconciliation, tests for explicit none

### 8. Retained/Fallback Data After Access Disappears

Signal: UI/store retains last workspace/team/user/context to avoid flicker during transitions.

Expected catch:

- Bug class: Scope And Tenancy, Lifecycle And Transient Ownership, Compatibility And Legacy Data
- Invariant: retained data must expire or clear when live access truly disappears
- Variant: route transition temporary gap vs deleted/lost-membership permanent gap
- Sibling search: retained workspace, retained team, shell fallback, bootstrap seed, not-found/redirect gates

### 9. Sort-Key Semantic Regression

Signal: Feed/list ordering changes from activity/update time to creation time during refactor.

Expected catch:

- Bug class: Semantic Regression
- Invariant: activity feeds sort by current activity unless product intent explicitly changed
- Variant: old item with new reply/update should rise above newer inactive item
- Sibling search: channel posts, comments, inbox, activity feeds, notifications

### 10. Hot-Path Whole-Snapshot Comparison

Signal: hydration, selector, job, or request code serializes/compares a full workspace snapshot on a repeated path.

Expected catch:

- Bug class: Performance And Scale Hot Path
- Invariant: repeated work should not scale with entire tenant/workspace payload unless bounded or memoized
- Variant: large workspace with many users/teams/items/labels
- Sibling search: hydration signatures, read-model merge, selectors, render loops, stream handlers

### 11. Button, Keyboard, API, And Job Guards Diverge

Signal: handler and shortcut require a field/permission, but button/API/job path has a different gate.

Expected catch:

- Bug class: Affordance And Entrypoint Parity
- Invariant: all entrypoints expose the same validity and permission rules
- Variant: valid title but no participants; API direct call bypasses UI guard; job caller bypasses route schema
- Sibling search: UI button, keyboard hook, route, store action, server handler, job, script

### 12. Parent/Child Preservation Under Group Operations

Signal: regrouping, drag/drop, bulk edit, or migration sets group fields and also clears parent fields.

Expected catch:

- Bug class: Preservation, Semantic Regression
- Invariant: parent relationship changes must be intentional and match the product/system interaction
- Variant: child item moved between groups vs intentionally reparented
- Sibling search: board/list drop, bulk update, import, migration, descendants

## Calibration Questions

Before a clean conclusion on an audit with repeated external findings, ask:

- Which benchmark case is most similar to the latest finding?
- Which benchmark class has appeared more than once in this repo?
- Which benchmark would still fail if only the current-turn delta was reviewed?
- Which one needs a direct test rather than code-reading confidence?

# Escaped Review Benchmarks

Use these as calibration cases when improving or validating the diff-review skill. They are evidence-backed patterns from real missed or externally surfaced review findings. They intentionally avoid repo-specific checklists; the point is to verify that the review process would discover the class of issue.

## How To Run A Benchmark Mentally

For each case, a strong review should:

- identify the bug class from `bug-class-taxonomy.md`
- state the invariant that is at risk
- name at least one non-happy-path variant
- trace at least one sibling or adjacent path
- avoid giving an all-clear without direct evidence

## Benchmark Cases

### 1. Server ID Authority During Create

Signal: A create handler or sync call now accepts optional entity IDs from client/store payload.

Expected catch:

- Bug class: Authority, Optimistic/Persisted Drift, Identity And Uniqueness
- Invariant: server persistence owns durable domain IDs unless uniqueness is explicitly checked and reconciled
- Variant: public store/API caller passes an existing ID; optimistic local ID differs from server-persisted ID
- Sibling search: description/document IDs, create vs update schema, direct backend handlers, reconciliation

### 2. Batch Mutation Partial Success

Signal: A route changes batch archive/read/update handling to `Promise.all`, with read-model invalidation after the batch.

Expected catch:

- Bug class: Atomicity And Partial Failure
- Invariant: failed response must not leave partially mutated server state with stale derived/read state
- Variant: one invalid/not-owned/deleted item mixed with valid IDs
- Sibling search: archive, unarchive, markRead, bulk delete/update actions

### 3. Transient Menu Starts Confirmation Flow

Signal: A context-menu item calls an action that may require a confirmation dialog, but the dialog is owned by menu content.

Expected catch:

- Bug class: Lifecycle And Transient Containers, Affordance Parity
- Invariant: the confirmation owner must remain mounted after the menu item closes
- Variant: menu path requires confirmation while inline/detail path does not unmount
- Sibling search: status/priority/project/assignee menus and inline property controls

### 4. Empty vs Populated Editable Control

Signal: Empty assignee/project pills are hidden to reduce noise on rows/cards.

Expected catch:

- Bug class: Variant State, Affordance Parity
- Invariant: hiding empty controls on surface rows must not remove the only edit affordance in child/detail rows
- Variant: editable child row with empty value vs editable surface row with empty value
- Sibling search: board, list, child row, read-only detail/sidebar surfaces

### 5. Scoped Lookup By Display Label

Signal: Defaults for a grouped lane are resolved with `find()` using type and display label.

Expected catch:

- Bug class: Scope And Tenancy, Identity And Uniqueness
- Invariant: reverse lookup must use the active team/workspace/project scope, not only formatted display text
- Variant: two teams have the same key/title label
- Sibling search: grouping defaults, filters, rename flows, mentions, project/team lookups

### 6. Legacy Data Blocked By New Client Validation

Signal: A settings save button now gates on stricter min/max constraints that were already server-side but may not hold for old records.

Expected catch:

- Bug class: Compatibility And Legacy Data, Variant State
- Invariant: edit paths should allow compatible saves for old persisted records or clearly require migration
- Variant: existing blank/short optional-looking field while editing unrelated fields
- Sibling search: workspace, team, profile, create vs update schemas, UI `canSave` gates

### 7. Undefined vs Null Defaults

Signal: Create defaults use both `undefined` and `null` to distinguish inherited default from explicit "none".

Expected catch:

- Bug class: Variant State, Optimistic/Persisted Drift
- Invariant: `undefined` means "not explicitly set"; `null` means "explicitly empty" only if all consumers preserve that distinction
- Variant: grouped by project "No project" vs parent-based group inheriting parent project
- Sibling search: default builders, dialog initialization, server payload, tests for explicit none

### 8. Retained/Fallback Data After Access Disappears

Signal: UI retains last workspace/team context to avoid flicker during transitions.

Expected catch:

- Bug class: Scope And Tenancy, Compatibility And Legacy Data, Lifecycle And Transient Containers
- Invariant: retained data must expire or clear when live access truly disappears
- Variant: route transition temporary gap vs deleted/lost-membership permanent gap
- Sibling search: retained workspace, retained team, shell fallback, not-found/redirect gates

### 9. Sort-Key Semantic Regression

Signal: Feed ordering changes from update/activity time to creation time during refactor.

Expected catch:

- Bug class: Semantic Regression
- Invariant: discussion feeds sort by current activity unless product intent explicitly changed
- Variant: old post with new reply should rise above newer inactive post
- Sibling search: channel posts, comments, inbox, activity feeds

### 10. Hot-Path Whole-Snapshot Comparison

Signal: hydration signature uses full snapshot serialization on render.

Expected catch:

- Bug class: Performance Hot Path
- Invariant: per-render work should not scale with entire workspace payload unless bounded or memoized by identity
- Variant: large workspace with many users/teams/labels
- Sibling search: other hydration signatures, read-model merge, selectors, render loops

### 11. Button And Keyboard Guard Diverge

Signal: Submit handler and keyboard shortcut require selected participants, but button disabled state only checks title validity.

Expected catch:

- Bug class: Affordance Parity, Variant State
- Invariant: all submit affordances expose the same sendability rules
- Variant: no participants, valid title, button appears enabled but handler no-ops
- Sibling search: create group, direct chat, post composer, dialog submit, command-enter hooks

### 12. Parent/Child Preservation Under Group Operations

Signal: regrouping or lane drops set group fields and also clear parent fields.

Expected catch:

- Bug class: Preservation, Semantic Regression
- Invariant: parent relationship changes must be intentional and match the product interaction, not incidental to changing group/lane
- Variant: child item dragged between status lanes vs dropped onto a different parent
- Sibling search: board drop, list drop, item drop target, lane/root target, descendants

## Calibration Questions

Before an all-clear on a branch with repeated external findings, ask:

- Which benchmark case is most similar to the latest fix?
- Which benchmark class has appeared more than once on this branch?
- Which benchmark would still fail if only the current-turn diff was reviewed?
- Which one needs a direct test rather than code-reading confidence?

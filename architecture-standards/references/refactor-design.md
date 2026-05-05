# Refactor Design

Use this when audits, reviews, or analyzer reports reveal duplication, health hotspots, large modules, module-budget pressure, or broad cleanup/refactor work.

The goal is not to make metrics quiet. The goal is to discover what design concept is missing, where ownership is unclear, and what boundary would make future changes safer.

## Why This Matters

If a repo passes a normal architecture review but static analysis later exposes widespread duplication and complexity, the architecture review was probably too local. It checked known high-risk flows, but did not fully use structural evidence to find missing design concepts.

Architecture standards must therefore do two kinds of thinking:

- **Path thinking:** trace a user/system journey end to end and protect its invariants.
- **Shape thinking:** inspect repeated structures, hotspots, module pressure, and helper sprawl to infer where boundaries are weak.

Both are required for a serious architecture assessment.

Use audit-derived static-analysis evidence as the regression benchmark for this rule: a repo with broad duplication, dead-code inventory, and critical health hotspots should not pass architecture review as "healthy" simply because primary paths work. The design response must explain what ownership, boundary, public surface, or fitness function was missing.

## Refactor Design Loop

1. **Cluster the evidence.**
   Group duplication, health, large-file, and hotspot findings by capability, layer, and repeated responsibility. Do not work item-by-item.

2. **Name the repeated concept.**
   Ask what is actually repeated: presentation shell, route parsing, permission policy, state transition, query shaping, rank math, error handling, test fixture behavior, external adapter mapping, or data contract.

3. **Identify the owner.**
   Decide whether the concept belongs to presentation, application, domain, data, infrastructure, API/integration, operations, or tests. If no owner is obvious, that is the architecture problem.

4. **Choose the smallest design move.**
   Options include local helper, capability-owned helper, domain policy module, application command/query, data access helper, route adapter, shared UI primitive, test fixture utility, boundary config, or no extraction.

5. **Define the public surface.**
   The new surface should make misuse harder. It should not expose caller internals, transport objects, vendor details, or persistence shapes unless that layer owns them.

6. **Check bypass paths.**
   Search alternate routes, UI screens, jobs, scripts, tests, import paths, webhook handlers, CLI paths, and generated/client code.

7. **Prove behavior.**
   Add or identify tests, type/schema checks, browser smoke, static import checks, or operational checks that prove the refactor preserved the invariant.

8. **Record transition state.**
   Mark remaining work as fixed, must-fix, should-fix, deferred, accepted, policy-modeled, deployment-gated, or inventory-only.

9. **Ratchet the evidence.**
   If duplication, health, suppressions, allowlists, or module budgets remain, record owner, cap, reason, evidence command/date, and revisit trigger. A baseline-equal budget pass is accepted debt, not completion.

10. **Keep the branch reviewable.**
    For broad remediation, slice by owner/capability where possible. If the work must ship as one large branch, keep a ledger of batches, changed contracts, validation commands, raw analyzer paths, and external review state. Large PRs hide small contract bugs unless the review plan compensates.

## Duplication Design Questions

Ask these before extracting:

- Is the duplicate code repeating a business invariant or just similar syntax?
- Would callers change together when the rule changes?
- Is the variation meaningful?
- Is one copy authoritative and the other a drifted shadow?
- Is the duplication crossing capability/layer boundaries?
- Is a shared abstraction stable enough to own?
- Would extraction increase coupling or dependency direction risk?
- What test would fail if one copy changed and another did not?

## Health Hotspot Design Questions

Ask these before splitting:

- Which responsibilities are mixed in the hotspot?
- Is complexity from real domain branching, UI state branching, transport parsing, persistence shape, or integration error mapping?
- Can pure policy be separated from framework/persistence code?
- Can orchestration be separated from rendering or data access?
- Is the function large because it is a central contract? If yes, would splitting harm readability?
- Does churn indicate unstable requirements, unclear ownership, or simply active product work?

## Monolith Prevention Rules

When a component, route, handler, store slice, script, or Convex module is already large or likely to grow, do not wait for a health campaign to split it. Design the next change so the file has fewer reasons to change.

Prefer these owner-local splits:

- **UI screens/components:** keep route/screen orchestration visible, then split local state machines, view-model shaping, render-only rows/cards/dialogs, effect hooks, and feature-local primitives.
- **Rich editor/collaboration UI:** keep editor/collaboration wiring in the rich-text/collaboration owner; extract pure caret, marker, awareness, upload, and menu-navigation helpers into sibling modules imported by production and tests.
- **Routes/server handlers:** keep route semantics explicit; extract request parsing, public query/form serialization, auth/session wrappers, response/error helpers, and polling/stream mechanics only at the route/server owner.
- **Domain/data/Convex handlers:** move durable validation, authorization, cascade collection, and persistence patch decisions to the domain/data owner; do not hide business rules in generic utilities.
- **Store slices:** split pure state transitions from provider calls and optimistic/rollback orchestration while preserving replacement/mutation semantics.
- **Scripts/jobs:** extract env parsing, claim/release, loop/backfill, and result-summary mechanics into script-owned helpers; keep job intent visible in the script.
- **Tests:** extract fixtures only when they model a contract such as identity, tenancy, persistence semantics, time, env, or adapter state. Collapse repeated assertions when a zero-duplication gate would otherwise be broken.

Do not export private branches from production modules solely to satisfy coverage. If a branch deserves direct tests, move the stable primitive into an owner-local module that production imports, or test the behavior through the public owner.

For auth, routes, webhooks, storage, and external integrations, distinguish internal option names from serialized public keys. Contract tests should assert the URL/query/form/body/storage shape on failure and retry branches, where key drift often escapes happy-path tests.

## Common Refactor Shapes

### Presentation Duplication

Good response:

- extract capability-local presentation components, render helpers, empty/loading/error states, or view models
- keep business permission and persistence rules out of UI helpers
- browser-smoke important screens after broad presentation changes

Bad response:

- global component that hides feature-specific semantics
- shared props API so generic that every caller still duplicates policy

### Route / Handler Duplication

Good response:

- extract transport parsing, response helpers, CSRF/origin/rate-limit wrappers, or error mapping at the server/application edge
- keep route-specific command semantics visible
- add contract tests for success and failure states

Bad response:

- generic route runner that obscures auth, idempotency, or response behavior

### Domain / Data Duplication

Good response:

- move durable rules to the authoritative domain/data/application owner
- centralize query shaping or validation only when callers share the same invariant
- protect tenancy, permissions, and state transitions with tests

Bad response:

- shared utility imported by everyone that owns no data and answers business questions anyway

### Integration Duplication

Good response:

- keep vendor SDK details in adapters
- share proof/signature/error/URL helpers in infrastructure or server boundary
- keep product semantics outside vendor wrappers

Bad response:

- leaking vendor payloads into domain logic because it reduced repeated mapping code

### Test Duplication

Good response:

- extract fixtures when they model a contract: identity, tenancy, persistence semantics, time, env, external service state, queue/job behavior
- preserve object identity, mutation semantics, ordering, pagination, async timing, and cleanup behavior

Bad response:

- helper that makes tests shorter but less explicit about the invariant being proven

### Large Module Split

Good response:

- split by ownership: access checks, view model, action handlers, pure policy, persistence helpers, integration adapter, render-only components
- keep exports narrow
- update module-budget policy only if a central contract remains intentionally large
- verify representative UI screens in a browser when the split affects presentation/layout/navigation

Bad response:

- split by arbitrary line ranges or component subtrees while imports still form the same tangled dependency graph

## From Report To Transition Plan

An audit or Fallow report should produce a design transition plan, not just a warning list.

A useful transition plan says:

- which clusters represent missing architecture concepts
- which clusters are harmless inventory
- which clusters require behavior-preserving refactor tests first
- which module-budget exceptions are temporary
- which analyzer config changes model intentional architecture
- which screens/routes/jobs need browser, contract, or deployment smoke
- how the branch will stay reviewable if remediation spans many owners or produces a large PR
- what order reduces risk fastest

## Design Review Checklist

Before approving a broad refactor:

- The repeated concept is named.
- The owning layer/capability is explicit.
- The new boundary has a narrow public API.
- Shared code does not hide business ownership.
- Bypass paths were searched.
- Behavior-preserving verification exists.
- Metrics improved because design improved, not because policy was loosened.
- Remaining inventory has a transition state and revisit trigger.
- Production gate, full inventory, changed-file audit, and CI parity evidence are not collapsed into one "clean" claim.
- Broad movement has full tests, browser smoke, contract tests, or an explicit low-risk rationale for narrower validation.
- Production dead-code was rerun after coverage-oriented exports or helper extraction, so test-only production APIs did not become the new architecture.
- Coverage-aware health evidence was refreshed after test changes before declaring findings cleared.
- External review findings were checked for sibling builders/routes/helpers that share the same contract or option mapping.
- If hosted PR diff tooling is truncated or difficult to navigate, local branch-vs-base review, owner batch ledger, and comment/thread polling are used as the source of truth.

---
name: diff-review
description: Review local git diffs for bugs, security issues, and code quality before pushing to origin — with root cause analysis, codebase-aware context, and iterative turn-based review tracking. Use this skill whenever the user asks to review a diff, check changes before pushing, review staged changes, compare branches, do a local code review, pre-PR review, re-review after fixes, check review status, or says things like "review my changes", "check my diff", "what did I break", "review before I push", "look at my staged changes", "compare my branch to main", "run the review again", "did I fix the issues", or "what's still open from the last review". Also trigger when the user mentions reviewing code changes even casually, like "can you look at what I changed" or "sanity check my work".
---

# Diff Review

A local code review system that analyses git diffs before they reach origin. Goes beyond surface-level diff scanning — it reads the surrounding codebase for context, performs root cause analysis, and tracks findings across iterative review turns in a single file per content area.

## Reviewer stance

When running this skill, operate as a world-class software risk analyst: a reviewer with deep practical experience across bugs, security, reliability, architecture, and QA. Your job is to find the issues that matter before they reach origin, explain them clearly, and recommend fixes that hold up under real codebase conditions.

Think like an owner, not a diff scanner. Read enough surrounding code to understand invariants, dependencies, callers, consumers, shared types, data flow, failure modes, and deployment impact before deciding something is wrong or suggesting a fix.

Be strict about correctness, but stay grounded in the actual codebase. The goal is not to produce the most sophisticated theoretical answer. The goal is to identify the highest-signal issues and drive toward fixes that solve the problem without creating new ones somewhere else.

## Remediation stance

Review findings and re-review fixes with full code awareness:

- Never treat a fix as isolated to the edited lines. Check what the issue touches and what the proposed fix would touch: callers, consumers, shared types, state transitions, persistence, config, tests, and adjacent error paths.
- Prefer fixes that address root cause without widening coupling, duplicating logic, breaking existing contracts, or introducing a different failure mode downstream.
- Treat "resolved" as a high bar: the original issue is fixed, the root cause is addressed, and the remediation does not create an obvious regression in nearby flows.
- If the safest action is a narrow fix now and a broader cleanup later, say so explicitly. Separate must-fix work from follow-on improvements.

## Investigation standard

This skill is only useful if the investigation is thorough. Review literally every changed file in scope and keep expanding outward until you understand what each change affects.

- Do not stop at the first plausible explanation or the first bug you find.
- Turn over every stone on the changed path: callers, consumers, shared utilities, schemas, tests, config, migrations, permissions, retries, caches, feature flags, and operational side effects.
- Shared abstractions demand deeper tracing. If a changed file is reused across the codebase, inspect enough usage sites to understand the real blast radius before concluding the change is safe.
- A review is not complete just because the diff was scanned. It is complete when you can explain the full impact of the change and why the untouched but connected code still holds.
- If you cannot fully review the whole diff in the current pass, say so explicitly and list what remains unreviewed. Never imply "all clear" on a partial investigation.

## Review discipline

Operate like a senior PR reviewer, not a linter.

- Start by understanding intended change, then review for unintended change.
- Prioritize findings that create user risk, production risk, security exposure, data integrity risk, operational pain, or developer footguns.
- Distinguish clearly between must-fix findings and lower-signal observations. Do not bury serious issues in a long list of minor comments.
- Do not manufacture noise for the sake of appearing thorough. The standard is depth and accuracy, not comment volume.
- Be willing to say "no findings" when the change is genuinely solid and sufficiently verified.

## All-clear bar

Do not give an "all clear" unless all of the following are true:

- The intended change is understood and the diff matches that intent.
- Every changed file in scope was reviewed.
- High-risk connected code paths were traced far enough to understand the blast radius.
- Relevant tests and checks were run, or the lack of verification is explicitly called out and accepted as low enough risk.
- No open Critical or High findings remain.
- Any remaining uncertainty is minor enough that shipping is still a defensible decision.

For `Medium` risk or above, read `references/all-clear-antipatterns.md` before final all-clear and explicitly avoid the relevant anti-patterns in the turn notes.

If those conditions are not met, the correct outcome is not "all clear". It is "partial review", "open findings remain", or "needs follow-up verification".

## High-risk all-clear proof burden

For `High` and `Critical` reviews, "no open findings" is not enough by itself.

Before giving an all-clear, confirm all of the following explicitly:

- the current branch state was reassessed this turn
- the hotspot ledger was reviewed this turn
- sibling closure was completed for every serious bug family touched in prior turns
- relevant targeted verification was rerun, not just inherited from an older turn
- the challenger pass completed
- the weakest-evidence areas are called out explicitly

If any of those are missing, the outcome must remain partial or blocked even if no fresh finding was written this turn.

## Anti-blind-spot checks

Before concluding the review, actively look for what reviewers commonly miss:

- **Negative space:** what should have changed but did not? Callers, validation, tests, docs, config, migrations, feature flags, monitoring, cleanup, or rollback handling.
- **Deleted safeguards:** removed guards, removed tests, removed validation, removed retries, or deleted error handling can be as risky as added code.
- **Pattern siblings:** when you find one bug pattern, stop and build a sibling matrix. Search for the same pattern across lifecycle variants, layers, parallel entities, alternate consumers, and non-primary callers. Do not assume a single occurrence unless the search proves it.
- **Refactor debris:** stale names, half-moved files, dead code, duplicate paths, partial reverts, and generated artifacts that no longer match the source.
- **False confidence:** passing tests do not overrule contradictory code evidence, and broad CI green does not prove a risky path is safe if coverage is weak.

## Invariant-first review gate

Do not review meaningful behavior changes only as code hunks. Convert each changed behavior into invariants, then try to break those invariants against representative states.

When external review findings, escaped bugs, repeated false all-clears, or high-risk branch loops are present, load `references/bug-class-taxonomy.md` and classify the findings or risks into bug classes before concluding the turn. Use `references/escaped-review-benchmarks.md` for calibration when the branch resembles a prior missed-review pattern.

For every shared UI, contract, persistence, optimistic-state, batch-operation, or fallback-path change, identify:

- **Authority:** which layer owns IDs, defaults, validation, permissions, timestamps, and persisted values; reject changes that let less-trusted layers override authoritative layers without an explicit guard.
- **Preservation:** which fields, relationships, filters, parent links, sort keys, or existing values must remain unchanged when the user performs the action.
- **State variants:** empty vs filled, valid vs legacy-invalid, editable vs read-only, parent vs child, grouped vs ungrouped, default vs filtered, current user vs other user, and duplicate display-label cases.
- **Interaction variants:** mouse, keyboard shortcut, disabled button, context menu, nested menu, inline editor, modal, confirmation dialog, and autosave/explicit-save variants.
- **Lifecycle:** whether the component that starts an async action, confirmation, or dialog can unmount before the follow-up UI appears or before the mutation completes.
- **Identity:** whether keys, registration IDs, cache keys, unique lookups, and reverse lookups are truly unique under duplicate render surfaces, duplicated labels, multiple tenants/teams, or repeated entity names.
- **Atomicity:** for batch or fan-out operations, what happens if one item fails after others succeed; whether read models, caches, optimistic state, and error responses remain coherent.

For `Medium` risk or above, record the main invariants checked in the review turn. For `High`/`Critical` risk, an all-clear is not allowed unless the weakest invariant has been attacked directly with code reading, a targeted test, or a concrete reason it cannot fail.

## Variant matrix discipline

When a shared component, selector, helper, dialog, menu, or store action changes behavior, build a small variant matrix before clearing it.

Minimum useful axes:

- **Value state:** empty, populated, invalid legacy value, and explicit `null`/`undefined` when both are meaningful.
- **Mode state:** editable, read-only, inline, detail view, surface/list/card view, create mode, rename/update mode.
- **Scope state:** tenant/workspace/team/project, no scope, duplicate labels in different scopes, and stale or retained scope.
- **Flow state:** click, keyboard submit, programmatic submit, optimistic submit, server failure, retry, and reconciliation.
- **Container state:** normal mounted component, transient menu/popover, nested dialog, route transition, fallback/skeleton, retained data.

The matrix does not need to be large or formal. It must be explicit enough that a reviewer cannot accidentally only check the happy path.

## Risk escalation

Not every diff needs the same level of scrutiny. Raise the review depth aggressively for high-risk changes.

Treat these as high-risk by default:
- Auth, authz, session, permissions, impersonation, tenancy, or secrets handling
- Payments, billing, pricing, entitlements, quotas, or irreversible user actions
- Migrations, backfills, schema changes, data deletion, or one-way data transforms
- Shared libraries, design systems, public APIs, SDKs, events, contracts, or widely reused utilities
- Concurrency, retries, queues, caches, locks, background jobs, or distributed workflows
- Infra, deployment, config, feature flags, rollout controls, or operational toggles

For high-risk changes:
- Prefer broader verification over narrow verification.
- Review failure modes, retry behavior, rollback paths, and partial-success states explicitly.
- Check compatibility across old and new clients, callers, consumers, payloads, and stored data where relevant.
- Expect stronger evidence before giving medium or high confidence.
- If the environment prevents meaningful verification, say so and lower confidence rather than hand-waving.

## Risk score

Assign every review a risk score before concluding the first pass:

- **Low**: Localized change, small blast radius, strong direct coverage, easy rollback.
- **Medium**: Multiple files or flows touched, moderate shared-surface impact, some uncertainty.
- **High**: Shared abstractions, contracts, auth/data integrity, migrations, concurrency, or broad blast radius.
- **Critical**: Money, permissions, destructive data paths, one-way transforms, infra toggles, or changes where failure consequences are severe.

State the score in the review and let it drive scrutiny:

- **Low**: Targeted review plus targeted verification.
- **Medium**: Full flow tracing plus targeted verification and safety-net checks.
- **High**: Full flow tracing, broader verification, compatibility/release-safety review, and challenger pass.
- **Critical**: Treat as production-risk work. Require the strongest evidence available, explicit residual risks, and a challenger pass before any all-clear.

## Process proportionality and stopping rule

The goal is fail-safe review, not maximum ceremony for its own sake.

- Apply the full guardrail set when the risk score, change archetypes, hotspot ledger, or escaped-bug history justify it.
- For low-risk and well-evidenced turns, use the lightest process that still satisfies the active obligations.
- Stop adding new review machinery when the current risk obligations are met, the evidence is strong enough to support the decision, and additional process is unlikely to change the outcome.
- Do not skip mandatory closure work for serious findings just because the diff is small.
- Do not force high-ceremony checks on every low-risk turn just because earlier turns were high risk. Reassess the branch each turn, then apply the proportional process for that turn's actual risk.
- If in doubt between two levels of scrutiny, choose the stricter one and say why.

## Independent challenger pass

For `High` and `Critical` risk reviews, run a second pass whose job is to disprove the first pass's confidence.

- If an independent review surface is available, use it.
- If not, do a fresh adversarial pass yourself after the main review: assume there is at least one serious missed issue and go hunting for it.
- In the challenger pass, focus on the weakest-evidence areas: untouched dependencies, deleted safeguards, compatibility assumptions, migrations, rollout paths, and tests that may give false confidence.
- If the challenger pass finds uncertainty the first pass did not resolve, lower confidence or block the all-clear.

## Confidence penalties

Lower confidence automatically when one or more of these are true:

- sibling closure is incomplete
- only the primary path was tested
- only the route path was reviewed for a contract bug
- no non-primary caller audit was done where bypass paths likely exist
- external findings were not triaged against the current tree first
- branch-totality was not reassessed on Turn 2+
- hotspot ledger was not checked on a long-running review
- previously resolved adjacent findings were not revalidated despite substantial nearby change

When these penalties apply, say so explicitly in the confidence note rather than keeping generic medium/high confidence language.

## Family closure for repeated bug classes

For every serious finding (`High`/`Critical` Bug or Security issue), run a symmetry sweep before calling the issue resolved.

When a Bug or Security finding lands on a shared abstraction, contract surface, duplicated implementation, or parallel entity flow, do not treat it as a single-site issue.

Build a sibling matrix across:

- **Lifecycle siblings:** create, update, patch, rename, delete, import, optimistic apply, reconcile, background sync, backfill
- **Layer siblings:** UI, shared component, store, route/API, server wrapper, backend handler, schema/validator, persistence, tests
- **Entity siblings:** parallel entities implementing the same concept (for example work item, project, view, doc)
- **Consumer siblings:** screen-local copies, shared helpers, alternate screens, alternate routes, alternate render surfaces
- **Caller siblings:** direct server callers, scripts, jobs, migrations, webhooks, or any path that bypasses the primary route

Record:

- primary site
- sibling sites checked
- sibling sites fixed
- sibling sites intentionally out of scope
- verification run on at least one non-primary sibling path when risk warrants it

Do not mark the finding resolved until this closure pass is complete. If closure is incomplete, the review outcome must remain partial.

## Resolution gate

A finding cannot be marked `Resolved` unless all of the following are true:

- the root cause is addressed, not just the local symptom
- the sibling/family sweep is complete
- the remediation shape is coherent across the bug family or any intentional divergence is explained
- the remediation impact surface was assessed across adjacent callers, consumers, dependencies, and contracts
- any `must fix now` adjacent weakness uncovered during remediation was fixed, kept open, or explicitly blocked
- at least one non-primary path was checked when bypass paths plausibly exist
- targeted verification ran for the affected behavior
- recurrence risk was reduced with a prevention artifact, or the review explains why none is practical here
- no obvious expected companion change is still missing

If those conditions are not met, use `Partially addressed` or `Still open` instead of `Resolved`.

## Family-level remediation coherence

When a finding belongs to a repeated workflow, shared abstraction, related contract family, or parallel implementation set, do not solution it site-by-site in isolation.

Before recommending, accepting, or clearing a fix, decide whether the bug family needs:

- one shared remediation pattern across sibling surfaces
- one abstraction, contract, or boundary fix instead of multiple local patches
- intentionally different fixes in different surfaces because the constraints genuinely differ

Explicitly check:

- whether the proposed fix conflicts with how adjacent family members behave
- whether the same invariant should now be enforced in sibling paths as well
- whether a shared helper, adapter, schema, permission rule, or contract should change instead of each call site drifting independently
- whether mixed local fix styles would create remediation drift, policy drift, or future bugs when multiple fixes interact

If sibling surfaces remain intentionally different, say why. If the remediation shape is inconsistent across the same bug family without a defensible reason, keep the finding open or raise a new finding for remediation drift. If coherence depends on long-lived boundaries or dependency direction, use the `architecture-standards` skill to shape the proper fix.

## Remediation impact surface

Do not stop at bug-family similarity. A remediation can be family-consistent and still break adjacent code that depends on the same helper, contract, state shape, data model, orchestration step, or side effect.

For any proposed or applied fix that changes behavior, contract shape, shared code, sequencing, permissions, caching, data writes, or read semantics, explicitly map the remediation impact surface:

- upstream callers, inputs, and assumptions that feed the changed behavior
- downstream consumers, renderers, jobs, events, and integrations that observe the changed behavior
- adjacent workflows that share the same state, schema, transport, queue, feature flag, or operational boundary
- shared dependencies, adapters, helpers, and abstractions whose semantics now differ
- interactions between multiple related fixes that may be individually valid but inconsistent together

Use this impact surface to decide what else must be re-read, re-tested, or re-verified before clearing the turn. If a fix changes a reusable contract or behavior, audit dependents even when they are not part of the original bug family.

## Remediation radius and prevention

Do not treat every nearby imperfection as in-scope just because the team is already editing the area. Adjacent fixes must be evidence-led and bounded.

For each meaningful finding or remediation path, classify nearby work into three buckets:

- `Must fix now` — leaving it alone would likely preserve a live bug, create a fresh bug, leave a broken dependent path, keep a companion change missing, or leave the same violated invariant active in an adjacent surface
- `Should fix now if cheap/safe` — low-risk follow-through that materially reduces fragility, such as removing duplicated risky logic, adding missing regression coverage, tightening validation, or aligning an obviously drifting helper while the code is already open
- `Defer` — speculative cleanup, broad refactors, style consistency, architecture redesign, migrations, or any change whose risk/scope is disproportionate to the current bug fix

Adjacent improvements need proof, not taste. Only expand scope when the evidence shows the work is necessary or clearly risk-reducing. If an adjacent issue is not required for correctness, safety, compatibility, or coherent behavior, do not smuggle it in as "while we're here" cleanup.

For every adjacent fix you recommend or accept, state:

- what concrete risk it removes
- what evidence shows it is live or likely enough to justify touching now
- how it was verified independently from the main fix

Every meaningful fix should also leave behind a prevention artifact when feasible:

- regression test
- stronger type/schema/runtime validation
- invariant assertion or guardrail
- lint/static rule
- telemetry, logging, or alerting improvement
- helper extraction that removes risky duplication without broadening scope

If no prevention artifact is appropriate, say why.

## Non-primary path audit

For any serious finding on a contract surface, shared abstraction, or repeated workflow, explicitly ask:

- what bypasses the main route or primary UI path?
- what writes this data directly?
- what background job, script, migration, webhook, or alternate server wrapper touches the same behavior?
- what alternate screen, alternate store action, or alternate render path implements the same action?

Record the result of this audit in the turn notes when relevant. If no meaningful non-primary path exists, say that explicitly.

## Parallel implementation parity

When a bug is found in one implementation of a repeated concept, check the parallel implementations before concluding the review.

Common examples:

- work item vs project
- saved view vs fallback/local-only view
- shared editor vs screen-local editor
- create route vs patch route vs direct mutation

If parity was checked, say so. If not, keep the finding open or mark the review partial.

## Branch-totality reassessment

On Turn 2+, the authoritative review target is the current branch state, not just the incremental fix diff.

Every re-review must look at:

- the current-turn delta
- the cumulative branch diff versus the base branch
- the current-tree state of previously flagged areas, even if untouched this turn
- the current-tree state of sibling surfaces for repeated bug classes

Use the turn delta to focus attention. Use the branch-total state to decide shipping readiness. Never give an all-clear based only on the latest turn's edit set.

## Branch-totality proof requirement

On Turn 2+, the review file must prove branch-total reassessment concretely, not just claim it.

The branch-totality proof should name:

- non-delta files, systems, or consumers that were re-read
- prior open findings that were rechecked against the current tree
- prior resolved or adjacent areas that were revalidated because the latest work could have disturbed them
- hotspot families, sibling paths, or non-primary paths that were revisited
- why those rechecks are enough to support the stated branch confidence

If the `Branch totality` note or supporting proof only restates the latest diff files, the review cannot conclude `all clear` or `all clear with low-risk unknowns`. Mark the turn partial or blocked and keep digging.

## Do not over-index on the latest fix

On Turn 2+, the latest patch is a clue, not the whole target.

- the current branch state is the object under review
- the latest fix diff is only the fastest way to find what changed most recently
- previously changed high-risk areas can still fail shipping readiness even when untouched this turn

If the current tree is not credible overall, do not let a clean-looking fix diff drive an all-clear.

## Live-first triage for pasted findings

When findings come from outside the current review pass, classify each one against the current tree before acting on it:

- `live`
- `already fixed`
- `stale`
- `intentional`
- `needs confirmation`

Only after this triage should remediation or re-review planning begin. Do not assume externally supplied findings are still open just because they were once valid.

When multiple external findings are supplied, load `references/external-finding-import.md` and normalize them into an import table before fixing or clearing them.

Also classify every external finding by bug class using `references/bug-class-taxonomy.md`. If the finding is live, already fixed, or stale, the classification still matters because it reveals what the prior review failed to prove. If no taxonomy class fits, record a candidate class in the review turn instead of inventing a one-off checklist item.

For any external finding that was missed after a prior all-clear or partial-clear, load `references/miss-retrospective-template.md` and write a concise retrospective entry in the review file. The retrospective must name the missed signal, the missing variant or invariant, and the future proof obligation.

## Common miss archetypes

Expand the review automatically when the diff touches one of these recurring miss patterns:

- **Contract surfaces:** the same field or rule can enter through create, update, patch, rename, delete, import, and direct-server paths
- **Parallel entity flows:** similar behavior implemented separately for work items, projects, views, docs, or other peer entities
- **Shared component plus local forks:** a bug fixed in one screen copy may still exist in the shared primitive or another surface-specific copy
- **Optimistic vs persisted state:** client optimistic logic, server defaults, reconciliation, and read-side normalization can drift apart
- **Fallback vs persisted paths:** local-only fallback state often diverges from saved or shared state paths
- **Template or design ports:** imported UI shells often introduce dead affordances or product-capability drift across multiple surfaces
- **Calendar date and timezone logic:** create defaults, server fallbacks, storage formats, update paths, and display helpers often drift as a family
- **Validation and typed-error stacks:** schema validation, route validation, server wrapper mappings, and backend handler validation frequently diverge

## Change archetype tags per turn

At the top of every turn, assign one or more archetype tags that describe the current review surface. These tags drive which checklists and hotspot rechecks are mandatory for that turn.

Suggested tags:

- `contract`
- `shared-ui`
- `optimistic-state`
- `parallel-entity`
- `migration`
- `release-safety`
- `infra`
- `security`

If multiple apply, list all of them and name the primary one. If none clearly apply, say so and proceed with the general workflow. On Turn 2+, archetype tags are based on the current branch state and current-turn delta together, not just the latest patch.

## Archetype-specific checklists

When the diff matches one of these archetypes, explicitly check the listed surfaces before concluding the review.

### Contract stack checklist

When a payload field, schema, validation rule, or typed error changes, check:

- create / update / patch / rename / delete / import / direct-mutation entrypoints
- route-layer validation and route schema shape
- shared schema/validator definitions
- client/store validation
- server-wrapper mappings and direct callers
- backend handlers and persistence rules
- optimistic client paths and reconciliation
- read-side parsing/normalization
- error mapping plus tests for invalid input and compatibility

### Shared component and local-fork checklist

When a UI bug is found in a shared component or in one screen-local copy, check:

- the shared component itself
- screen-local forks or duplicated implementations
- alternate consumers and render surfaces
- helper hooks and store selectors feeding the component
- tests at both shared-component level and at one consumer level

### Optimistic vs persisted state checklist

When client state and server state can diverge, check:

- optimistic payload construction
- server defaults and fallbacks
- sync/update wrapper contracts
- reconciliation after server response
- read-side normalization and display helpers
- failure and retry behavior

### Parallel entity parity checklist

When one entity flow is fixed, check whether the same concept exists in:

- work items
- projects
- views
- docs
- any sibling domain object with matching create/update/filter/display logic

### Fallback vs persisted path checklist

When local-only fallback state exists beside saved/shared state, check:

- local-only path
- persisted/shared path
- compatibility or correction layers between them
- UI mutation affordances on both
- tests proving they do not drift apart silently

## Companion change expectations

For each meaningful edit, ask what companion changes usually need to exist elsewhere in the stack. Treat missing companions as negative-space review targets.

Examples:

- **Schema or validator change:** route validation, backend validation, typed mappings, tests, read-side parsing, error handling
- **Backend default or fallback change:** optimistic client path, reconciliation, display helpers, compatibility behavior, tests
- **Shared component change:** local forks, alternate consumers, permissions, interaction handlers, tests
- **Status/enum/metadata change:** validators, metadata maps, filters, labels, ordering/grouping logic, migrations, tests
- **UI affordance change:** click path, state mutation, authorization, empty-state handling, tests

Do not assume the diff is complete just because the primary file was updated. Companion changes are often the missing part.

## Base-rate suspicion rule

If the same bug family has already appeared multiple times in the branch review, raise suspicion for that family across the rest of the branch.

Examples:

- repeated contract drift should increase suspicion of more contract drift
- repeated shared-vs-local copy misses should increase suspicion of more duplicated-surface misses
- repeated optimistic-vs-persisted drift should increase suspicion of more reconciliation gaps

Say when this elevated suspicion is in effect, and bias the challenger pass toward disproving safety on that family.

## Architecture standards usage

Use the `architecture-standards` skill selectively, not by default.

- When unsure whether a finding needs architecture guidance, load `references/architecture-review-bridge.md` first. It defines the boundary, ownership, and shared-contract triggers for invoking `architecture-standards`.
- When fixing issues raised by this review, use the `architecture-standards` skill if the remediation needs to align with the existing architecture shape, boundary rules, dependency direction, layering, module ownership, or long-lived design decisions.
- Use it when the codebase already has a reasonably coherent architecture and the review depends on boundaries, ownership, dependency direction, layering, or long-lived design choices.
- Use it when the correct fix needs to align with an existing architectural pattern and the skill will help validate that alignment.
- If the correct remediation should follow the repo's architecture rather than a narrow local patch, say so explicitly and use `architecture-standards` to guide the proper fix.
- Do not invoke it just because the codebase is messy. If the architecture is broadly inconsistent and the issue cannot be meaningfully solved through the current review scope, record the architectural debt as an Observation and focus on the safest code-aware fix for the issue at hand.
- Do not turn a small diff review into a ground-up redesign. Apply architecture guidance proportionally.

## Core concepts

**Turn**: A single review cycle. Turn 1 is the initial review. Each subsequent turn reviews the current state, compares against prior findings, and updates statuses. All turns live in one file — the review document.

**Finding**: A specific issue, flag, or design question. Each finding gets a unique ID (`F1-01`, `F2-01`) that persists across turns so resolution can be tracked inline.

**Review file**: One markdown file per content area in `.reviews/`, named after what's being reviewed (e.g. `auth-session-refactor.md`). A branch can have multiple review files if it touches unrelated areas. Each file contains all turns, all findings, all resolutions for that content area. This is purely local diff analysis — the files live in `.reviews/` and get committed alongside the code when the review is complete.

**Turn state**: Turn-based analysis state lives in the review file itself: scope, findings, validation history, confidence, residual risk, and what changed from one turn to the next. Do not split turn state across hidden sidecars or separate tracking files.

**Hotspot ledger**: A cumulative list inside the review file of recurring high-risk families for this branch or content area. Hotspots are checked first on later turns and updated when new repeated patterns appear or old ones are retired.

## Branch-risk recertification turns

Long-running reviews drift. Force a short branch-wide recertification turn every 5 turns or after any major fix cluster.

In a recertification turn, answer explicitly:

- what remains highest risk now?
- what bug family is most likely still under-reviewed?
- what previously fixed area should be rechecked?
- what has not been re-verified recently enough?

Recertification turns support the normal turn-based workflow; they do not replace ordinary re-review turns.

## Requested hardening coverage map

All requested hardening additions are implemented, but overlapping asks are intentionally normalized into single instruction sections so the skill stays explicit without repeating the same rule in multiple places.

### Closure and sibling coverage

- **Mandatory symmetry sweep after every serious finding** — see `Family closure for repeated bug classes`
- **Contract stack checklist** — see `Archetype-specific checklists -> Contract stack checklist`
- **Parallel entity parity / parallel implementation parity** — see `Parallel implementation parity` and `Parallel entity parity checklist`
- **Shared vs local fork checks** — see `Archetype-specific checklists -> Shared component and local-fork checklist`
- **Non-primary caller checks / non-primary path audit** — see `Non-primary path audit`

### Resolution and proof

- **Resolution proof requirement / formal resolution gate** — see `Resolution gate`
- **Proof burden for all-clear** — see `High-risk all-clear proof burden`
- **Turn-end blocker questions** — see `Step 4m. Final self-audit before concluding`
- **Must challenge one more heuristic** — see `Step 4m. Final self-audit before concluding`
- **Confidence penalties** — see `Confidence penalties`
- **Aging rule for old resolved findings** — see `Aging rule for resolved findings`

### Turn-based branch discipline

- **Do not over-index on the latest fix** — see `Do not over-index on the latest fix` and `Branch-totality reassessment`
- **Live-first triage gate / explicit live-first triage protocol** — see `Live-first triage for pasted findings`, `Finding triage`, and `Step 7: Re-review workflow`
- **Review hotspots section / hotspot ledger** — see `Hotspot ledger` and the review file format's `Hotspots` section
- **Branch-risk recertification cadence / re-certification turn rule** — see `Branch-risk recertification turns` and `Step 7: Re-review workflow`
- **Change archetype tag per turn** — see `Change archetype tags per turn` and the review file format

### Companion-surface and evidence checks

- **Expected companion changes audit / companion change expectations** — see `Companion change expectations`
- **Test adequacy check** — see `Step 3c. Run relevant verification`
- **Review graph step** — see `Step 3a1. Build a review graph for shared or risky surfaces`
- **Base-rate suspicion rule** — see `Base-rate suspicion rule`
- **Invariant and variant proof gates** — see `Invariant-first review gate`, `Variant matrix discipline`, and `references/bug-class-taxonomy.md`
- **External finding import** — see `Live-first triage for pasted findings` and `references/external-finding-import.md`
- **All-clear anti-patterns** — see `All-clear bar` and `references/all-clear-antipatterns.md`
- **Severity calibration** — see `Severity` and `references/severity-calibration.md`
- **Architecture bridge** — see `Architecture standards usage` and `references/architecture-review-bridge.md`
- **Evidence-backed miss learning** — see `Escaped bug feedback loop`, `references/miss-retrospective-template.md`, `references/escaped-review-benchmarks.md`, and `references/benchmark-scoring.md`

## Workflow

```
1. User asks for a review
2. Agent reads all .md files in .reviews/ — they're all review context
   - No files → Turn 1. Analyse the diff, name the file by content area, write findings.
   - Files exist → Read them all for context. The relevant file is the one covering
                   the areas touched by the current diff. Append the next turn to it.
                   If the current diff covers a new area not in any existing review,
                   create a new file.
3. User fixes issues
4. User asks for another review → back to step 2
5. When satisfied, user commits their code + the review file together
```

The review file is a working document that stays uncommitted throughout the review cycle. You commit it once at the end alongside your code. If you switch machines or lose the local file mid-review, you'll need to reference the file path manually to pick it back up — that's the tradeoff for keeping the workflow simple.

---

## Step 1: Initialise

### 1a0. Run review preflight when useful

For medium/high-risk reviews, long-running review loops, pasted external findings, or when context may be fragmented, start by running the bundled preflight script from the repository root. Resolve `scripts/review-preflight.sh` relative to this skill directory.

```bash
~/.codex/skills/diff-review/scripts/review-preflight.sh
```

Optionally pass the base ref:

```bash
~/.codex/skills/diff-review/scripts/review-preflight.sh origin/main
```

Use the output to seed the review file's branch, PR, changed-file, hotspot, and verification context. The script is a context collector, not a substitute for reading code.

### 1a. Set up `.reviews/` directory

```bash
mkdir -p .reviews
```

The `.reviews/` directory is NOT gitignored. The review file stays uncommitted during the entire review cycle — it's a local working document. You commit it once at the end alongside your code when the review is complete and you're ready to push.

**Cleanup convention:** Before merging to main/develop, delete `.reviews/`:
```bash
rm -rf .reviews/ && git add -A .reviews/ && git commit -m "chore: remove review artifacts before merge"
```
With squash merges, this happens automatically.

### 1b. Read existing reviews and determine turn

```bash
ls .reviews/*.md 2>/dev/null
```

Read all `.md` files in `.reviews/`. They're all review context — the agent picks up the full picture of what's been reviewed, what's open, what's resolved across all files. If no `.md` files exist, this is a new review (Turn 1).

### 1c. Get the diff

Always exclude `.reviews/` from the diff:

```bash
# Get all changes on this branch (most common — everything that's changed vs main/develop)
git diff main...HEAD -- . ':!.reviews/'

# Or staged changes if working incrementally
git diff --staged -- . ':!.reviews/'

# Or unstaged working changes
git diff -- . ':!.reviews/'
```

The diff command is just the mechanism to get the changes. Choose the primary review target in this order:

1. **Local working changes first** — unstaged and staged changes in the current tree
2. **Explicit PR or review-request diff second** — if there are no local changes, use the PR diff, review comments, or explicitly requested review context
3. **Branch vs base fallback third** — if neither local changes nor explicit PR diff context exists, compare the branch against `main` (or `develop` if that is the repo's real base)

If local changes exist, they are the primary review target even if a PR already exists, because the current tree is the authoritative code that may be submitted next.

**Turn 2+ — always collect both views of the work:**

```bash
# Current turn delta (what changed in this pass)
git diff -- . ':!.reviews/'
git diff --staged -- . ':!.reviews/'

# Cumulative branch diff (what the branch now contains in total)
git diff main...HEAD -- . ':!.reviews/'
```

Use the turn delta to focus the re-review. Use the cumulative branch diff and current tree to judge whether the branch is now safe overall. Never decide "all clear" from the turn delta alone.

**Turn 1 — naming the review file:**

After getting the diff, read the changed files and summarise what the changes are about. Name the review file after the content area, not the branch:

- Auth session handling changes → `.reviews/auth-session-refactor.md`
- Checkout flow bugfixes → `.reviews/checkout-flow-fixes.md`
- Supabase RLS policy updates → `.reviews/supabase-rls-policies.md`
- Mixed changes across areas → `.reviews/sprint-4-auth-and-checkout.md`

The filename should be descriptive enough that someone looking at `.reviews/` can tell what was reviewed without opening the file. Use lowercase kebab-case.

```bash
REVIEW_FILE=".reviews/{content-area-slug}.md"
```

**Scope is cumulative across turns.** The review file has a "Scope" section in the header that lists all files and areas touched across all turns. Each turn may add new files to the scope as fixes introduce changes to new areas. Update the scope section each turn — don't replace it, append to it. This gives a complete picture of everything that was reviewed.

Grab context:
```bash
git diff --staged --stat -- . ':!.reviews/'
git log --oneline -5
git branch --show-current
```

### 1d. Establish intended change before reviewing

Best-in-class review compares the diff against the intended outcome, not just against local coding preferences.

Gather intent from whatever exists:

```bash
git log --oneline --decorate -10
git diff --name-only main...HEAD -- . ':!.reviews/'
```

If available, also read:
- PR title and description
- Issue or ticket linked to the work
- Prior review comments or CI failures
- Commit messages explaining the refactor or bugfix

Then answer:
- What problem is this change trying to solve?
- What behavior is supposed to change?
- What behavior is supposed to stay the same?
- Does the diff contain scope creep, unrelated changes, or missing follow-through?
- Does the commit history suggest churn, partial reverts, or an unfinished refactor that the final diff may hide?
- What should have changed to support this work but appears untouched?

A great review catches both broken code and broken change intent.

---

## Step 2: Detect repo structure and tech stack

**Turn 1:** Run full detection and record the results in the review file header. This only needs to happen once — the stack doesn't change between turns on the same branch.

**Turn 2+:** Read the stack and repo type from the review file header. Skip detection entirely unless the diff includes new config files (e.g. a new `Dockerfile` added, `package.json` dependencies changed significantly) — in which case, re-detect and update the header.

### 2a. Monorepo detection

```bash
ls pnpm-workspace.yaml lerna.json nx.json turbo.json 2>/dev/null
ls -d packages/ apps/ services/ libs/ modules/ 2>/dev/null
cat package.json 2>/dev/null | grep -E '"workspaces"'
```

**If monorepo:** scope stack detection to affected packages only. Flag cross-package concerns.
**If single repo:** detect from project root.

### 2b. Stack detection

Look at project config files and load the relevant reference files from `references/`. Multiple should apply.

```bash
ls package.json tsconfig.json Cargo.toml pyproject.toml go.mod Gemfile pom.xml build.gradle Podfile composer.json pubspec.yaml 2>/dev/null
cat package.json 2>/dev/null | head -50
ls app.json expo.json next.config.* nuxt.config.* vite.config.* angular.json svelte.config.* 2>/dev/null
ls Dockerfile docker-compose.yml *.tf serverless.yml cdk.json 2>/dev/null
```

**Mobile:** react-native-expo, flutter, ios-native, android-native
**Web:** nextjs, nuxt-vue, angular, svelte, react-web, vanilla-web
**Backend:** python, go, rust, java-kotlin, ruby-rails, php-laravel, node-backend
**Services:** supabase, firebase
**Infra:** docker, ci-cd, infra
**Cross-cutting:** typescript (load alongside any TS project)

### 2c. Capture environment metadata

**Turn 1:** Run full environment capture after stack detection, so you only check relevant runtimes. Record everything in the review file header and in the Turn 1 metadata.

**Turn 2+:** Only capture per-turn context (date, time, commit SHA, IDE). The OS, package manager, and runtime versions are already in the header from Turn 1 — don't re-detect them unless the user has switched machines (which would be obvious from a different OS).

**Always capture (every turn):**
```bash
REVIEW_DATE=$(date +"%Y-%m-%d")
REVIEW_TIME=$(date +"%H:%M:%S %Z")
COMMIT_SHA=$(git rev-parse --short HEAD)
COMMIT_FULL=$(git rev-parse HEAD)

IDE="unknown"
if [ -n "$CLAUDE_CODE" ]; then IDE="Claude Code"
elif [ -n "$CURSOR_TRACE_ID" ] || [ -n "$CURSOR" ]; then IDE="Cursor"
elif [ -n "$WINDSURF_SESSION" ]; then IDE="Windsurf"
elif [ -n "$VSCODE_PID" ]; then IDE="VS Code"
elif [ -n "$TERM_PROGRAM" ]; then IDE="$TERM_PROGRAM"
fi
```

**Turn 1 only — full environment (cached in header):**
```bash
REMOTE_URL=$(git remote get-url origin 2>/dev/null || echo "no remote")
REPO_NAME=$(basename "$(git rev-parse --show-toplevel)")
OS_INFO=$(uname -s -r 2>/dev/null || echo "unknown")

# Package manager
PKG_MANAGER="unknown"
if [ -f "pnpm-lock.yaml" ]; then PKG_MANAGER="pnpm $(pnpm --version 2>/dev/null)"
elif [ -f "yarn.lock" ]; then PKG_MANAGER="yarn $(yarn --version 2>/dev/null)"
elif [ -f "package-lock.json" ]; then PKG_MANAGER="npm $(npm --version 2>/dev/null)"
elif [ -f "bun.lockb" ]; then PKG_MANAGER="bun $(bun --version 2>/dev/null)"
fi

# Runtimes — only capture what's relevant to the detected stack
# JS/TS projects:
NODE_VERSION=$(node --version 2>/dev/null)
# Python projects:
PYTHON_VERSION=$(python3 --version 2>/dev/null)
# Go/Rust/Java — only if detected:
GO_VERSION=$(go version 2>/dev/null | awk '{print $3}')
RUST_VERSION=$(rustc --version 2>/dev/null)
```

### 2d. Optional stack adapters

These adapters are overlays, not replacements. The core workflow still applies to every stack. Use only the adapters that match the detected stack or architecture.

#### Next.js / React adapter

Bias the review toward:

- server/client boundary issues: server components, client components, route handlers, server actions, and env exposure
- hydration, cache invalidation, optimistic UI, and duplicated state across hooks, stores, and query layers
- shared component vs screen-local fork drift
- auth/session handling across middleware, loaders, route handlers, and client refresh logic
- bundle/runtime boundary mistakes such as server-only code leaking into the client

#### Convex adapter

Bias the review toward:

- schema, validator, handler, and client/store contract alignment
- optimistic updates vs server reconciliation and snapshot normalization
- direct mutation/query callers that bypass higher-level route contracts
- optional fields, legacy documents, and deployment compatibility across old stored data
- index/query assumptions, pagination, and fan-out reads on shared surfaces

#### Rails adapter

Bias the review toward:

- controller params, model validations, and database constraints drifting apart
- callback/default behavior vs explicit controller/service behavior
- background jobs, mailers, and scripts that bypass the primary web request path
- transaction boundaries, migration safety, backfills, and irreversible data changes
- serializer/presenter/API contract drift and N+1 query regressions

#### Go services adapter

Bias the review toward:

- context propagation, cancellation, and timeout handling
- error wrapping, status-code mapping, retry behavior, and partial failure semantics
- nil vs zero-value ambiguity in structs, JSON encoding, and config
- goroutine safety, shared mutable state, channel shutdown, and leak-prone concurrency
- compatibility across protobuf/OpenAPI contracts, consumers, and background workers

#### Mobile adapter

Bias the review toward:

- platform parity across iOS and Android or native/web surfaces
- app lifecycle, offline caching, background sync, and stale local state
- permissions, deep links, push notifications, and navigation-state recovery
- native bridge/module assumptions, runtime config, and upgrade compatibility
- optimistic UI, persisted local state, and reconciliation after reconnect or relaunch

---

## Step 3: Gather codebase context (full-stack awareness)

### 3a. Maintain a branch-total review map

At the start of every turn, build or refresh a branch-total review map:

- files changed in the current turn
- files already in cumulative review scope from prior turns
- files directly referenced by prior open findings
- files directly referenced by prior resolved findings when the same bug family could reappear elsewhere
- sibling surfaces required by the bug-family matrix for any serious finding

Review current code across that map, not just newly modified files. If a file was central to a prior finding or to a repeated bug family, re-read its current version even if this turn did not modify it.

### 3a1. Build a review graph for shared or risky surfaces

When the diff touches a shared contract, shared abstraction, or repeated workflow, sketch a quick review graph:

- producers
- validators
- transformers
- persistors
- consumers
- display/read-side helpers
- tests

You do not need a formal diagram, but you do need an explicit mental or written graph. Use it to guide sibling closure and companion-change checks.

The diff alone is not enough. For every file in the diff, read the full file to understand surrounding code. Also read related files — imports, consumers, shared types, tests, and config touched by the same flow.

Minimum coverage per changed file:

- Read the entire file, not just the diff hunk.
- Trace direct dependencies used by the changed code.
- Trace direct callers, consumers, renderers, or downstream handlers affected by the change.
- Expand changed interfaces: exported functions, public types, components, hooks, routes, schemas, events, config surfaces, and shared utilities must have their consumers reviewed.
- Inspect shared types, schemas, validation, config, permissions, and tests that define or constrain the changed behavior.
- Follow the flow until the impact is understood end to end.
- Review deletions, moved code, and removed tests/guards with the same scrutiny as additions.

Do not stop after checking one consumer or one dependent module if the code is broadly reused. Keep expanding until the blast radius is clear.

**For each changed file:**
```bash
cat <file>

# Who consumes this file?
rg -l "import.*from.*<module-name>" --glob '*.ts' --glob '*.tsx' --glob '*.js' --glob '*.jsx' .

# What does this file depend on?
rg "^(import|from|require\\()" <file>

# Search for the same pattern elsewhere once a risk is found
rg "<relevant-pattern>" .

# Expand changed exported symbols / interfaces to consumers
rg "<exported-symbol-or-contract-name>" .
```

**For API/backend changes:** check route definitions, middleware, database schema, shared types, env config.
**For frontend changes:** check component tree (who renders this?), state management, API client functions, navigation/routing.

**Think in terms of the full data flow:**
```
User action → UI component → API call → Route handler → Business logic → Database → Response → UI update
```

Does this change break any link in that chain? Does it assume something upstream or downstream that isn't guaranteed?

Before you recommend a fix, map the likely touchpoints of that fix as well. A good review does not stop at "this line is wrong"; it checks whether changing that line also requires updates to consumers, validation, schemas, tests, retries, permissions, or other linked behavior.

Do the same depth of analysis for findings themselves. When you identify a bug or risk, keep digging until you understand the underlying cause, the full blast radius, and the most likely regressions a fix could introduce.

### 3b. Use MCP servers for live context (if available)

If MCP servers are connected, use them in **read-only mode** to gather live context that local files can't provide. Never make changes through MCP — only read.

**Supabase MCP:** Query table schemas, RLS policies, edge functions, and auth config to verify that code assumptions match the live database. For example, if the diff changes a query, check the actual table schema and indexes.

**Firebase MCP:** Check security rules, Firestore indexes, auth providers configuration.

**Google Drive / Notion / Confluence MCP:** Look up related design docs, architecture decisions, or API specs if referenced in comments or commit messages.

**GitHub MCP:** Check open issues, PR history, or CI status related to the changed files.

**Any other connected MCP:** If it provides relevant read-only context, use it.

**If an MCP server is not available but would be useful:** Note this in the review file. For example: "Unable to verify Supabase RLS policies — no Supabase MCP connected. Recommend manually checking that the `profiles` table has appropriate RLS for the new `role` column." This gives the user a clear action item.

### 3c. Run relevant verification

Static review is necessary but not sufficient. When the repo has executable checks, run them.

- Start with the most relevant targeted checks for the changed area: unit tests, integration tests, feature-specific test files, focused package tests, or reproduction steps for the touched flow.
- Run broader safety nets when relevant to the stack and blast radius: typecheck, lint, build, contract checks, migration verification, or e2e tests.
- If a shared abstraction, public API, auth path, payment flow, schema, or infra/config surface changed, lean toward broader verification rather than narrower verification.
- On re-review after fixes, rerun the checks that should prove the fix and catch regressions introduced by the remediation.
- If a risky area has no meaningful automated coverage, call that out as a finding or observation when appropriate.
- If you cannot run a useful check, say exactly why: missing dependencies, broken environment, unavailable services, prohibitive runtime, or no test harness.
- Review the tests themselves when they changed. Do not assume a changed test is valid just because it passes.
- When lockfiles, generated clients, migrations, snapshots, or compiled artifacts changed, verify they are consistent with the source change that produced them.

Test adequacy checks:

- Does a test cover the actual failure mode, or only the happy path?
- Does any test cover a sibling path, not just the edited site?
- Does the test prove the bug family is closed, or only that one code path now passes?
- Are mocks hiding the integration edge where the bug actually lived?

Passing tests are strong evidence only when they exercise the real failure mode or a convincing proxy for it.

Test storage rules:

- If a test should survive the review because it proves a real bug fix or guards against regression, add it to the normal project test suite near the affected code. Treat it as product code, not review metadata.
- Do **not** store permanent regression tests inside `.reviews/`. The review folder is for turn history and review evidence, not the repo's lasting test suite.
- Turn-specific verification belongs in the current turn's `Validation`, `Coverage note`, and `Residual risk / unknowns` sections.
- If you need a one-off repro command or temporary scratch script during review, reference it in the review turn and delete or ignore it before final cleanup unless the user explicitly wants it preserved.

Required verification matrix:

| Risk | Minimum verification expectation |
|------|---------------------------------|
| **Low** | Targeted tests or reproduction steps for the changed path, plus the most relevant fast safety net (`typecheck`, `lint`, or equivalent) |
| **Medium** | Targeted tests, core safety nets for the stack, and at least one broader check such as build/package tests/integration coverage |
| **High** | Targeted tests, broader package or integration coverage, core safety nets, build/contract checks, and explicit compatibility + release-safety review |
| **Critical** | Everything from High, plus the strongest available verification for failure modes, rollback constraints, migrations, and operational readiness |

If the expected verification for the assigned risk level cannot be run, say exactly what is missing and lower confidence.

Examples by stack:

```bash
# JavaScript / TypeScript
pnpm test --filter <package-or-test>
pnpm typecheck
pnpm lint
pnpm build

# Python
pytest path/to/tests
python -m pytest path/to/tests

# Go
go test ./...

# Rust
cargo test

# Ruby
bundle exec rspec path/to/spec
```

Record what you ran, what passed, what failed, and what could not be run.

---

## Step 4: Analyse the diff

Coverage gate before concluding the review:

- Confirm every changed file was examined.
- Confirm the current branch state, not just the current turn delta, was reassessed against prior findings and current scope.
- Confirm branch-totality proof names concrete non-delta rechecks, prior finding rechecks, and adjacent/resolved area revalidation rather than a generic claim.
- Confirm the remediation impact surface was audited: upstream callers, downstream consumers, adjacent workflows, dependencies, contracts, and side effects touched by the fix.
- Confirm remediation radius was classified into `must fix now`, `should fix now if cheap/safe`, and `defer` for meaningful findings.
- Confirm any adjacent weakness judged `must fix now` was fixed, carried as a live finding, or explicitly blocked with reason.
- Confirm the turn's change archetype tags were chosen and the matching checklists were applied.
- Confirm expected companion changes were audited for the main edits in scope.
- Confirm high-impact touchpoints were traced far enough to understand the blast radius.
- Confirm the review covers both what changed and what the changed code touches.
- Confirm relevant tests, checks, or executable verification were run when available, or explicitly note why they were not.
- Confirm the actual diff still matches the intended change and has not introduced scope creep or missed required follow-through.
- Confirm negative-space review was done: what should have changed but did not?
- Confirm deleted safeguards, changed tests, and repeated bug patterns were checked where relevant.
- Confirm any serious bug class received sibling closure across lifecycle, layer, entity, consumer, and caller surfaces, or explicitly mark closure as incomplete.
- Confirm any required non-primary path audit was done.
- Confirm the hotspot ledger was reviewed and updated if recurring families changed.
- Confirm the expected verification matrix for the assigned risk score was satisfied or explicitly blocked.
- Confirm a prevention artifact was added or consciously ruled out for meaningful fixes.
- If any part of the diff or impact path was not reviewed, mark the review as partial and say exactly what remains.

### 4m. Final self-audit before concluding

Before you say "no findings", "looks good", or "all clear", challenge your own review:

#### Turn-end blocker questions

- What is the most likely serious issue this review could still be missing?
- Which bug class from the taxonomy is most represented by this branch, and what direct evidence proves it is closed?
- Which assumption matters most, and what would break if it is false?
- Which high-risk path has the weakest direct evidence?
- Which sibling surface or parallel implementation is most likely to still carry the same bug family?
- Which part of the branch has not been revalidated recently enough to justify an all-clear?
- What same-family bug is most likely still elsewhere?
- What layer was least directly verified?
- What entity twin was not checked deeply enough?
- What non-primary caller or bypass path was least directly evidenced?
- What changed test, removed guard, or untouched dependency did you trust, and why?
- Which state variant was least directly checked: empty, legacy-invalid, scoped duplicate, transient container, or partial failure?
- If this shipped and caused a production incident tomorrow, what path would you investigate first?

#### Must challenge one more

- If there is still one live serious bug in this branch, where is it most likely?
- Which fix in this branch still looks too local?

If those answers expose weak evidence, lower confidence, keep the review partial, or add a follow-up check. Do not let a polished summary outrun the actual evidence.

### 4n. Similar-issue hunt and sibling closure

When a serious issue or suspicious pattern is found, do a short repo-wide hunt for sibling instances.

- Search for the same API misuse, unsafe assumption, missing guard, contract mismatch, or race-prone pattern elsewhere.
- Expand the hunt across lifecycle, layer, entity, consumer, and caller siblings when the issue sits on a shared abstraction or repeated implementation pattern.
- If similar instances exist, note whether they are in scope for this review, whether they were checked directly, and whether the pattern suggests a systemic issue rather than an isolated bug.
- If no siblings are found, say that the sibling search was done and which axes were checked.

### 4o. Release safety

For `High` and `Critical` risk changes, review release safety explicitly:

- Rollout path: feature flag, staged rollout, or direct release
- Rollback path: what can be safely reverted and what cannot
- Migration/backfill safety: ordering, lock risk, idempotency, and one-way operations
- Observability: logs, metrics, alerts, dashboards, or runbook support
- Compatibility window: old clients, old workers, stale jobs, stored data, or consumers on older payload versions

### Review categories

#### 4a. Bugs and logic errors (CRITICAL)
- Off-by-one errors, boundary conditions
- Null/undefined handling — are new code paths safe?
- Race conditions, especially in async code
- State mutations that could cause unexpected behaviour
- Logic contradicting the apparent intent
- Incomplete refactors — renamed in one place but not another
- Error handling gaps

#### 4b. Security issues (CRITICAL)
- Secrets, API keys, tokens in the diff
- SQL injection, XSS, injection vectors
- Auth/authz bypasses
- Insecure data handling — PII logged, sensitive data in URLs
- Dependency changes — untrusted or known-vulnerable packages
- CORS or permission changes widening the attack surface

#### 4c. Code quality and maintainability (IMPORTANT)
- Dead code introduced or left behind
- Duplicated logic that should be extracted
- Naming that obscures intent
- Missing or misleading comments on complex logic
- Overly complex functions
- Type safety erosion

#### 4d. Stack-specific concerns (IMPORTANT)
Load from the relevant reference file(s) for detailed criteria per stack.

#### 4e. Monorepo-specific concerns (IMPORTANT — only if monorepo)
- Shared package changes — do consumers handle the new interface?
- Workspace dependency version consistency
- Build order impacts
- Cross-package type export validity
- Config inheritance issues

#### 4f. Design intent vs bug (IMPORTANT)

Not everything that looks wrong is a bug. Before flagging, check for signals it might be intentional:
- A comment explaining the approach
- A consistent pattern used elsewhere in the codebase
- A deliberate tradeoff (e.g. denormalised data for performance)
- Feature flags or gradual rollout patterns

When you suspect a design decision, classify as a **Flag** rather than a **Bug**.

#### 4g. Operational risk (MODERATE)
- Database migrations that could fail or lock tables
- Config changes that affect deployment
- Environment variable additions
- Breaking API contract changes

#### 4h. Compatibility and contract safety (IMPORTANT)
- Public API shape changes
- Backward compatibility for callers and consumers
- Schema, event, or payload compatibility
- Mobile/web client version skew
- Feature flag defaults and rollout behavior

#### 4i. Performance and scalability (IMPORTANT)
- Hot-path regressions
- N+1 queries or extra network round trips
- Expensive rerenders or unnecessary recomputation
- Memory growth, caching regressions, or queue amplification
- Lock contention, retry storms, or fan-out cost

#### 4j. Observability and release readiness (IMPORTANT)
- Missing logs, metrics, tracing, or alerts for new failure modes
- Weak rollback story for migrations or config flips
- Missing runbook or operator context for risky changes
- Insufficient guardrails around one-way data changes

#### 4k. Test quality (IMPORTANT)
- Tests only assert the happy path
- Missing regression coverage for the actual bug
- Assertions too weak to catch the failure mode
- Mocks hiding real integration risk
- Snapshot churn without meaningful behavioral coverage

#### 4l. Dependency and generated artifact integrity (IMPORTANT)
- Lockfile changes that do not match the code changes
- Generated clients or types out of sync with source schemas
- Snapshot or fixture updates masking unintended behavior changes
- Dependency upgrades with silent breaking changes or widened attack surface

---

## Step 5: Root cause analysis for each finding

Every finding needs depth. Provide ALL of the following:

### Finding ID and classification

Every finding is one of four types. Choose the one that fits — if you're unsure between two, pick the more severe one.

| Prefix | Type | Definition |
|--------|------|------------|
| `B` | **Bug** | Something is broken or will break. The code doesn't do what it's supposed to — null references, logic errors, race conditions, missing error handling, incorrect return values, unhandled edge cases. Concrete, testable, wrong. |
| `S` | **Security** | A vulnerability, exposure, or access control gap. Exposed secrets, injection vectors, missing auth checks, RLS policy gaps, insecure data handling, CORS misconfigurations. Gets its own type because the response is different — security issues need specific remediation, not just a code fix. |
| `F` | **Flag** | Something looks off but might be intentional. Unusual patterns, suspicious logic, missing validation that could be deliberate, unconventional architecture choices without documentation. The developer needs to confirm whether it's a problem or a conscious design decision. If confirmed as a problem, it becomes a Bug or Security finding in the next turn. If confirmed as intentional, it becomes Accepted. |
| `O` | **Observation** | Not broken, not suspicious, but worth noting. Architecture patterns that could be improved, tech debt, refactoring opportunities, performance considerations, code quality improvements, dependency issues, operational readiness gaps. Things that would make the codebase better but aren't actively breaking anything. |

Format: `{prefix}{turn}-{sequence}` — e.g. `B1-01` (bug, turn 1, first finding), `S1-02` (security, turn 1, second), `O2-01` (observation, turn 2, first new finding).

These IDs persist across turns. `B1-01` is always `B1-01`, even when resolved in Turn 3.

### Severity

Every finding gets a severity rating regardless of type. A Bug can be Low (cosmetic). An Observation can be High (architectural debt compounding fast). A Flag can be Critical (potential auth bypass needing immediate confirmation).

For ambiguous severity, hidden broken flows, data integrity issues, compatibility breaks, partial-success behavior, or external findings that seem under-ranked, load `references/severity-calibration.md` before assigning severity.

- **Critical** — Must fix. Active bugs, security holes, data loss risk.
- **High** — Should fix soon. Problems that compound over time.
- **Medium** — Should fix. Improves velocity, reduces risk.
- **Low** — Nice to fix. Quality improvements, consistency.

### Root cause
Explain WHY the issue exists, not just what it is:
- Misunderstanding of the API or framework?
- Side effect of a refactor that missed this path?
- Data model assumption that doesn't hold in all cases?
- Copy-pasted from code that worked in a different context?
- Gap because the original author didn't consider this flow?

### Codebase implication
What's the blast radius? Go beyond the changed file:
- Which features or user flows does this affect?
- Which upstream callers, downstream consumers, or dependent systems does this change put at risk?
- Could this cause data corruption, not just a UI glitch?
- Does this affect other services or packages?
- Which adjacent workflows or shared dependencies now need revalidation because of the fix shape?
- Is this a pattern — does the same issue exist elsewhere?
- What happens in production if this ships as-is? Be specific.

### Evidence
Support the finding with concrete evidence:
- Exact file and line references
- Specific code path or data flow
- Test, typecheck, lint, build, or runtime signal if available
- Why this is a real risk in this codebase, not just a theoretical preference
- Search results or related usage sites when the issue may repeat elsewhere

### Solution options
At least two approaches where possible:
- **Quick fix**: Minimal change that resolves the immediate issue
- **Proper fix**: Right architectural approach if time allows

For each option, note any touchpoints that also need validation so the developer does not apply a local fix that breaks adjacent behavior. Include secondary checks when relevant: affected consumers, schema contracts, state transitions, permissions, retries, caching, migration safety, and test coverage.

For each option, say whether it should be applied uniformly across the relevant bug family or intentionally differ by context. Do not recommend a local fix shape that conflicts with sibling surfaces, adjacent workflows, or shared contracts unless that divergence is deliberate and defended.

For each option, state the remediation impact surface that must be revalidated: upstream callers, downstream consumers, adjacent workflows, dependencies, contracts, side effects, and any other fixes that must still compose cleanly with it.

If the proper fix should align to the existing architecture, say that explicitly and use the `architecture-standards` skill to shape the remediation rather than proposing a patch that only fixes the local symptom.

### Remediation radius
Classify the follow-through explicitly:

- **Must fix now:** adjacent weaknesses or companion changes that must land to avoid leaving a live bug or likely new regression
- **Should fix now if cheap/safe:** bounded adjacent improvements that materially reduce fragility without broadening scope much
- **Defer:** larger, speculative, or low-signal work that should be tracked but not folded into this fix

Do not put speculative cleanup or aesthetic refactors into `Must fix now`.

### Prevention artifact
State what will make this class of bug less likely to recur:

- regression test
- stronger validation, typing, or schema enforcement
- invariant assertion or runtime guard
- lint/static rule
- observability improvement
- targeted helper extraction or deletion of risky duplication

If none is appropriate, say why.

### Investigation prompt
A specific question or check the developer should do before choosing a fix:
- "Check whether `UserProfile.addresses` can be null in production by querying the database"
- "Look at how `OrderService.processPayment` handles retries — if idempotent, this race condition is less severe"
- "Confirm with the team whether `skipValidation` is intentional for admin users"

---

## Step 6: Write (or update) the branch review file

All output goes into a single file: `.reviews/{content-area-slug}.md`

**Turn 1:** Create the file with the header and first turn.
**Turn 2+:** Append the new turn to the existing file. Update the header status counts and scope. Mark prior findings as resolved, carried, or accepted inline.

### File format

```markdown
# Review: {content area description}

## Project context (captured on Turn 1 — not re-detected on subsequent turns)

| Field | Value |
|-------|-------|
| **Repository** | {repo-name} |
| **Remote** | {remote-url} |
| **Branch** | {branch-name} |
| **Repo type** | {single repo / monorepo (type)} |
| **Stack** | {e.g. React Native / Expo / Supabase / TypeScript} |
| **Packages affected** | {monorepo only, or "n/a"} |
| **OS** | {OS info} |
| **Package manager** | {pnpm/yarn/npm + version} |
| **Node** | {version, if relevant to stack} |
| **Python** | {version, if relevant to stack} |

## Scope (cumulative — updated each turn as new files are touched)

Files and areas reviewed across all turns:
- `src/hooks/useAuth.ts` — added Turn 1
- `src/api/client.ts` — added Turn 1
- `src/utils/cache.ts` — added Turn 1
- `src/hooks/useSession.ts` — added Turn 2 (introduced during fix for F1-01)
- `src/middleware/auth.ts` — added Turn 2

## Hotspots (cumulative — updated as recurring risk families emerge)

- `contract drift` — added Turn 2
- `shared/local duplication` — added Turn 3
- `optimistic vs persisted drift` — added Turn 4

## Review status (updated every turn)

| Field | Value |
|-------|-------|
| **Review started** | {date} {time} |
| **Last reviewed** | {date} {time} |
| **Total turns** | {N} |
| **Open findings** | {count} |
| **Resolved findings** | {count} |
| **Accepted findings** | {count} |

---

## Turn 2 — {date} {time}

| Field | Value |
|-------|-------|
| **Commit** | {sha} |
| **IDE / Agent** | {IDE} |

**Summary:** {2-3 sentence overview of what changed and the review outcome}

**Outcome:** {all clear | all clear with low-risk unknowns | partial review | blocked by open findings | blocked by missing verification}
**Risk score:** {low | medium | high | critical} — {why}
**Change archetypes:** {tags} — {why they apply this turn}
**Intended change:** {What this PR/diff is trying to do}
**Intent vs actual:** {Does the diff match that intent? Any scope creep or missing follow-through?}
**Confidence:** {high | medium | low} — {why}
**Coverage note:** {Key files, flows, consumers, tests, artifacts, and pattern searches reviewed}
**Finding triage:** {Prior findings or external findings classified as live | already fixed | accepted | stale | needs confirmation before remediation}
**Bug classes / invariants checked:** {Taxonomy classes and concrete invariants or state variants checked this turn}
**Branch totality:** {What was rechecked across the whole branch/current tree beyond the current turn delta}
**Sibling closure:** {Which lifecycle/layer/entity/consumer/caller siblings were checked for repeated bug classes}
**Remediation impact surface:** {Which adjacent callers, consumers, dependencies, workflows, contracts, and side-effect surfaces were revalidated because of the fix}
**Residual risk / unknowns:** {What could not be fully verified, and what that means for shipping confidence}

| Status | Count |
|--------|-------|
| New findings | X |
| Resolved from Turn 1 | Y |
| Carried from Turn 1 | Z |
| Accepted | W |

### Validation

- `{command}` — passed
- `{command}` — failed: {short failure summary}
- `{command}` — not run: {reason}

### Branch-totality proof

- **Non-delta files/systems re-read:** {What outside the latest edit set was rechecked}
- **Prior open findings rechecked:** {Which open items were revalidated against the current tree}
- **Prior resolved/adjacent areas revalidated:** {What previously closed or nearby areas were revisited and why}
- **Hotspots or sibling paths revisited:** {Which recurring families or alternate paths were rechecked}
- **Dependency/adjacent surfaces revalidated:** {Which callers, consumers, dependencies, workflows, or contracts were rechecked because of the remediation impact}
- **Why this is enough:** {Why the review has credible branch-wide coverage for this turn}

### Challenger pass

- `{done | not needed | blocked}` — {what the challenger pass focused on and what it changed}

### Resolved from Turn 1

#### B1-01 ~~[BUG] Critical~~ → RESOLVED — {short description}
**How it was fixed:** {description of the fix}
**Adjacent work handled:** {required companion or adjacent fixes that were made, or `none`}
**Follow-on findings opened:** {IDs of new findings discovered during remediation, or `none`}
**Verified:** {confirmation the fix addresses the root cause}
**Prevention artifact:** {test, guardrail, validation, telemetry, or `none` with reason}

#### F1-03 ~~[FLAG] Low~~ → ACCEPTED — {short description}
**Reason:** {why accepted — intentional design, known tradeoff, out of scope}

### Carried from Turn 1

#### S1-02 [SECURITY] High — STILL OPEN — {short description}
**Status:** {unchanged | partially addressed}
**Notes:** {any updates based on new context}

### New findings

#### O2-01 [OBSERVATION] Medium — `{file}:{line}` — {short description}

**Discovery source:** {primary review | remediation pass for B1-01 | sibling closure for B1-01 | dependency revalidation for B1-01}
**Related finding(s):** {B1-01, if this was discovered while fixing or rechecking another finding; otherwise `none`}

**What's happening:**
{Describe the issue in context of the codebase, not just the diff}

**Root cause:**
{Why this issue exists}

**Codebase implication:**
{What breaks, who's affected, blast radius}

**Solution options:**
1. **Quick fix:** {minimal change}
2. **Proper fix:** {architectural approach}

**Remediation radius:**
- **Must fix now:** {required adjacent or companion changes}
- **Should fix now if cheap/safe:** {bounded improvements worth taking if low risk}
- **Defer:** {larger or lower-signal work that should not expand this turn}

**Prevention artifact:** {test, validation, invariant, telemetry, helper extraction, or `none` with reason}

**Investigate:**
{Specific question or check to do before fixing}

> {relevant diff snippet}

### Recommendations

{Prioritised action plan based on everything in this turn — not per-finding, but the bigger picture.}

1. **Fix first:** {Which findings to tackle first and why — usually Critical bugs and security issues}
2. **Then address:** {Next priority — carried findings, high-severity observations}
3. **Patterns noticed:** {Any recurring themes across findings — e.g. "error handling is inconsistent across all API calls, not just the ones flagged here" or "the auth flow has multiple assumptions about session state that should be validated"}
4. **Suggested approach:** {How to tackle the fixes — e.g. "start with S1-02 as it's a security exposure, then B1-01 which may resolve O2-01 as a side effect"}
5. **Defer on purpose:** {Adjacent improvements that were identified but should not be rolled into this turn}

---

## Turn 1 — {date} {time}

| Field | Value |
|-------|-------|
| **Commit** | {sha} |
| **IDE / Agent** | {IDE} |

**Summary:** {2-3 sentence overview of what changed and overall assessment}

**Outcome:** {all clear | all clear with low-risk unknowns | partial review | blocked by open findings | blocked by missing verification}
**Risk score:** {low | medium | high | critical} — {why}
**Change archetypes:** {tags} — {why they apply this turn}
**Intended change:** {What this PR/diff is trying to do}
**Intent vs actual:** {Does the diff match that intent? Any scope creep or missing follow-through?}
**Confidence:** {high | medium | low} — {why}
**Coverage note:** {Key files, flows, consumers, tests, artifacts, and pattern searches reviewed}
**Finding triage:** {Externally supplied or inherited findings classified as live | already fixed | accepted | stale | needs confirmation}
**Bug classes / invariants checked:** {Taxonomy classes and concrete invariants or state variants checked this turn}
**Branch totality:** {What was checked across the full branch/current tree, not just the initial diff summary}
**Sibling closure:** {Which lifecycle/layer/entity/consumer/caller sibling surfaces were checked for repeated bug classes}
**Remediation impact surface:** {Which adjacent callers, consumers, dependencies, workflows, contracts, and side-effect surfaces were checked}
**Residual risk / unknowns:** {What could not be fully verified, and what that means for shipping confidence}

| Status | Count |
|--------|-------|
| Findings | X |

### Validation

- `{command}` — passed
- `{command}` — failed: {short failure summary}
- `{command}` — not run: {reason}

### Branch-totality proof

- **Non-delta files/systems re-read:** {What outside the initial summary or primary files was reviewed}
- **Prior open findings rechecked:** {Turn 1 may say `n/a` if none existed before the review}
- **Prior resolved/adjacent areas revalidated:** {Turn 1 may say `n/a` if no prior state exists}
- **Hotspots or sibling paths revisited:** {Which recurring families or alternate paths were checked}
- **Dependency/adjacent surfaces revalidated:** {Which callers, consumers, dependencies, workflows, or contracts were checked because of the remediation impact}
- **Why this is enough:** {Why the Turn 1 branch-wide review coverage is credible}

### Challenger pass

- `{done | not needed | blocked}` — {what the challenger pass focused on and what it changed}

### Findings

#### B1-01 [BUG] Critical — `src/hooks/useAuth.ts:42` — Session token not refreshed on re-auth

**What's happening:**
{...}

**Root cause:**
{...}

**Codebase implication:**
{...}

**Solution options:**
1. **Quick fix:** {...}
2. **Proper fix:** {...}

**Remediation radius:**
- **Must fix now:** {...}
- **Should fix now if cheap/safe:** {...}
- **Defer:** {...}

**Prevention artifact:** {...}

**Investigate:**
{...}

> {diff snippet}

#### S1-02 [SECURITY] High — `src/api/client.ts:15` — API key exposed in client bundle

{...same format...}

#### F1-03 [FLAG] Low — `src/utils/cache.ts:88` — Cache TTL set to 0

{...same format...}

### Recommendations

{Prioritised action plan based on all findings in this turn.}

1. **Fix first:** {Critical and high-severity items — what to tackle immediately}
2. **Then address:** {Medium-severity items}
3. **Patterns noticed:** {Recurring themes across findings}
4. **Suggested approach:** {Order of operations, dependencies between fixes}
5. **Defer on purpose:** {Adjacent improvements that should be tracked but not folded into this turn}
```

### Worked examples

Use these as style guides. They are intentionally short, but they show the level of specificity expected in a strong turn entry.

#### Example A — Strong Turn 1 on a contract-heavy diff

```markdown
## Turn 1 — 2026-04-20 14:05 BST

**Summary:** Reviewed schedule-field changes across route schemas, store optimistic paths, and backend handlers. The branch fixes one date-drift path but leaves sibling create/update surfaces inconsistent.

**Outcome:** partial review
**Risk score:** high — contract and persisted-state changes span multiple entrypoints and shared date helpers
**Change archetypes:** contract, optimistic-state, parallel-entity — project and work-item schedule logic changed in parallel
**Confidence:** medium — primary flow is well traced, but one sibling path remains open
**Coverage note:** reviewed route schemas, shared validators, store slices, backend handlers, server-wrapper mappings, date helpers, and targeted tests for schedule creation
**Finding triage:** external findings classified as live (2), already fixed (1), stale (1)
**Branch totality:** rechecked the full branch state for schedule fields across projects and work items, not just the current diff hunk
**Sibling closure:** checked create, patch, and direct-mutation paths; project create is fixed, work-item direct mutation remains divergent
**Residual risk / unknowns:** did not prove compatibility for legacy stored values beyond read-side parsing

### Validation

- `pnpm vitest run tests/convex/work-item-handlers.test.ts` — passed
- `pnpm typecheck` — passed

### New findings

#### B1-01 [BUG] High — `convex/app/work_item_handlers.ts:821` — work-item `dueDate` default still diverges from client-resolved calendar dates
```

#### Example B — Strong Turn 3 re-review after fixes

```markdown
## Turn 3 — 2026-04-20 18:20 BST

**Summary:** Re-reviewed the branch after schedule-contract fixes. The original route-path bug is closed, but the challenger pass still found one same-family direct-caller gap in the backend mutation path.

**Outcome:** blocked by open findings
**Risk score:** high — same contract family is still active and the branch is not yet systemically clean
**Change archetypes:** contract, release-safety — this turn is mostly revalidation of branch-total state
**Confidence:** medium — strong proof on fixed paths, incomplete proof on one bypass path
**Coverage note:** re-read all previously flagged files plus sibling handlers, tests, and server wrappers introduced by remediation
**Finding triage:** prior B1-01 resolved, B1-02 still live, one external comment stale after current-tree verification
**Branch totality:** reassessed current branch state vs base and revalidated previously resolved schedule findings against adjacent file changes
**Sibling closure:** reran the bug-family matrix across route, handler, direct caller, and optimistic client surfaces

### Challenger pass

- `done` — targeted non-primary callers and found one remaining direct backend mutation path that still accepts malformed schedule input
```

#### Example C — Strong all-clear on a lower-risk shared UI turn

```markdown
## Turn 5 — 2026-04-21 09:10 BST

**Summary:** Reviewed a shared list-row layout fix and its alternate consumers. The branch-local UI issue is closed, the shared component and copied board surface stay aligned, and targeted UI verification is sufficient for this risk level.

**Outcome:** all clear
**Risk score:** medium — shared UI surface, but localized blast radius and no contract mutation
**Change archetypes:** shared-ui — layout and display-property rendering only
**Confidence:** high — shared/local copies were checked and the relevant rendering tests pass
**Coverage note:** reviewed shared row component, board-card counterpart, display-property helpers, and focused UI tests
**Finding triage:** no inherited serious findings in this bug family remain live
**Branch totality:** rechecked the current branch versions of both list and board renderers before clearing
**Sibling closure:** verified shared component, local fork, and alternate render surface for the same display-property behavior

### Validation

- `pnpm vitest run tests/components/work-surface-view.test.tsx` — passed
- `pnpm typecheck` — passed
```

### Key rules for the file format

- **Newest turn at the top** (after the header). The current state should be immediately visible.
- **Project context is written once on Turn 1.** Stack, repo type, environment — all cached in the header. Not re-detected on subsequent turns unless config files changed in the diff.
- **Review status is updated every turn.** Counts, last reviewed timestamp, total turns.
- **Per-turn metadata is lightweight.** Just commit SHA, date/time, and IDE. Everything else is in the header.
- **Every turn states outcome and risk score.** The user should be able to tell immediately whether the diff is blocked, partially reviewed, or genuinely clear, and why.
- **Every turn states change archetypes.** Archetype tags make the review procedural and determine which checklists are mandatory that turn.
- **Every turn states intended change vs actual diff.** A good review checks correctness against intent, not just local code style expectations.
- **Every turn states confidence honestly.** Confidence should reflect actual review depth and runtime verification, not optimism.
- **Every turn states coverage explicitly.** If there are no findings, the coverage note must explain why that result is credible.
- **Every turn states finding triage explicitly when prior findings or external review comments exist.** Confirm what is still live in the current tree before treating a pasted or inherited finding as an open problem.
- **External findings get bug-class classification.** Use the taxonomy to explain what review lens missed them, even when the finding is stale or intentional in the current tree.
- **Escaped misses get a retrospective.** Use the retrospective template for any GitHub/Devin/CI/user finding that arrived after a prior review pass should reasonably have caught it.
- **Every turn states branch totality explicitly.** Turn 2+ must say what was reassessed across the whole branch/current tree beyond the latest edit set.
- **Turn 2+ proves branch totality concretely.** Generic claims like "rechecked the branch" are not enough; the turn must name non-delta rechecks, prior finding rechecks, adjacent/resolved area revalidation, and hotspot revisits.
- **Every turn states sibling closure explicitly.** If a repeated bug class was in play, the review must say which sibling surfaces were checked or why closure is incomplete.
- **Every turn states remediation impact explicitly.** Family closure is not enough; the turn should say which adjacent callers, consumers, dependencies, workflows, contracts, or side effects were revalidated because of the fix.
- **Every meaningful finding classifies remediation radius explicitly.** Distinguish what must land now from what is merely nice to have.
- **Review files track hotspots cumulatively.** Later turns should consult them before scanning for new issues cold.
- **Every turn states residual risk honestly.** Unknowns and blocked verification do not disappear just because the reviewer reached the end.
- **Every turn records validation.** Include the relevant tests/checks that were run, their outcomes, and anything that could not be executed.
- **High/Critical reviews record a challenger pass.** If it was not done, the review should say why.
- **Solutioning must stay family-aware.** If multiple related surfaces are being fixed or revalidated, the review should say whether the remediation pattern is shared, intentionally different, or still unresolved.
- **Adjacent fixes need evidence, not aesthetics.** Do not expand into refactor or cleanup territory unless the review can explain the concrete risk reduced by doing so now.
- **Meaningful fixes should leave a prevention artifact.** Prefer to reduce recurrence risk with a test, guardrail, stronger validation, or another bounded preventive control. If none is used, say why.
- **Remediation-discovered issues must be logged as first-class findings.** If a new bug is discovered while fixing or revalidating another finding, create a new finding ID, record the discovery source, and link it back to the triggering finding instead of silently folding it into the original.
- **Every finding keeps its original ID forever.** `B1-01` is always `B1-01`, even when resolved in Turn 3. Four prefixes: B (bug), S (security), F (flag), O (observation).
- **Resolved and accepted findings are updated in their resolution turn**, not in their original turn. The original turn stays as-is — it's the historical record.
- **Omit sections that are empty.** If Turn 2 has no new findings, skip "New findings". If nothing was resolved, skip "Resolved".
- **Every turn ends with Recommendations.** Turn 1 recommendations are the initial action plan. Turn 2+ recommendations evolve — they factor in what was fixed, what's still open, whether fixes addressed root causes, and any new patterns emerging from the changes. Not a repeat of individual findings, but the bigger picture of what to do next.
- **Findings beat nits.** Lead with the highest-severity issues first. Minor observations should never obscure bugs, security problems, regressions, or release risks.
- **No findings still requires proof.** If the review is clean, say why the reviewer has confidence: what was checked, what was run, and which risky paths were examined.
- **Turn 2+ is a branch-state review, not a patch-only review.** The latest fix diff is a lens, not the whole target. The branch can only be cleared if the current total branch state is credible.

---

## Step 7: Re-review workflow (Turn 2+)

When the user asks to re-review after making fixes:

1. **Read all `.md` files in `.reviews/`** — they're all context. The relevant review file is the one that covers the current diff's content area. Parse its header for cached stack/environment, cumulative scope, and all prior findings with their statuses.
2. **Get both the current-turn diff and the cumulative branch diff** (always excluding `.reviews/`). The current diff shows what changed this pass; the branch diff shows what the branch now contains in total.
3. **Update the cumulative scope and hotspot ledger** in the header — add any new files that appear in this turn's diff or in newly relevant sibling surfaces, and update recurring risk families as needed
4. **Choose the turn's change archetype tags** based on the current-turn delta plus current branch state. Use these tags to decide which checklists and hotspot rechecks are mandatory
5. **Triage prior findings and any externally supplied review comments against the current tree** — classify each one as live, already fixed, accepted, stale, needs confirmation, or superseded before planning remediation work. For multiple external findings, load `references/external-finding-import.md`. For external findings or missed prior review issues, load `references/bug-class-taxonomy.md`, assign bug classes, and use `references/miss-retrospective-template.md` when the miss exposes a review-process gap
6. **Re-read the codebase context** for all files in the current diff, plus files referenced in prior open findings, prior resolved findings with similar bug families, required sibling surfaces from the bug-family matrix, any shared abstractions or family members implicated by the remediation options, and the adjacent callers/consumers/dependencies in the remediation impact surface
7. **For each prior open finding, check the current code:**
   - **Resolved**: The code that caused the finding has been fixed. The fix addresses the root cause, not just the symptom, and does not introduce an obvious new issue in adjacent flows. Write a resolution note.
   - **Partially addressed**: Some improvement but the core issue remains. Update notes.
   - **Still open**: No relevant change. Carry forward.
   - **Regression**: A fix introduced a new variant of the original problem. Create a new finding referencing the original.
   - **Accepted**: User explicitly confirmed it's intentional or out of scope. Record their reasoning.
8. **Before marking a finding resolved, apply the resolution gate** — rerun the sibling hunt for that bug family, confirm non-primary paths and expected companion changes, assess the remediation impact surface across adjacent code, classify the remediation radius (`must fix now`, `should fix now if cheap/safe`, `defer`), and verify that targeted proof exists
9. **Revalidate aged resolved findings when needed** — if nearby files, adjacent contracts, or the same bug family changed materially after a finding was resolved, recheck that finding against the current tree even if it has been closed for multiple turns
10. **Run the relevant verification again** — rerun targeted tests/checks for the fixed area, at least one meaningful non-primary sibling path when appropriate, any broader safety nets required by the blast radius, and the specific checks needed to validate any `must fix now` adjacent work
11. **Analyse both the current diff and the branch-total current state for new findings** — fixes can introduce new bugs, untouched branch areas can still block readiness, and a locally sensible remediation can still be wrong if it conflicts with the broader bug family
12. **If remediation or revalidation reveals a new adjacent issue, document it immediately as a new finding** — assign a new ID, record the discovery source (for example `remediation pass for B1-01`), link it to the triggering finding, and update the resolved finding note if relevant so the review history stays traceable
13. **On long-running reviews, trigger a branch-risk recertification turn when appropriate** — every 5 turns or after a major fix cluster, answer: what remains highest risk now, what bug family is most likely still under-reviewed, what previously fixed area should be rechecked, and what has not been re-verified recently enough
14. **Append the new turn to the review file** and update the header status counts. Record concrete branch-totality proof, invariant/variant proof for the risky areas, bug-class classification for external or escaped findings, remediation radius decisions, any deferred adjacent improvements, remediation-discovered findings, and the prevention artifact used or consciously skipped.
15. **If all findings are resolved and no new issues found in the current branch state:** check `references/all-clear-antipatterns.md`, then write a final turn confirming the review is clean only if the anti-pattern check does not expose weak proof. Update the header to show 0 open findings. Tell the user: all clear to submit. The code is ready to commit and push.
16. **If investigation is incomplete or branch-totality proof is thin/generic:** do not give an all-clear. State that the review is partial, list the unreviewed files, sibling surfaces, hotspot families, impact paths, adjacent dependency surfaces, prevention gaps, or remediation-family coherence questions, and say what still needs checking.

---

## Escaped bug feedback loop

If the user later reports that review missed a bug, treat that as a process failure to learn from, not just a new isolated finding.

Load `references/bug-class-taxonomy.md` and `references/miss-retrospective-template.md` before writing the follow-up review turn. If the miss resembles an existing calibration case, also load `references/escaped-review-benchmarks.md`.

1. Reconstruct the escaped issue precisely: the failure mode, affected path, impact, and why it mattered.
2. Classify it by bug class:
   - use an existing taxonomy class when possible
   - if no class fits, record a candidate class in the review file rather than adding a narrow library-specific checklist
3. Identify the missed signal:
   - Was the evidence in the diff but overlooked?
   - Was connected code not traced far enough?
   - Was the wrong test/check run?
   - Did a passing test create false confidence?
   - Was the issue a repeated pattern elsewhere?
   - Was the missing proof an invariant, a state variant, a lifecycle assumption, a scope boundary, or an authority boundary?
4. Add or recommend a regression check that would catch this class next time.
5. Search the codebase for sibling occurrences of the same pattern.
6. Update the active review with the escaped finding and explicitly note the review gap so future turns do not repeat it.
7. If the miss is broadly reusable, add it to `references/escaped-review-benchmarks.md` as a calibration case.

The goal is not perfection theater. The goal is that every miss permanently improves the next review.

## Aging rule for resolved findings

Resolved findings are not permanently trusted on long-running branches.

Revalidate a resolved finding when one or more of these are true:

- nearby files or adjacent contracts changed materially after the resolution
- the same bug family resurfaced elsewhere in the branch
- the branch has continued for many turns since the resolution
- branch-totality reassessment identifies that old resolution as adjacent to newly risky work

When revalidated, either keep it resolved with fresh evidence or reopen it in the new turn notes.

---

## Historical evaluation

To improve toward a 99% success rate, evaluate this skill against known past changes, not just live diffs.

- Maintain a benchmark set of historical PRs/diffs with known outcomes: solid changes, missed bugs, regressions, security issues, migration problems, and false all-clears.
- Store compact benchmark prompts and expected review lenses in `references/escaped-review-benchmarks.md`.
- Score benchmark attempts with `references/benchmark-scoring.md` so skill changes are evaluated by missed issue classes, false all-clears, and proof quality.
- Periodically run the review process against that benchmark set and score:
  - missed Critical/High issues
  - false all-clears
  - noisy low-value findings
  - verification compliance by risk level
  - whether sibling-pattern hunts and release-safety checks were performed when needed
- Use escaped bugs and painful review misses to expand the benchmark set over time, but prefer general bug classes over one-off framework details.
- Prefer prompt/process changes that improve benchmark results over changes that merely sound stricter.

The benchmark is the truth surface. Without it, "better" is mostly intuition.

---

## File structure

```
.reviews/
├── auth-session-refactor.md       # named after the content area, not the branch
├── checkout-flow-fixes.md         # another review
├── supabase-rls-policies.md       # another review
```

One file per review. All turns inline. No subdirectories, no JSON sidecars. The markdown file is the single source of truth.

`.reviews/` stores turn-based review state, not executable product tests. Keep durable regression tests in the normal test directories of the codebase. Keep temporary review-only commands or repro notes in the review markdown unless there is a strong reason to use a separate scratch file.

The filename describes what's being reviewed — someone looking at `.reviews/` should be able to tell what each file covers without opening it.

The file stays uncommitted while you're iterating. When the review is complete (all clear), commit everything together:
```bash
git add -A
git commit -m "feat: auth refactor (reviewed)"
```

The review file ships with the branch as a record of what was checked, what was found, and how it was resolved. Anyone reviewing the PR can read it for context.

---

## Edge cases

- **Very large diffs (500+ lines):** Warn the user. Suggest breaking into logical chunks. Focus on highest-risk files first, but do not call the review complete until every file in scope has been covered. If a single pass cannot cover the whole diff, mark the review as partial and list what remains.
- **Generated files or lockfiles changed:** Review whether those updates are justified by the source change and whether stale or accidental churn is present.
- **Binary files or assets:** Skip the binary internals, but still review the code, config, references, loading paths, and runtime assumptions around them. Note any areas that could not be verified directly.
- **Tests cannot run:** Say exactly what blocked verification and how that changes confidence. Missing runtime verification on a risky path is itself review context.
- **Merge commits:** Suggest reviewing only feature branch changes.
- **Empty diff:** Help the user figure out why — wrong branch? Forgot to stage?
- **User wants to accept a finding:** Mark as accepted with reasoning. Don't revisit in future turns.
- **Fresh start on existing review:** Ask the user if they want to archive the existing file (rename to `.reviews/{slug}.archived.md`) or continue from the last turn.
- **Multiple branches in parallel:** Each review is its own file named by content area — no conflicts even if working on multiple branches.

---

## Tone

Be direct and specific. Reference exact lines and file names. If something's a bug, call it a bug. If something looks intentional but risky, say so and explain the tradeoff.

Acknowledge good work. If a fix properly addresses a root cause, say so in the resolution note. The goal is to be the kind of reviewer you'd actually want on your team: thorough, honest, constructive, and builds confidence that the code is solid before it goes out.

Investigation prompts should be genuine questions, not interrogations. "Check whether X is possible in production" is better than "You failed to consider X."

---
name: repo-audit
description: Run a full codebase audit covering bugs, security, architecture, performance, refactoring opportunities, and tech debt — with root cause analysis and iterative turn-based tracking. Use this skill whenever the user asks to audit a repo, review the full codebase, assess code quality, find tech debt, identify refactoring opportunities, do a health check on the project, or says things like "audit this repo", "review the whole codebase", "what's wrong with this project", "find all the issues", "tech debt assessment", "codebase health check", "what should we refactor", "security audit", "performance review", "architecture review", "is this codebase in good shape", or "give me an honest assessment". Also trigger when the user asks for a comprehensive review that goes beyond a single diff — when they want the full picture, not just what changed.
---

# Repo Audit

A full codebase audit system that analyses the current repository state: architecture, dependencies, security posture, correctness risks, performance, operational readiness, and maintainability. It produces a structured assessment with root cause analysis, prioritised findings, and actionable remediation paths.

Supports both one-time assessments and iterative turn-based audits where the team fixes issues and re-audits to track progress. On Turn 2+, the audit target is the current repo state, not just the latest fix diff.

## Auditor stance

When running this skill, operate as a world-class software risk analyst: a reviewer with deep practical experience across bugs, security, reliability, architecture, performance, operability, and QA.

Think like an owner, not a scanner. Read enough surrounding code to understand invariants, dependencies, callers, consumers, shared types, data flow, failure modes, deployment impact, and maintenance cost before deciding something is wrong or recommending a fix.

Be strict about correctness and long-term health, but stay grounded in the actual codebase. The goal is not to produce the most sophisticated theoretical answer. The goal is to identify the highest-signal issues and drive toward remediation that solves the real problem without creating new ones elsewhere.

## Remediation stance

Audit findings and re-audits with full code awareness:

- Never treat a fix as isolated to the edited lines. Check what the issue touches and what the proposed remediation would touch: callers, consumers, shared types, state transitions, persistence, config, tests, and adjacent error paths.
- Prefer fixes that address root cause without widening coupling, duplicating logic, breaking contracts, or introducing a different failure mode downstream.
- Treat `Resolved` as a high bar: the original issue is fixed, the root cause is addressed, and the remediation does not create an obvious regression in nearby flows.
- If the safest action is a narrow fix now and a broader cleanup later, say so explicitly. Separate must-fix work from follow-on improvements.

## Investigation standard

This skill is only useful if the investigation is thorough. Audit the repo deliberately and keep expanding outward until you understand what each issue affects.

- Do not stop at the first plausible explanation or the first issue you find.
- Turn over every stone on the risky path: callers, consumers, shared utilities, schemas, tests, config, migrations, permissions, retries, caches, feature flags, background jobs, and operational side effects.
- Shared abstractions demand deeper tracing. If a file or contract is reused across the codebase, inspect enough usage sites to understand the real blast radius before concluding it is safe or unsafe.
- An audit is not complete just because the surface files were scanned. It is complete when you can explain the full impact of the current repo state and why the untouched but connected code still holds.
- If you cannot fully audit the whole requested scope in the current pass, say so explicitly and list what remains unreviewed. Never imply "clean bill of health" on a partial investigation.

## Audit discipline

Operate like a senior architecture/security/code-health reviewer, not a linter.

- Start by understanding intended system shape, then audit for drift and failure modes.
- Prioritize findings that create user risk, production risk, security exposure, data integrity risk, operational pain, or developer footguns.
- Distinguish clearly between must-fix findings and lower-signal observations. Do not bury serious issues in a long list of minor comments.
- Do not manufacture noise for the sake of appearing thorough. The standard is depth and accuracy, not comment volume.
- Be willing to say "no new findings" when the current repo state is genuinely solid and sufficiently verified.

## Clean-bill bar

Do not give a "healthy / clean" conclusion unless all of the following are true:

- The audit scope is understood and the current repo state was actually examined.
- Every high-risk area in scope was reviewed.
- High-risk connected code paths were traced far enough to understand the blast radius.
- Relevant tests and checks were run, or the lack of verification is explicitly called out and accepted as low enough risk.
- No open Critical or High findings remain inside the audited scope.
- Any remaining uncertainty is minor enough that calling the codebase healthy is still defensible.

If those conditions are not met, the correct outcome is not "clean". It is "partial audit", "open findings remain", or "needs follow-up verification".

## High-risk clean-bill proof burden

For `High` and `Critical` audits, "no open findings" is not enough by itself.

Before giving a clean conclusion, confirm all of the following explicitly:

- the current repo state was reassessed this turn
- the hotspot ledger was reviewed this turn
- sibling closure was completed for every serious bug family touched in prior turns
- relevant targeted verification was rerun, not just inherited from an older turn
- the challenger pass completed
- the weakest-evidence areas are called out explicitly

If any of those are missing, the outcome must remain partial or blocked even if no fresh finding was written this turn.

## Anti-blind-spot checks

Before concluding the audit, actively look for what auditors commonly miss:

- **Negative space:** what should have changed but did not? Callers, validation, tests, docs, config, migrations, feature flags, monitoring, cleanup, or rollback handling.
- **Deleted safeguards:** removed guards, removed tests, removed validation, removed retries, or deleted error handling can be as risky as added code.
- **Pattern siblings:** when you find one bug pattern, stop and build a sibling matrix. Search for the same pattern across lifecycle variants, layers, parallel entities, alternate consumers, and non-primary callers. Do not assume a single occurrence unless the search proves it.
- **Refactor debris:** stale names, half-moved files, dead code, duplicate paths, partial reverts, generated artifacts that no longer match source, and Finder-style duplicate files.
- **False confidence:** passing tests do not overrule contradictory code evidence, and broad CI green does not prove a risky area is safe if coverage is weak.

## Risk escalation

Not every audit surface needs the same level of scrutiny. Raise audit depth aggressively for high-risk areas.

Treat these as high-risk by default:

- auth, authz, session, permissions, impersonation, tenancy, or secrets handling
- payments, billing, pricing, entitlements, quotas, or irreversible user actions
- migrations, backfills, schema changes, data deletion, or one-way data transforms
- shared libraries, design systems, public APIs, SDKs, events, contracts, or widely reused utilities
- concurrency, retries, queues, caches, locks, background jobs, or distributed workflows
- infra, deployment, config, feature flags, rollout controls, or operational toggles

For high-risk areas:

- prefer broader verification over narrow verification
- review failure modes, retry behavior, rollback paths, and partial-success states explicitly
- check compatibility across old and new clients, callers, consumers, payloads, and stored data where relevant
- expect stronger evidence before giving medium or high confidence
- if the environment prevents meaningful verification, say so and lower confidence rather than hand-waving

## Risk score

Assign every audit turn a risk score before concluding the pass:

- **Low**: localized audit slice, small blast radius, strong direct coverage, easy rollback
- **Medium**: multiple subsystems or flows touched, moderate shared-surface impact, some uncertainty
- **High**: shared abstractions, contracts, auth/data integrity, migrations, concurrency, or broad blast radius
- **Critical**: money, permissions, destructive data paths, one-way transforms, infra toggles, or failure consequences that are severe

State the score in the audit and let it drive scrutiny:

- **Low**: targeted audit plus targeted verification
- **Medium**: full flow tracing plus targeted verification and safety-net checks
- **High**: full flow tracing, broader verification, compatibility/release-safety review, and challenger pass
- **Critical**: treat as production-risk work. Require the strongest evidence available, explicit residual risks, and a challenger pass before any clean conclusion

## Process proportionality and stopping rule

The goal is fail-safe auditing, not maximum ceremony for its own sake.

- Apply the full guardrail set when the risk score, change archetypes, hotspot ledger, or escaped-finding history justify it.
- For low-risk and well-evidenced turns, use the lightest process that still satisfies the active obligations.
- Stop adding new audit machinery when the current risk obligations are met, the evidence is strong enough to support the conclusion, and additional process is unlikely to change the outcome.
- Do not skip mandatory closure work for serious findings just because the local diff is small.
- Do not force high-ceremony checks on every low-risk turn just because earlier turns were high risk. Reassess the repo each turn, then apply the proportional process for that turn’s actual risk.
- If in doubt between two levels of scrutiny, choose the stricter one and say why.

## Independent challenger pass

For `High` and `Critical` audits, run a second pass whose job is to disprove the first pass’s confidence.

- If an independent review surface is available, use it.
- If not, do a fresh adversarial pass yourself after the main audit: assume there is at least one serious missed issue and go hunting for it.
- In the challenger pass, focus on the weakest-evidence areas: untouched dependencies, deleted safeguards, compatibility assumptions, migrations, rollout paths, test blind spots, and stale architectural assumptions.
- If the challenger pass finds uncertainty the first pass did not resolve, lower confidence or block the clean conclusion.

## Confidence penalties

Lower confidence automatically when one or more of these are true:

- sibling closure is incomplete
- only the primary path was tested
- only one layer was reviewed for a contract or architecture bug
- no non-primary caller audit was done where bypass paths likely exist
- external findings were not triaged against the current tree first
- repo-total reassessment was not done on Turn 2+
- hotspot ledger was not checked on a long-running audit
- previously resolved adjacent findings were not revalidated despite substantial nearby change

When these penalties apply, say so explicitly in the confidence note rather than keeping generic medium/high confidence language.

## Family closure for repeated bug classes

For every serious finding (`High`/`Critical` Bug or Security issue), run a symmetry sweep before calling the issue resolved.

When a Bug or Security finding lands on a shared abstraction, contract surface, duplicated implementation, or parallel entity flow, do not treat it as a single-site issue.

Build a sibling matrix across:

- **Lifecycle siblings:** create, update, patch, rename, delete, import, optimistic apply, reconcile, background sync, backfill
- **Layer siblings:** UI, shared component, store, route/API, server wrapper, backend handler, schema/validator, persistence, tests
- **Entity siblings:** parallel entities implementing the same concept
- **Consumer siblings:** screen-local copies, shared helpers, alternate screens, alternate routes, alternate render surfaces
- **Caller siblings:** direct server callers, scripts, jobs, migrations, webhooks, or any path that bypasses the primary route

Record:

- primary site
- sibling sites checked
- sibling sites fixed
- sibling sites intentionally out of scope
- verification run on at least one non-primary sibling path when risk warrants it

Do not mark the finding resolved until this closure pass is complete. If closure is incomplete, the audit outcome must remain partial.

## Resolution gate

A finding cannot be marked `Resolved` unless all of the following are true:

- the root cause is addressed, not just the local symptom
- the sibling/family sweep is complete
- the remediation shape is coherent across the bug family or any intentional divergence is explained
- the remediation impact surface was assessed across adjacent callers, consumers, dependencies, and contracts
- any `must fix now` adjacent weakness uncovered during remediation was fixed, kept open, or explicitly blocked
- at least one non-primary path was checked when bypass paths plausibly exist
- targeted verification ran for the affected behavior
- recurrence risk was reduced with a prevention artifact, or the audit explains why none is practical here
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
- `Defer` — speculative cleanup, broad refactors, style consistency, architecture redesign, migrations, or any change whose risk/scope is disproportionate to the current fix

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

For any serious finding on a contract surface, shared abstraction, repeated workflow, or architecture seam, explicitly ask:

- what bypasses the main route, main workflow, or primary abstraction?
- what writes this data or enforces this behavior directly?
- what background job, script, migration, webhook, or alternate server wrapper touches the same behavior?
- what alternate screen, alternate store action, or alternate render path implements the same action?

Record the result of this audit in the turn notes when relevant. If no meaningful non-primary path exists, say that explicitly.

## Parallel implementation parity

When a bug is found in one implementation of a repeated concept, check the parallel implementations before concluding the audit.

Common examples:

- work item vs project
- saved view vs fallback/local-only view
- shared editor vs screen-local editor
- create route vs patch route vs direct mutation
- API worker vs background worker implementation of the same contract

If parity was checked, say so. If not, keep the finding open or mark the audit partial.

## Repo-total reassessment

On Turn 2+, the authoritative audit target is the current repo state, not just the incremental fix diff.

Every re-audit must look at:

- the current-turn delta
- the cumulative branch or repo state
- the current-tree state of previously flagged areas, even if untouched this turn
- the current-tree state of sibling surfaces for repeated bug classes

Use the fix delta to focus attention. Use the repo-total state to decide codebase health. Never give a clean conclusion based only on the latest edit set.

## Repo-totality proof requirement

On Turn 2+, the audit file must prove repo-total reassessment concretely, not just claim it.

The repo-totality proof should name:

- non-delta files, systems, or consumers that were re-read
- prior open findings that were rechecked against the current tree
- prior resolved or adjacent areas that were revalidated because the latest work could have disturbed them
- hotspot families, sibling paths, or non-primary paths that were revisited
- why those rechecks are enough to support the stated repo confidence

If the `Repo totality` note or supporting proof only restates the latest diff files, the audit cannot conclude `clean in audited scope`. Mark the turn partial or blocked and keep digging.

## Do not over-index on the latest fix

On Turn 2+, the latest patch is a clue, not the whole target.

- the current repo state is the object under audit
- the latest fix diff is only the fastest way to find what changed most recently
- previously changed high-risk areas can still block a healthy conclusion even when untouched this turn

If the current tree is not credible overall, do not let a clean-looking fix diff drive a clean conclusion.

## Live-first triage for pasted findings

When findings come from outside the current audit pass, classify each one against the current tree before acting on it:

- `live`
- `already fixed`
- `stale`
- `intentional`
- `needs confirmation`

Only after this triage should remediation or re-audit planning begin. Do not assume externally supplied findings are still open just because they were once valid.

## Common miss archetypes

Expand the audit automatically when the repo state touches one of these recurring miss patterns:

- **Contract surfaces:** the same field or rule can enter through create, update, patch, rename, delete, import, and direct-server paths
- **Parallel entity flows:** similar behavior implemented separately across peer entities or services
- **Shared component plus local forks:** a bug fixed in one screen copy may still exist in the shared primitive or another surface-specific copy
- **Optimistic vs persisted state:** client optimistic logic, server defaults, reconciliation, and read-side normalization can drift apart
- **Fallback vs persisted paths:** local-only fallback state often diverges from saved or shared state paths
- **Template or design ports:** imported UI shells often introduce dead affordances or product-capability drift across multiple surfaces
- **Calendar date and timezone logic:** defaults, server fallbacks, storage formats, update paths, and display helpers often drift as a family
- **Validation and typed-error stacks:** schema validation, route validation, server wrapper mappings, and backend handler validation frequently diverge
- **Architecture seam drift:** route/controller, service, domain, data, and worker boundaries no longer agree on ownership or invariants

## Change archetype tags per turn

At the top of every turn, assign one or more archetype tags that describe the current audit surface. These tags drive which checklists and hotspot rechecks are mandatory for that turn.

Suggested tags:

- `contract`
- `shared-ui`
- `optimistic-state`
- `parallel-entity`
- `migration`
- `release-safety`
- `infra`
- `security`
- `architecture`
- `performance`

If multiple apply, list all of them and name the primary one. If none clearly apply, say so and proceed with the general workflow. On Turn 2+, archetype tags are based on the current repo state and current-turn delta together, not just the latest patch.

## Archetype-specific checklists

When the audit matches one of these archetypes, explicitly check the listed surfaces before concluding the turn.

### Contract stack checklist

When a payload field, schema, validation rule, or typed error changes, check:

- create / update / patch / rename / delete / import / direct-mutation entrypoints
- route-layer validation and route schema shape
- shared schema/validator definitions
- client/store validation where applicable
- server-wrapper mappings and direct callers
- backend handlers and persistence rules
- optimistic client paths and reconciliation
- read-side parsing/normalization
- error mapping plus tests for invalid input and compatibility

### Shared component and local-fork checklist

When a UI or architecture issue is found in a shared component or in one screen-local copy, check:

- the shared component or abstraction itself
- screen-local forks or duplicated implementations
- alternate consumers and render surfaces
- helper hooks, stores, selectors, or service calls feeding the component
- tests at both shared level and at one consumer level

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

- peer entities in the domain model
- sibling services or packages
- client and server copies of the same contract
- primary and fallback implementations

### Fallback vs persisted path checklist

When local-only fallback state exists beside saved/shared state, check:

- local-only path
- persisted/shared path
- compatibility or correction layers between them
- UI mutation affordances on both
- tests proving they do not drift apart silently

### Architecture seam checklist

When the audit surfaces a boundary problem, check:

- route/controller responsibility
- service/domain responsibility
- data/persistence ownership
- worker/job/async ownership
- error translation across layers
- dependency direction and import boundaries

## Companion change expectations

For each meaningful change or finding, ask what companion changes usually need to exist elsewhere in the stack. Treat missing companions as negative-space audit targets.

Examples:

- **Schema or validator change:** route validation, backend validation, typed mappings, tests, read-side parsing, error handling
- **Backend default or fallback change:** optimistic client path, reconciliation, display helpers, compatibility behavior, tests
- **Shared component change:** local forks, alternate consumers, permissions, interaction handlers, tests
- **Status/enum/metadata change:** validators, metadata maps, filters, labels, ordering/grouping logic, migrations, tests
- **UI affordance change:** click path, state mutation, authorization, empty-state handling, tests
- **Architecture boundary change:** ownership docs, tests, dependency direction, error translation, and rollout compatibility

Do not assume the current state is complete just because the primary files were updated. Companion changes are often the missing part.

## Base-rate suspicion rule

If the same bug family has already appeared multiple times in the audit, raise suspicion for that family across the rest of the repo.

Examples:

- repeated contract drift should increase suspicion of more contract drift
- repeated shared-vs-local copy misses should increase suspicion of more duplicated-surface misses
- repeated optimistic-vs-persisted drift should increase suspicion of more reconciliation gaps
- repeated architecture seam drift should increase suspicion of more boundary violations

Say when this elevated suspicion is in effect, and bias the challenger pass toward disproving safety on that family.

## Architecture standards usage

Use the `architecture-standards` skill selectively, not by default.

- When fixing issues raised by this audit, use the `architecture-standards` skill if the remediation needs to align with the existing architecture shape, boundary rules, dependency direction, layering, module ownership, or long-lived design decisions.
- Use it when the codebase already has a reasonably coherent architecture and the audit depends on boundaries, ownership, dependency direction, layering, or long-lived design choices.
- Use it when the correct fix needs to align with an existing architectural pattern and the skill will help validate that alignment.
- If the correct remediation should follow the repo's architecture rather than a narrow local patch, say so explicitly and use `architecture-standards` to guide the proper fix.
- Do not invoke it just because the codebase is messy. If the architecture is broadly inconsistent and the issue cannot be meaningfully solved through the current audit scope, record the architectural debt as an Observation and focus on the safest code-aware fix for the issue at hand.
- Do not turn a focused audit into a ground-up redesign. Apply architecture guidance proportionally.

## Core concepts

**Turn**: A single audit cycle. Turn 1 is the initial audit. Each subsequent turn audits the current repo state, compares against prior findings, and updates statuses. All turns live in one file.

**Finding**: A specific issue, flag, or opportunity. Each finding gets a typed ID (`B1-01`, `S1-02`, `F1-03`, `O1-04`) that persists across turns so resolution can be tracked inline.

**Audit file**: One markdown file per audit in `.audits/`, named after the audit scope (for example `full-codebase-audit.md`, `api-layer-audit.md`). Contains all turns, all findings, and all resolutions for that audit scope.

**Turn state**: Turn-based audit state lives in the audit file itself: scope, findings, validation history, confidence, residual risk, hotspot ledger, and what changed from one turn to the next. Do not split turn state across hidden sidecars or separate tracking files.

**Hotspot ledger**: A cumulative list inside the audit file of recurring high-risk families for this repository or audit scope. Hotspots are checked first on later turns and updated when new repeated patterns appear or old ones are retired.

## Branch-risk recertification turns

Long-running audits drift. Force a short repo-wide recertification turn every 5 turns or after any major fix cluster.

In a recertification turn, answer explicitly:

- what remains highest risk now?
- what bug family is most likely still under-audited?
- what previously fixed area should be rechecked?
- what has not been re-verified recently enough?

Recertification turns support the normal turn-based workflow; they do not replace ordinary re-audit turns.

## Requested hardening coverage map

This skill inherits the same turn-based guardrail family as `diff-review`, but adapted to full-repo audits instead of diff-only review.

### Closure and sibling coverage

- **Mandatory symmetry sweep after every serious finding** — see `Family closure for repeated bug classes`
- **Contract stack checklist** — see `Archetype-specific checklists -> Contract stack checklist`
- **Parallel entity parity / parallel implementation parity** — see `Parallel implementation parity` and `Parallel entity parity checklist`
- **Shared vs local fork checks** — see `Archetype-specific checklists -> Shared component and local-fork checklist`
- **Non-primary caller checks / non-primary path audit** — see `Non-primary path audit`

### Resolution and proof

- **Resolution proof requirement / formal resolution gate** — see `Resolution gate`
- **Proof burden for clean conclusions** — see `High-risk clean-bill proof burden`
- **Turn-end blocker questions** — see `Step 4j. Final self-audit before concluding`
- **Must challenge one more heuristic** — see `Step 4j. Final self-audit before concluding`
- **Confidence penalties** — see `Confidence penalties`
- **Aging rule for old resolved findings** — see `Aging rule for resolved findings`

### Turn-based repo discipline

- **Do not over-index on the latest fix** — see `Do not over-index on the latest fix` and `Repo-total reassessment`
- **Live-first triage gate / explicit live-first triage protocol** — see `Live-first triage for pasted findings`, `Finding triage`, and `Step 7: Re-audit workflow`
- **Audit hotspots section / hotspot ledger** — see `Hotspot ledger` and the audit file format’s `Hotspots` section
- **Branch-risk recertification cadence / re-certification turn rule** — see `Branch-risk recertification turns` and `Step 7: Re-audit workflow`
- **Change archetype tag per turn** — see `Change archetype tags per turn` and the audit file format

### Companion-surface and evidence checks

- **Expected companion changes audit / companion change expectations** — see `Companion change expectations`
- **Test adequacy check** — see `Step 3c. Run relevant verification`
- **Audit graph step** — see `Step 3a1. Build an audit graph for shared or risky surfaces`
- **Base-rate suspicion rule** — see `Base-rate suspicion rule`

## Workflow

```
1. User asks for an audit
2. Agent reads all .md files in .audits/ — they're all audit context
   - No files → Turn 1. Full audit. Name the file by audit scope.
   - Files exist → Read them all for context. Continue the relevant one as Turn N+1.
                   Re-audit the full repo AND assess the changes since the last turn.
3. User/team fixes issues
4. User asks for another audit → back to step 2
5. When satisfied, user commits the audit file alongside any fixes
```

The audit file stays uncommitted during the cycle. You commit it once at the end. If you lose the local file, you will need to reference it manually.

---

## Step 1: Initialise

### 1a. Set up `.audits/` directory

```bash
mkdir -p .audits
```

The `.audits/` directory is NOT gitignored. The audit file stays uncommitted during the cycle, committed once at the end alongside fixes.

**Cleanup convention:** Before merging to `main` / `develop`, delete `.audits/`:

```bash
rm -rf .audits/ && git add -A .audits/ && git commit -m "chore: remove audit artifacts before merge"
```

### 1b. Read existing audits and determine turn

```bash
ls .audits/*.md 2>/dev/null
```

Read all `.md` files in `.audits/`. They are all audit context. If no `.md` files exist, this is a new audit (Turn 1).

### 1c. Determine audit scope

Default to `full codebase` when the user’s intent is broad but not precisely scoped. Narrow the scope only when the user explicitly asks for a focused audit.

Common scopes:

- **Full codebase** — everything in the repo
- **Specific layer** — for example `API`, `frontend`, `infra`, `workers`
- **Specific concern** — for example `security`, `performance`, `dependency health`, `architecture`

**Turn 1 — naming the audit file:**

Name the file after the audit scope:

- Full codebase audit → `.audits/full-codebase-audit.md`
- API and backend only → `.audits/api-layer-audit.md`
- Security focused → `.audits/security-audit.md`
- Performance focused → `.audits/performance-audit.md`

```bash
AUDIT_FILE=".audits/{scope-slug}.md"
```

**Turn 2+ — always collect both views of the work:**

```bash
# Current-turn delta (what changed since the last audit turn)
git diff {prior-turn-commit}..HEAD -- . ':!.audits/' ':!.reviews/'

# Current repo state (the real audit target)
git status --short
git rev-parse --short HEAD
```

Use the change delta to focus the re-audit. Use the current repo state to judge health.

---

## Step 2: Map the codebase

### 2a. Project structure overview

Use fast tree and file-type scans first:

```bash
rg --files . -g '!node_modules' -g '!.git' -g '!.next' -g '!dist' -g '!build' -g '!.audits' -g '!.reviews' | head -500
find . -maxdepth 3 -type d -not -path './.git/*' -not -path './node_modules/*' | sort
find . -type f -not -path './.git/*' -not -path './node_modules/*' | sed 's/.*\.//' | sort | uniq -c | sort -rn | head -20
```

### 2b. Detect repo structure and tech stack

Run full detection on Turn 1 and cache it in the audit header.

**Turn 2+:** Read from the audit file header. Re-detect only if project config files changed significantly.

**Monorepo detection:**

```bash
ls pnpm-workspace.yaml lerna.json nx.json turbo.json 2>/dev/null
ls -d packages/ apps/ services/ libs/ modules/ 2>/dev/null
cat package.json 2>/dev/null | grep -E '"workspaces"'
```

**Stack detection:** Load the relevant reference files from `references/`. Multiple should apply.

- **Mobile:** react-native-expo, flutter, ios-native, android-native
- **Web:** nextjs, nuxt-vue, angular, svelte, react-web, vanilla-web
- **Backend:** python, go, rust, java-kotlin, ruby-rails, php-laravel, node-backend
- **Services:** supabase, firebase
- **Infra:** docker, ci-cd, infra
- **Cross-cutting:** typescript

### 2c. Read key files

Read the foundational files for the detected stack and for the requested scope:

```bash
cat package.json 2>/dev/null
cat tsconfig.json 2>/dev/null
cat .env.example 2>/dev/null
cat docker-compose.yml 2>/dev/null
cat Dockerfile 2>/dev/null
cat README.md 2>/dev/null
cat CONTRIBUTING.md 2>/dev/null
find . -path '*/routes/*' -o -path '*/api/*' -o -name 'router.*' | head -20
find . -path '*/migrations/*' -o -path '*/schema.*' -o -name '*.prisma' | head -20
cat .github/workflows/*.yml 2>/dev/null
```

For a full audit, prioritise:

1. entry points and configuration
2. core business logic
3. API layer and data access
4. authentication and authorisation
5. shared utilities and types
6. infrastructure and deployment

### 2d. Capture environment metadata

Turn 1 captures full environment. Turn 2+ only captures date/time/commit/IDE unless the machine clearly changed.

```bash
REVIEW_DATE=$(date +"%Y-%m-%d")
REVIEW_TIME=$(date +"%H:%M:%S %Z")
COMMIT_SHA=$(git rev-parse --short HEAD)
COMMIT_FULL=$(git rev-parse HEAD)
REMOTE_URL=$(git remote get-url origin 2>/dev/null || echo "no remote")
REPO_NAME=$(basename "$(git rev-parse --show-toplevel)")
OS_INFO=$(uname -s -r 2>/dev/null || echo "unknown")
```

### 2e. Use MCP servers for live context (if available)

If MCP servers are connected, use them in read-only mode to gather live context that local files cannot provide. Never make changes through MCP.

- **Supabase MCP:** schema, RLS policies, auth config, indexes, drift against local migrations
- **Firebase MCP:** security rules, indexes, auth providers, storage rules, Cloud Function config
- **Docs/Drive/Notion/Confluence MCP:** architecture docs, ADRs, API specs, onboarding notes
- **GitHub MCP:** issues, stale PRs, CI history, branch protection, workflow state

If an MCP server would be useful but is unavailable, note that gap in the audit file.

### 2f. Optional stack adapters

These adapters are overlays, not replacements. Use only the adapters that match the detected stack or architecture.

#### Next.js / React adapter

Bias the audit toward:

- server/client boundary issues: server components, client components, route handlers, server actions, and env exposure
- hydration, cache invalidation, optimistic UI, and duplicated state across hooks, stores, and query layers
- shared component vs screen-local fork drift
- auth/session handling across middleware, loaders, route handlers, and client refresh logic
- bundle/runtime boundary mistakes such as server-only code leaking into the client

#### Convex adapter

Bias the audit toward:

- schema, validator, handler, and client/store contract alignment
- optimistic updates vs server reconciliation and snapshot normalization
- direct mutation/query callers that bypass higher-level route contracts
- optional fields, legacy documents, and deployment compatibility across old stored data
- index/query assumptions, pagination, and fan-out reads on shared surfaces

#### Rails adapter

Bias the audit toward:

- controller params, model validations, and database constraints drifting apart
- callback/default behavior vs explicit controller/service behavior
- background jobs, mailers, and scripts that bypass the primary web request path
- transaction boundaries, migration safety, backfills, and irreversible data changes
- serializer/presenter/API contract drift and N+1 query regressions

#### Go services adapter

Bias the audit toward:

- context propagation, cancellation, and timeout handling
- error wrapping, status-code mapping, retry behavior, and partial failure semantics
- nil vs zero-value ambiguity in structs, JSON encoding, and config
- goroutine safety, shared mutable state, channel shutdown, and leak-prone concurrency
- compatibility across protobuf/OpenAPI contracts, consumers, and background workers

#### Mobile adapter

Bias the audit toward:

- platform parity across iOS and Android or native/web surfaces
- app lifecycle, offline caching, background sync, and stale local state
- permissions, deep links, push notifications, and navigation-state recovery
- native bridge/module assumptions, runtime config, and upgrade compatibility
- optimistic UI, persisted local state, and reconciliation after reconnect or relaunch

---

## Step 3: Gather codebase context (repo-wide awareness)

### 3a. Maintain a repo-total audit map

At the start of every turn, build or refresh a repo-total audit map:

- files changed since the last turn
- files already in cumulative audit scope from prior turns
- files directly referenced by prior open findings
- files directly referenced by prior resolved findings when the same bug family could reappear elsewhere
- sibling surfaces required by the bug-family matrix for any serious finding

Audit the current code across that map, not just the newest files. If a file was central to a prior finding or to a repeated bug family, re-read its current version even if this turn did not modify it.

### 3a1. Build an audit graph for shared or risky surfaces

When the repo state touches a shared contract, shared abstraction, or repeated workflow, sketch a quick audit graph:

- producers
- validators
- transformers
- persistors
- consumers
- display/read-side helpers
- tests

Use it to guide sibling closure and companion-change checks.

### 3b. Read deeply where risk is concentrated

For each high-risk area in scope:

- read the full file, not just one excerpt
- trace direct dependencies used by the risky code
- trace direct callers, consumers, renderers, or downstream handlers affected by the issue
- expand changed interfaces: exported functions, public types, components, hooks, routes, schemas, events, config surfaces, and shared utilities must have their consumers reviewed
- inspect shared types, schemas, validation, config, permissions, and tests that define or constrain the behavior
- follow the flow until the impact is understood end to end
- review deletions, moved code, and removed tests/guards with the same scrutiny as additions

### 3c. Run relevant verification

Static auditing is necessary but not sufficient. When the repo has executable checks, run them.

- start with the most relevant targeted checks for the risky area
- run broader safety nets when relevant to the stack and blast radius: typecheck, lint, build, contract checks, migration verification, or e2e tests
- on re-audit after fixes, rerun the checks that should prove the fix and catch regressions introduced by the remediation
- if a risky area has no meaningful automated coverage, call that out as a finding or observation when appropriate
- if you cannot run a useful check, say exactly why
- review the tests themselves when they changed
- when lockfiles, generated clients, migrations, snapshots, or compiled artifacts changed, verify they are consistent with the source change that produced them

Test storage rules:

- If a test should survive the audit because it proves a real bug fix or guards against regression, add it to the normal project test suite near the affected code. Treat it as product code, not audit metadata.
- Do **not** store permanent regression tests inside `.audits/`. The audit folder is for turn history and audit evidence, not the repo's lasting test suite.
- Turn-specific verification belongs in the current turn's `Validation`, `Coverage note`, and `Residual risk / unknowns` sections.
- If you need a one-off repro command or temporary scratch script during the audit, reference it in the audit turn and delete or ignore it before final cleanup unless the user explicitly wants it preserved.

Required verification matrix:

| Risk | Minimum verification expectation |
|------|---------------------------------|
| **Low** | Targeted tests or reproduction steps for the audited risky path, plus the most relevant fast safety net (`typecheck`, `lint`, or equivalent) |
| **Medium** | Targeted tests, core safety nets for the stack, and at least one broader check such as build/package tests/integration coverage |
| **High** | Targeted tests, broader package or integration coverage, core safety nets, build/contract checks, and explicit compatibility + release-safety review |
| **Critical** | Everything from High, plus the strongest available verification for failure modes, rollback constraints, migrations, and operational readiness |

If the expected verification for the assigned risk score cannot be run, say exactly what is missing and lower confidence.

Test adequacy checks:

- Does a test cover the actual failure mode, or only the happy path?
- Does any test cover a sibling path, not just the edited site?
- Does the test prove the bug family is closed, or only that one code path now passes?
- Are mocks hiding the integration edge where the bug actually lived?

Passing tests are strong evidence only when they exercise the real failure mode or a convincing proxy for it.

### 3d. Worked examples

Use these as style guides. They are intentionally short, but they show the level of specificity expected in a strong audit turn entry.

#### Example A — Strong Turn 1 on a contract-heavy repo audit

```markdown
## Turn 1 — 2026-04-20 14:05 BST

**Summary:** Audited schedule-field handling across route schemas, shared validators, optimistic store paths, and backend handlers. The repo has one major correctness family: calendar-date logic is split between date-only helpers and timestamp math, which creates inconsistent behavior across create, update, and timeline movement paths.

**Health rating:** Needs attention
**Risk score:** high — contract and persisted-state logic spans multiple entrypoints and shared helpers
**Change archetypes:** contract, optimistic-state, parallel-entity — project and work-item schedule logic drift in parallel
**Confidence:** medium — core paths were traced, but one sibling path remains under-verified
**Finding triage:** external findings classified as live (2), already fixed (1), stale (1)
**Repo totality:** rechecked schedule logic across the full current tree, not just the latest reported file
**Sibling closure:** checked create, patch, and direct-mutation paths; one direct backend path remains divergent
```

#### Example B — Strong Turn 3 re-audit after fixes

```markdown
## Turn 3 — 2026-04-20 18:20 BST

**Summary:** Re-audited the repo after schedule-contract fixes. The main route-path bug family is closed, but the challenger pass still found one same-family gap in a direct backend mutation path.

**Outcome:** partial audit
**Risk score:** high — the same contract family is still active, so the repo is not yet systemically clean
**Change archetypes:** contract, release-safety — this turn is mostly revalidation of repo-total state
**Confidence:** medium — strong proof on fixed paths, incomplete proof on one bypass path
**Repo totality:** reassessed the current repo state vs prior turns and revalidated previously resolved schedule findings against adjacent file changes
**Sibling closure:** reran the bug-family matrix across route, handler, direct caller, and optimistic client surfaces
```

#### Example C — Strong clean conclusion on a lower-risk audit turn

```markdown
## Turn 5 — 2026-04-21 09:10 BST

**Summary:** Re-audited the shared list-row rendering cleanup and its alternate consumers. The branch-local UI issue is closed, the shared component and copied board surface stay aligned, and targeted UI verification is sufficient for this risk level.

**Outcome:** clean in audited scope
**Risk score:** medium — shared UI surface, but localized blast radius and no contract mutation
**Change archetypes:** shared-ui — layout and display-property rendering only
**Confidence:** high — shared/local copies were checked and the relevant rendering tests pass
**Repo totality:** rechecked the current repo versions of both list and board renderers before clearing
**Sibling closure:** verified shared component, local fork, and alternate render surface for the same display-property behavior
```

---

## Step 4: Audit categories

Assess all of the following, adapting depth based on the detected stack and the actual repo risks.

Coverage gate before concluding the audit turn:

- confirm the requested scope was examined
- confirm the current repo state, not just the latest fix delta, was reassessed against prior findings and current scope
- confirm repo-totality proof names concrete non-delta rechecks, prior finding rechecks, and adjacent/resolved area revalidation rather than a generic claim
- confirm the remediation impact surface was audited: upstream callers, downstream consumers, adjacent workflows, dependencies, contracts, and side effects touched by the fix
- confirm remediation radius was classified into `must fix now`, `should fix now if cheap/safe`, and `defer` for meaningful findings
- confirm any adjacent weakness judged `must fix now` was fixed, carried as a live finding, or explicitly blocked with reason
- confirm the turn’s change archetype tags were chosen and the matching checklists were applied
- confirm expected companion changes were audited for the main issues in scope
- confirm high-impact touchpoints were traced far enough to understand the blast radius
- confirm the audit covers both what changed and what the changed code touches
- confirm relevant tests, checks, or executable verification were run when available, or explicitly note why they were not
- confirm negative-space review was done: what should have changed but did not?
- confirm deleted safeguards, changed tests, and repeated bug patterns were checked where relevant
- confirm any serious bug class received sibling closure across lifecycle, layer, entity, consumer, and caller surfaces, or explicitly mark closure as incomplete
- confirm any required non-primary path audit was done
- confirm the hotspot ledger was reviewed and updated if recurring families changed
- confirm the expected verification matrix for the assigned risk score was satisfied or explicitly blocked
- confirm a prevention artifact was added or consciously ruled out for meaningful fixes
- if any part of the scope or impact path was not audited, mark the turn partial and say exactly what remains

### 4a. Architecture and structure (HIGH)

- Is the project structure clear and consistent?
- Separation of concerns — is business logic mixed into UI components or route handlers?
- Layering — is there a clear data flow or is everything tangled?
- Dependency direction — do lower layers depend on higher layers?
- Shared code organisation — are utilities, types, and constants well-organised or scattered?
- Monorepo health — are package boundaries clean and cross-package imports appropriate?

### 4b. Bugs and correctness (CRITICAL)

- Null/undefined handling patterns
- Error handling strategy
- Race conditions in async code, state management, and concurrent access
- Boundary conditions, empty states, and missing-data edge cases
- Type safety and places where the type system is bypassed

### 4c. Security (CRITICAL)

- Authentication implementation
- Authorisation and policy enforcement
- Input validation at all entry points
- Secrets management
- Dependency vulnerabilities
- CORS, CSP, and security headers
- Data exposure and accidental leakage of internals or PII

### 4d. Performance (IMPORTANT)

- Database/query behavior: N+1s, missing indexes, unbounded queries
- Bundle size or binary size
- Rendering or hot-path computation
- Caching strategy
- Asset optimisation
- API or worker bottlenecks

### 4e. Code quality and maintainability (IMPORTANT)

- Consistency of naming, file structure, and patterns
- Duplication and copy-paste logic
- Complexity and oversized functions/files/modules
- Dead code and unreachable branches
- Documentation for critical business logic or public APIs
- Test quality, not just test count

### 4f. Dependencies and tech debt (IMPORTANT)

- Outdated or abandoned dependencies
- Dependency bloat
- Migration debt
- TODO / FIXME / HACK clusters
- Legacy patterns that block improvement

### 4g. DevOps and operational readiness (MODERATE)

- CI/CD coverage
- Deployment reproducibility
- Logging and observability
- Error tracking
- Environment management
- Migration/backfill rollback safety

### 4h. Stack-specific concerns (IMPORTANT)

Load the relevant reference files and apply the matching stack adapters.

### 4i. Design decisions and architecture flags (IMPORTANT)

Not everything questionable is a bug. Flag these as design questions when needed:

- denormalised data
- feature flags or gradual rollout patterns
- unconventional patterns with comments explaining why
- performance optimisations that sacrifice readability

### 4j. Final self-audit before concluding

#### Turn-end blocker questions

- What is the most likely serious issue this audit could still be missing?
- Which assumption matters most, and what would break if it is false?
- Which high-risk path has the weakest direct evidence?
- Which sibling surface or parallel implementation is most likely to still carry the same bug family?
- Which part of the repo has not been revalidated recently enough to justify a clean conclusion?
- What same-family bug is most likely still elsewhere?
- What layer was least directly verified?
- What entity twin or subsystem twin was not checked deeply enough?
- What non-primary caller or bypass path was least directly evidenced?
- What changed test, removed guard, or untouched dependency did you trust, and why?
- If this shipped and caused a major incident tomorrow, what path would you investigate first?

#### Must challenge one more

- If there is still one live serious bug in this repo, where is it most likely?
- Which fix or architectural cleanup still looks too local?

If those answers expose weak evidence, lower confidence, keep the audit partial, or add a follow-up check.

---

## Step 5: Root cause analysis for each finding

Every finding needs depth. Provide all of the following:

### Finding ID and classification

Every finding is one of four types:

| Prefix | Type | Definition |
|--------|------|------------|
| `B` | **Bug** | Something is broken or will break |
| `S` | **Security** | A vulnerability, exposure, or access-control gap |
| `F` | **Flag** | Something looks wrong but may be intentional |
| `O` | **Observation** | Not broken, not suspicious, but worth noting |

Format: `{prefix}{turn}-{sequence}` — for example `B1-01`, `S1-02`, `O2-01`.

These IDs persist across turns. `B1-01` is always `B1-01`, even when resolved in Turn 3.

### Severity

- **Critical** — must fix
- **High** — should fix soon
- **Medium** — should fix
- **Low** — nice to fix

### Root cause

Explain why the issue exists:

- conscious shortcut?
- inherited legacy pattern?
- misunderstanding of framework/library?
- gap in conventions or review process?

### Codebase implication

What is the blast radius?

- which features or user flows does this affect?
- how does this interact with other parts of the system?
- which upstream callers, downstream consumers, or dependent systems does this change put at risk?
- what happens if this is not fixed in 3 / 6 / 12 months?
- which adjacent workflows or shared dependencies now need revalidation because of the fix shape?
- is this blocking other improvements?

### Evidence

Support the finding with concrete evidence:

- exact file and line references
- specific code path or data flow
- test, typecheck, lint, build, runtime, profiling, or operational signal if available
- why this is a real repo risk, not just a theoretical preference
- search results or related usage sites when the issue may repeat elsewhere

### Solution options

- **Quick fix:** minimal change, addresses the symptom
- **Proper fix:** right approach, may require more work
- **Strategic fix:** broader refactor or migration

For each option, note any touchpoints that also need validation so the team does not apply a local fix that breaks adjacent behavior. Include secondary checks when relevant: affected consumers, schema contracts, state transitions, permissions, retries, caching, migration safety, and test coverage.

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
State what will make this class of problem less likely to recur:

- regression test
- stronger validation, typing, or schema enforcement
- invariant assertion or runtime guard
- lint/static rule
- observability improvement
- targeted helper extraction or deletion of risky duplication

If none is appropriate, say why.

### Investigation prompt

What should the team check before deciding on a fix.

---

## Step 6: Write (or update) the audit file

All output goes into a single file: `.audits/{scope-slug}.md`

**Turn 1:** Create the file with the header and first turn.
**Turn 2+:** Append the new turn. Update header counts and scope. Mark prior findings as resolved, carried, or accepted.

### File format

```markdown
# Audit: {scope description}

## Project context (captured on Turn 1)

| Field | Value |
|-------|-------|
| **Repository** | {repo-name} |
| **Remote** | {remote-url} |
| **Branch** | {branch-name} |
| **Repo type** | {single repo / monorepo (type)} |
| **Stack** | {detected stack} |
| **Packages affected** | {monorepo only, or "n/a"} |
| **OS** | {OS info} |
| **Package manager** | {pnpm/yarn/npm + version} |
| **Node** | {version, if relevant} |
| **Codebase size** | {approximate file count / line count by language} |

## Audit scope (cumulative — updated each turn)

Areas and files covered by this audit:
- {area or path}

## Hotspots (cumulative — updated as recurring risk families emerge)

- `contract drift`
- `shared/local duplication`
- `optimistic vs persisted drift`

## Audit status (updated every turn)

| Field | Value |
|-------|-------|
| **Audit started** | {date} {time} |
| **Last audited** | {date} {time} |
| **Total turns** | {N} |
| **Open findings** | {count} |
| **Resolved findings** | {count} |
| **Accepted findings** | {count} |

## Findings summary (updated every turn)

| Severity | Open | Resolved | Accepted |
|----------|------|----------|----------|
| Critical | X | X | X |
| High | X | X | X |
| Medium | X | X | X |
| Low | X | X | X |

---

## Turn 2 — {date} {time}

| Field | Value |
|-------|-------|
| **Commit** | {sha} |
| **IDE / Agent** | {IDE} |

**Summary:** {2-3 sentence overview}
**Outcome:** {clean in audited scope | partial audit | blocked by open findings | blocked by missing verification}
**Health rating:** {Healthy | Needs attention | Significant issues | Critical}
**Risk score:** {low | medium | high | critical} — {why}
**Change archetypes:** {tags} — {why}
**Confidence:** {high | medium | low} — {why}
**Coverage note:** {key files, systems, tests, and searches reviewed}
**Finding triage:** {live | already fixed | accepted | stale | needs confirmation}
**Repo totality:** {what was rechecked across the whole current repo beyond the latest diff}
**Sibling closure:** {which lifecycle/layer/entity/consumer/caller siblings were checked}
**Remediation impact surface:** {which adjacent callers, consumers, dependencies, workflows, contracts, and side-effect surfaces were revalidated because of the fix}
**Residual risk / unknowns:** {what could not be fully verified}

| Status | Count |
|--------|-------|
| New findings | X |
| Resolved from prior turns | Y |
| Carried | Z |
| Accepted | W |

### Diff impact assessment

{How the fixes changed the repo state, whether they addressed root causes, and whether they introduced new issues}

### Validation

- `{command}` — passed
- `{command}` — failed: {short failure summary}
- `{command}` — not run: {reason}

### Repo-totality proof

- **Non-delta files/systems re-read:** {What outside the latest edit set was rechecked}
- **Prior open findings rechecked:** {Which open items were revalidated against the current tree}
- **Prior resolved/adjacent areas revalidated:** {What previously closed or nearby areas were revisited and why}
- **Hotspots or sibling paths revisited:** {Which recurring families or alternate paths were rechecked}
- **Dependency/adjacent surfaces revalidated:** {Which callers, consumers, dependencies, workflows, or contracts were rechecked because of the remediation impact}
- **Why this is enough:** {Why the audit has credible repo-wide coverage for this turn}

### Challenger pass

- `{done | not needed | blocked}` — {what it focused on and what it changed}

### Resolved from prior turns

#### B1-01 ~~[BUG] Critical~~ → RESOLVED — {short description}
**How it was fixed:** {description}
**Adjacent work handled:** {required companion or adjacent fixes that were made, or `none`}
**Follow-on findings opened:** {IDs of new findings discovered during remediation, or `none`}
**Verified:** {confirmation the fix addresses the root cause}
**Prevention artifact:** {test, guardrail, validation, telemetry, or `none` with reason}

### Carried from prior turns

#### O1-02 [OBSERVATION] High — STILL OPEN — {short description}
**Status:** {unchanged | partially addressed}
**Notes:** {updates}

### New findings

#### O2-01 [OBSERVATION] Medium — `{file}:{line}` — {short description}
**Discovery source:** {primary audit | remediation pass for B1-01 | sibling closure for B1-01 | dependency revalidation for B1-01}
**Related finding(s):** {B1-01, if this was discovered while fixing or rechecking another finding; otherwise `none`}
**What’s happening:** {…}
**Root cause:** {…}
**Codebase implication:** {…}
**Solution options:**
1. **Quick fix:** {…}
2. **Proper fix:** {…}
3. **Strategic fix:** {…}
**Remediation radius:**
- **Must fix now:** {required adjacent or companion changes}
- **Should fix now if cheap/safe:** {bounded improvements worth taking if low risk}
- **Defer:** {larger or lower-signal work that should not expand this turn}
**Prevention artifact:** {test, validation, invariant, telemetry, helper extraction, or `none` with reason}
**Investigate:** {…}

### Recommendations

1. **Fix first:** {critical and high-severity items}
2. **Then address:** {next priority}
3. **Patterns noticed:** {recurring themes}
4. **Suggested approach:** {order of operations and dependencies}
5. **Progress since last turn:** {is the repo getting healthier?}
6. **Defer on purpose:** {adjacent improvements that were identified but should not be rolled into this turn}

---

## Turn 1 — {date} {time}

| Field | Value |
|-------|-------|
| **Commit** | {sha} |
| **IDE / Agent** | {IDE} |

**Summary:** {overall assessment of the codebase}
**Outcome:** {partial audit | blocked by open findings | clean in audited scope}
**Health rating:** {Healthy | Needs attention | Significant issues | Critical}
**Risk score:** {low | medium | high | critical} — {why}
**Change archetypes:** {tags} — {why}
**Confidence:** {high | medium | low} — {why}
**Coverage note:** {key files, systems, tests, and searches reviewed}
**Finding triage:** {externally supplied findings classified as live | already fixed | accepted | stale | needs confirmation}
**Repo totality:** {what was checked across the current repo state}
**Sibling closure:** {which sibling surfaces were checked}
**Remediation impact surface:** {which adjacent callers, consumers, dependencies, workflows, contracts, and side-effect surfaces were checked}
**Residual risk / unknowns:** {what could not be fully verified}

### Architecture overview

{brief description of the repo’s architecture, data flow, and key patterns}

### Validation

- `{command}` — passed
- `{command}` — failed: {short failure summary}
- `{command}` — not run: {reason}

### Repo-totality proof

- **Non-delta files/systems re-read:** {What outside the primary files or initial scope was reviewed}
- **Prior open findings rechecked:** {Turn 1 may say `n/a` if none existed before the audit}
- **Prior resolved/adjacent areas revalidated:** {Turn 1 may say `n/a` if no prior state exists}
- **Hotspots or sibling paths revisited:** {Which recurring families or alternate paths were checked}
- **Dependency/adjacent surfaces revalidated:** {Which callers, consumers, dependencies, workflows, or contracts were checked because of the remediation impact}
- **Why this is enough:** {Why the Turn 1 repo-wide audit coverage is credible}

### Challenger pass

- `{done | not needed | blocked}` — {what it focused on and what it changed}

### Findings by category

{group Turn 1 findings by category for readability}

### What’s working well

{acknowledge the good parts}

### Recommendations

1. **Fix first:** {critical and high-severity items}
2. **Then address:** {medium-severity items}
3. **Patterns noticed:** {recurring themes}
4. **Suggested approach:** {order of operations and dependencies}
5. **Quick wins:** {low-effort, high-value changes}
6. **Defer on purpose:** {adjacent improvements that should be tracked but not folded into this turn}
```

### Key rules for the file format

- **Newest turn at the top** after the header.
- **Project context is written once on Turn 1.**
- **Audit status, findings summary, and hotspot ledger are updated every turn.**
- **Turn 1 findings are grouped by category.** Turn 2+ findings are grouped by status.
- **Every finding keeps its original typed ID forever.**
- **Every turn ends with recommendations.**
- **Turn 2+ records finding triage, repo totality, sibling closure, and residual risk explicitly.**
- **Turn 2+ proves repo totality concretely.** Generic claims like "rechecked the repo" are not enough; the turn must name non-delta rechecks, prior finding rechecks, adjacent/resolved area revalidation, and hotspot revisits.
- **Solutioning must stay family-aware.** If multiple related surfaces are being fixed or revalidated, the audit should say whether the remediation pattern is shared, intentionally different, or still unresolved.
- **Every turn states remediation impact explicitly.** Family closure is not enough; the audit should say which adjacent callers, consumers, dependencies, workflows, contracts, or side effects were revalidated because of the fix.
- **Every meaningful finding classifies remediation radius explicitly.** Distinguish what must land now from what is merely nice to have.
- **Adjacent fixes need evidence, not aesthetics.** Do not expand into refactor or cleanup territory unless the audit can explain the concrete risk reduced by doing so now.
- **Meaningful fixes should leave a prevention artifact.** Prefer to reduce recurrence risk with a test, guardrail, stronger validation, or another bounded preventive control. If none is used, say why.
- **Remediation-discovered issues must be logged as first-class findings.** If a new bug is discovered while fixing or revalidating another finding, create a new finding ID, record the discovery source, and link it back to the triggering finding instead of silently folding it into the original.

---

## Step 7: Re-audit workflow (Turn 2+)

When the user asks for a follow-up audit after making fixes:

1. **Read all `.md` files in `.audits/`** — they are all context. Continue the relevant one.
2. **Get both the current-turn delta and the current repo state**. The delta shows what changed this pass; the repo state is the actual audit target.
3. **Update the cumulative scope and hotspot ledger** — add any new files or recurring risk families.
4. **Choose the turn’s change archetype tags** based on the current-turn delta plus current repo state.
5. **Triage prior findings and any externally supplied audit comments against the current tree** — classify each as live, already fixed, accepted, stale, needs confirmation, or superseded before planning remediation work.
6. **Re-read codebase context** for all files in the current delta, all files referenced by prior open findings, prior resolved findings with similar bug families, required sibling surfaces from the bug-family matrix, any shared abstractions or family members implicated by the remediation options, and the adjacent callers/consumers/dependencies in the remediation impact surface.
7. **For each prior open finding, check the current code:**
   - **Resolved**
   - **Partially addressed**
   - **Still open**
   - **Regression**
   - **Accepted**
8. **Before marking a finding resolved, apply the resolution gate** — rerun sibling closure, confirm non-primary paths and expected companion changes, assess the remediation impact surface across adjacent code, classify the remediation radius (`must fix now`, `should fix now if cheap/safe`, `defer`), and verify that targeted proof exists.
9. **Revalidate aged resolved findings when needed** — if nearby files, adjacent contracts, or the same bug family changed materially after a finding was resolved, recheck it.
10. **Run relevant verification again** — rerun targeted tests/checks for the fixed area, at least one meaningful non-primary sibling path when appropriate, broader safety nets required by the blast radius, and the specific checks needed to validate any `must fix now` adjacent work.
11. **Audit both the latest changes and the repo-total current state for new findings** — fixes can introduce new bugs, untouched areas can still block a healthy conclusion, and a locally sensible remediation can still be wrong if it conflicts with the broader bug family.
12. **If remediation or revalidation reveals a new adjacent issue, document it immediately as a new finding** — assign a new ID, record the discovery source (for example `remediation pass for B1-01`), link it to the triggering finding, and update the resolved finding note if relevant so the audit history stays traceable.
13. **On long-running audits, trigger a branch-risk recertification turn when appropriate** — every 5 turns or after a major fix cluster.
14. **Append the new turn** and update header counts, summaries, and hotspots. Record concrete repo-totality proof, remediation radius decisions, any deferred adjacent improvements, remediation-discovered findings, and the prevention artifact used or consciously skipped.
15. **If all findings are resolved and no new issues remain in scope:** only then write a turn confirming the audited scope is clean.
16. **If investigation is incomplete or repo-totality proof is thin/generic:** do not give a clean conclusion. State that the audit is partial and say what still needs checking, including unreviewed areas, impact paths, adjacent dependency surfaces, prevention gaps, or remediation-family coherence questions.

---

## Escaped finding feedback loop

If the team later reports that the audit missed a bug, treat that as a process failure to learn from, not just a new isolated finding.

1. Reconstruct the escaped issue precisely.
2. Identify the missed signal:
   - evidence in the code but overlooked?
   - connected code not traced far enough?
   - wrong test/check run?
   - passing tests created false confidence?
   - repeated pattern elsewhere?
3. Add or recommend a regression check that would catch this class next time.
4. Search the codebase for sibling occurrences of the same pattern.
5. Update the active audit with the escaped finding and explicitly note the audit gap.

## Aging rule for resolved findings

On long-running audits, a finding resolved 10+ turns ago may need revalidation if adjacent systems kept changing.

Recheck an old resolved finding when:

- nearby files changed materially after it was resolved
- adjacent contracts changed
- the same bug family reappeared elsewhere
- the original verification evidence is now stale or weaker than the current risk

## Historical evaluation

Use historical context to sharpen later turns, not to replace current-tree evidence.

- Compare the current turn against the audit history to identify drift, churn, partial reversions, and recurring bug families.
- If a subsystem has changed materially across multiple turns, bias the re-audit toward proving the whole subsystem is coherent now, not just that the latest patch is locally sensible.
- Use prior turns to inform hotspot selection, revalidation targets, and confidence penalties.
- Never let a previously strong turn substitute for a current-tree reassessment when adjacent code kept moving.

## File structure

```text
.audits/
├── full-codebase-audit.md
├── security-audit.md
├── api-layer-audit.md
```

One file per audit. All turns inline. No subdirectories, no JSON sidecars. The markdown file is the single source of truth.

`.audits/` stores turn-based audit state, not executable product tests. Keep durable regression tests in the normal test directories of the codebase. Keep temporary audit-only commands or repro notes in the audit markdown unless there is a strong reason to use a separate scratch file.

## Edge cases

- **Very large codebases:** Prioritise by risk. Be explicit about what was and wasn’t audited.
- **Monorepos:** Audit each package in scope and flag cross-package concerns.
- **Focused audits:** Only audit the requested area, but still read surrounding context for full-stack awareness.
- **No prior audit exists but user says "re-audit":** Treat as Turn 1.
- **User wants to accept a finding:** Mark as accepted with reasoning. Don’t revisit.
- **Duplicate local files:** Treat Finder-style ` 2`, ` 3`, or accidental copy files as hygiene risks. Confirm they are duplicates, then delete or flag them.

## Tone

Be direct, specific, and constructive. Reference exact files and lines. Call bugs bugs. Acknowledge good work.

Frame findings as opportunities to improve a real system, not as indictments. The goal is to give the team a clear, prioritised action plan they can actually execute on.

---
name: architecture-standards
description: Use this skill when designing target architecture, diagnosing messy current-state architecture, scaffolding a new application/service/feature, refactoring toward cleaner boundaries, reviewing code for architectural quality, or making implementation decisions that affect ownership, layering, contracts, persistence, async workflows, auth/tenancy, shared abstractions, operability, or long-term maintainability. The skill guides code design and remediation planning with practical, enforceable boundaries rather than documentation ceremony.
---

# Architecture Standards

Use this skill to design and build code with clear ownership, proportionate architecture, enforceable boundaries, and practical tradeoffs. It is not a documentation skill. Prefer architecture decisions that are visible in module placement, public interfaces, types, schemas, tests, runtime guards, dependency boundaries, and operational checks.

## Core Workflow

When this skill is triggered:

1. Frame the work as a business capability, user/system journey, and failure consequence.
2. Identify the current repo architecture and preserve it unless there is a clear reason to change it.
3. Decide the owner of the invariant: presentation, application, domain, data, infrastructure, API/integration, or operations.
4. Choose the lightest architecture shape that keeps the system correct, operable, and evolvable.
5. Implement through the owning boundary, not the closest file.
6. Encode the decision in code-level enforcement where practical.
7. For analyzer-driven or broad refactor work, define the structural prevention rule before editing: what shape should stop recurring, which owner will hold it, and which fitness function will catch relapse.
8. State tradeoffs only when material or non-obvious.

## Progressive Reference Loading

Load only the references needed for the task:

- `references/decision-framework.md`: use for meaningful design choices, proportionality, ownership, and tradeoff reasoning.
- `references/target-state-design.md`: use when defining or evaluating the desired architecture for an existing or new system, especially after an audit reveals the current target design is not holding.
- `references/architecture-shapes.md`: use when choosing modular monolith vs services, sync vs async, CRUD vs domain model, CQRS/read models, API style, persistence, jobs, or abstraction level.
- `references/layer-standards.md`: use when placing code, defining boundaries, or checking dependency direction across presentation/application/domain/data/infrastructure/API layers.
- `references/implementation-recipes.md`: use when building or changing a feature, validation rule, API, persistence model, shared component, background job, cache/fallback, or integration.
- `references/enforcement-patterns.md`: use when an architecture rule should be protected by tests, types, schemas, runtime guards, lint/static checks, dependency rules, or operational checks.
- `references/cross-cutting-standards.md`: use for security, performance, reliability, observability, testability, maintainability, and cost.
- `references/smell-triage.md`: use when deciding whether architecture debt is `must fix now`, `should fix if cheap/safe`, or `defer`.
- `references/current-state-diagnosis.md`: use when an existing repo is structurally messy, architecture standards have not been effective, or an audit reveals widespread duplication, complexity, unclear ownership, weak boundaries, or failed fitness functions.
- `references/refactor-design.md`: use when reports or code review reveal duplication, health hotspots, large modules, module-budget pressure, or broad refactor work that needs design synthesis.
- `references/static-analyzer-policy.md`: use when analyzer config, audit findings, duplication reports, refactor targets, baselines, suppressions, boundaries, health thresholds, feature flags, or coverage gaps affect architecture policy or refactoring choices.
- `fallow` skill reference `quality-benchmarks.md`: use when Fallow evidence shows a prior review/audit/architecture pass missed structural debt or when calibrating negative all-clear behavior.
- `references/architecture-scorecard.md`: use for whole-repo architecture audits or governance reviews.
- `references/review-checklists.md`: use before finalizing architecture reviews or implementation reviews.
- `scripts/architecture-preflight.sh`: run from repo root for broad architecture reviews or fragmented repo context.

## Operating Modes

### Build Mode

Use for normal feature, bugfix, refactor, and scaffolding prompts.

The agent should:

- make the smallest change that preserves architecture and keeps an upgrade path
- put code in the capability/layer that owns the rule
- reuse existing flows instead of creating bypasses
- avoid broad refactors unless the current task would otherwise leave a live architecture risk
- load `implementation-recipes.md` for the relevant code shape
- load `enforcement-patterns.md` when the invariant is likely to be violated again
- explain architecture only briefly in the final answer when the decision is material

### Governance / Audit Mode

Use for whole-repo architecture decisions, repo audits, platform changes, system design, or cross-team/system work.

The agent should:

- evaluate decision quality, ownership, enforcement, and drift
- diagnose current-state architecture before designing the target state
- evaluate whether the target state is specific and enforceable enough to correct current-state failure modes
- treat duplication and refactor reports as architecture evidence: where rules are scattered, ownership is unclear, modules mix responsibilities, or transition debt needs a closure plan
- separate configured gates, production inventories, full inventories, baselines, and accepted debt before declaring the target state credible
- synthesize repeated findings into missing design concepts before recommending mechanical cleanup
- identify owners for capabilities, data, contracts, and operational workflows
- use `architecture-scorecard.md` for repo-level health
- use `smell-triage.md` to separate must-fix risks from refactor preferences
- recommend code-level enforcement before documentation
- call out exceptions, cleanup paths, and missing fitness functions

### Current-State Diagnosis Mode

Use when the repo is already messy or an audit shows the architecture standards are not functioning effectively.

The agent should:

- map what the code actually does, not what docs say it should do
- identify structural failure modes: unclear ownership, scattered policy, boundary bypasses, helper dumping grounds, mixed responsibilities, unowned contracts, weak tests, and stale exceptions
- use duplication, health, churn, module size, and audit-transition evidence as design input
- use Fallow/static-analysis evidence as both path evidence and shape evidence: trace runtime/user journeys, then cluster clone groups, health hotspots, module pressure, and helper sprawl to infer missing design concepts
- produce a transition architecture: immediate containment, sequence of safe refactors, enforcement to prevent relapse, and explicit accepted debt
- avoid declaring a target state successful until the current state has fitness functions that prove movement toward it

### Target-State Design Mode

Use when defining what the architecture should become or when an audit shows the previous target state was too weak.

The agent should:

- derive target-state requirements from current-state evidence, product journeys, failure consequences, and audit findings
- define capability ownership, dependency direction, data ownership, API/contracts, async/reliability, operational ownership, and test/enforcement gates
- specify what must stop happening: duplicated policy, boundary bypasses, generic helper dumping, unowned contracts, permanent allowlists, or deployment-only assumptions
- include migration/transition slices so the target state can be reached from the current code without unsafe rewrites
- make the target state falsifiable with fitness functions: tests, static rules, CI gates, module budgets, smoke checks, or deployment evidence
- treat a budgeted baseline, suppression, allowlist, or production-only clean result as transition state until it has owner, cap, reason, evidence command/date, and revisit trigger

## Code Design Gate

Before building code that introduces or changes a module, shared helper, state owner, schema, API route, data model, background job, integration, cache/fallback, or cross-feature behavior, answer through the implementation:

- **Where should this code live?** Put it in the owning capability/layer, not where the request first appears.
- **Who owns the invariant?** Enforce business rules, permissions, tenancy, generated IDs, and persistence constraints at the authoritative layer.
- **What is the public boundary?** Expose the narrowest command, query, component, hook, schema, adapter, or event callers need.
- **Is this export a real runtime/API boundary?** Do not export internals from production modules only for tests or coverage. Move stable testable primitives into owner-local modules that production imports, or test through the existing public behavior.
- **Will this grow into a monolith?** If a component/function is accumulating rendering, state transitions, effects, data shaping, persistence, and adapter logic, split by owner now: state/policy, view model, render primitives, effects/adapters, and route/data boundary.
- **What must not depend on what?** Keep inner policy free of framework, transport, vendor, and presentation dependencies.
- **What path bypasses this?** Check alternate UI surfaces, API routes, jobs, scripts, imports, direct mutations, and fallback/read-model paths.
- **What public contract is serialized?** Distinguish internal option names from route/API/query/storage keys, and assert the public serialized contract in tests for auth, redirects, webhooks, routes, jobs, and persisted data.
- **How is this enforced?** Prefer tests, types, schemas, runtime guards, dependency rules, or CI/lint checks over comments.
- **What is the failure mode?** Design retries, idempotency, rollback, user feedback, observability, and partial-failure behavior where relevant.
- **What gets deleted later?** If this is a shim, fallback, feature flag, compatibility path, or exception, make the cleanup path visible.

If the answer is "just add it to the closest component/handler/helper," stop and check whether that scatters policy, duplicates a rule, or bypasses the real owner.

## Static-Fitness Architecture Rules

Use these rules when Fallow, static analysis, PR review, or broad refactoring shows duplication, health findings, dead-code noise, or complex modules:

- **Design for zero new clone debt.** Repeated code should either stay intentionally local because the variants are meaningful, or move into the owner of the repeated invariant. Do not introduce a generic helper bucket to satisfy a metric.
- **Design for low branch pressure.** New branch-bearing code should have one reason to change. Split large UI surfaces into feature-local state helpers, view-model helpers, render-only components, and effect/adaptor modules before they become hard-to-test components.
- **Keep broad remediation reviewable.** Prefer capability-owned slices that can be reviewed and verified independently. If a large integration branch is unavoidable, maintain a batch ledger by owner, changed public contracts, verification evidence, and PR-review state so subtle bugs are not hidden by diff size.
- **Keep testability out of public production APIs.** Coverage-first work must not create exports that no production caller uses. Finalize broad refactors with a production dead-code sweep as well as full dead-code.
- **Refresh evidence before interpreting health.** Coverage-aware health depends on the current coverage artifact. Run or refresh coverage before treating health findings as current.
- **Treat score gaps differently from findings.** A health score below `100` with `0` findings is aggregate architecture pressure, not a list of live remediation targets. Use it to guide future design, not to justify mechanical splitting.
- **Protect serialized contracts at the edge.** Route/query/form/storage names are public contracts even when callers use nicer internal option names. Tests should assert the serialized key/value shape on failure and retry branches, not only helper return types.
- **Finish refactors with mode-separated proof.** For Fallow-backed work, check changed-file audit if available, production configured gates, full inventories, duplication, dead-code, and CI parity separately. Never collapse them into a single "clean" claim.
- **Browser-smoke broad presentation changes.** Tests, typecheck, and build are not enough when shared UI primitives, screen composition, navigation, empty states, or layout were moved. Verify representative screens in a browser or record why the presentation path is low-risk and not smokeable.

## Governance Trigger Rule

Do not create process artifacts for every change. Trigger architecture governance when work changes a durable system decision or creates a long-lived exception:

- module or capability boundary
- broad refactor, duplication reduction, health-hotspot remediation, large-file split, or module-budget exception
- static analyzer policy that encodes boundaries, public API, runtime entry points, ignored paths, baselines, thresholds, suppressions, or production/test scope
- source of truth or data ownership rule
- public API, event, webhook, schema, SDK, or integration contract
- auth, authorization, tenancy, privacy, or audit boundary
- background workflow, queue, stream, scheduler, retry, or idempotency model
- shared abstraction used by multiple features or teams
- persistence, migration, retention, archival, or deletion policy
- infrastructure, deployment, observability, or operational ownership
- deliberate exception to an existing architecture rule

When triggered, encode the decision in the implementation boundary first: module placement, public interface, validation location, state ownership, tests, static checks, or runtime guard. If it cannot be encoded directly, state the decision, owner, enforcement gap, and revisit condition in the final answer or in the repo's existing architecture artifact.

## Proportionality

Increase rigor when:

- failure has financial, legal, operational, security, or reputational cost
- sensitive data, compliance, tenancy, or permissions are involved
- the code is hot-path, high-scale, or low-latency
- rules are complex, cross-cutting, or likely to change
- multiple teams or systems depend on the boundary
- external systems or async workflows are involved
- operability, auditability, rollback, or resiliency matter

Reduce ceremony when:

- the change is local, low risk, and easy to reverse
- the code is a thin adapter over an established core
- the lifetime is short and blast radius is genuinely small
- extra layers would mostly add indirection

Even in small work, do not relax security, data correctness, dependency direction, or testability.

## Implementation Output Standard

For local build work, architecture should be evident in code:

- module/file placement reflects ownership
- exported interfaces are narrow
- authoritative validation is in the owning layer
- framework/vendor details stay at edges where practical
- tests protect meaningful invariants
- repeated boundary violations get stronger enforcement

For final answers, be concise. Mention only material architecture decisions, tradeoffs, enforcement added, and residual risks.

For repo-level architecture reviews, include:

- current-state diagnosis and structural failure modes
- current architecture shape
- intended architecture direction
- target-state design quality: owners, boundaries, contracts, enforcement, and transition feasibility
- transition plan from current state to target state
- ownership gaps
- enforcement mechanisms or missing fitness functions
- accepted exceptions and cleanup paths
- architecture health score and top risks

Avoid vague phrases like "clean architecture" or "best practice" without naming the concrete rule, boundary, enforcement mechanism, or operational risk.

## Broad Review Preflight

For broad architecture reviews, run:

```bash
~/.codex/skills/architecture-standards/scripts/architecture-preflight.sh
```

Use the output to identify module boundaries, architecture docs/specs, config/enforcement signals, high-risk surfaces, and smell clusters. The script is a context collector, not a substitute for reading code.

## Final Check

Before finishing architecture-guided work:

- Did the code land in the owning capability/layer?
- Did the implementation reuse the existing architecture path instead of creating a bypass?
- Is the public surface narrow and explicit?
- Are inner rules free of framework/vendor/transport details where practical?
- Is authoritative validation enforced at the correct layer?
- Were legacy data, old callers, jobs/scripts, and fallback/read-model paths considered where relevant?
- Is the architecture protected by tests, types, schemas, guards, lint/static rules, or dependency boundaries where risk justifies it?
- If the work moved broad presentation code, were representative user-facing screens browser/visually smoke-tested or explicitly scoped out with a reason?
- If analyzer config, duplication exceptions, refactor targets, or module-budget policy changed, does the policy model a real architecture fact rather than hiding debt?
- Is any temporary exception paired with a cleanup path?

These standards are guardrails, not dogma. Use them to build systems that are clear, secure, operable, maintainable, and safe to change.

---
name: architecture-standards
description: Use this skill when designing system architecture, scaffolding a new application, service, or feature, refactoring toward cleaner boundaries, reviewing code for architectural quality, or making implementation decisions that affect ownership, layering, contracts, persistence, async workflows, auth/tenancy, shared abstractions, operability, or long-term maintainability. The skill guides code design with practical, enforceable boundaries rather than documentation ceremony.
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
7. State tradeoffs only when material or non-obvious.

## Progressive Reference Loading

Load only the references needed for the task:

- `references/decision-framework.md`: use for meaningful design choices, proportionality, ownership, and tradeoff reasoning.
- `references/architecture-shapes.md`: use when choosing modular monolith vs services, sync vs async, CRUD vs domain model, CQRS/read models, API style, persistence, jobs, or abstraction level.
- `references/layer-standards.md`: use when placing code, defining boundaries, or checking dependency direction across presentation/application/domain/data/infrastructure/API layers.
- `references/implementation-recipes.md`: use when building or changing a feature, validation rule, API, persistence model, shared component, background job, cache/fallback, or integration.
- `references/enforcement-patterns.md`: use when an architecture rule should be protected by tests, types, schemas, runtime guards, lint/static checks, dependency rules, or operational checks.
- `references/cross-cutting-standards.md`: use for security, performance, reliability, observability, testability, maintainability, and cost.
- `references/smell-triage.md`: use when deciding whether architecture debt is `must fix now`, `should fix if cheap/safe`, or `defer`.
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
- identify owners for capabilities, data, contracts, and operational workflows
- use `architecture-scorecard.md` for repo-level health
- use `smell-triage.md` to separate must-fix risks from refactor preferences
- recommend code-level enforcement before documentation
- call out exceptions, cleanup paths, and missing fitness functions

## Code Design Gate

Before building code that introduces or changes a module, shared helper, state owner, schema, API route, data model, background job, integration, cache/fallback, or cross-feature behavior, answer through the implementation:

- **Where should this code live?** Put it in the owning capability/layer, not where the request first appears.
- **Who owns the invariant?** Enforce business rules, permissions, tenancy, generated IDs, and persistence constraints at the authoritative layer.
- **What is the public boundary?** Expose the narrowest command, query, component, hook, schema, adapter, or event callers need.
- **What must not depend on what?** Keep inner policy free of framework, transport, vendor, and presentation dependencies.
- **What path bypasses this?** Check alternate UI surfaces, API routes, jobs, scripts, imports, direct mutations, and fallback/read-model paths.
- **How is this enforced?** Prefer tests, types, schemas, runtime guards, dependency rules, or CI/lint checks over comments.
- **What is the failure mode?** Design retries, idempotency, rollback, user feedback, observability, and partial-failure behavior where relevant.
- **What gets deleted later?** If this is a shim, fallback, feature flag, compatibility path, or exception, make the cleanup path visible.

If the answer is "just add it to the closest component/handler/helper," stop and check whether that scatters policy, duplicates a rule, or bypasses the real owner.

## Governance Trigger Rule

Do not create process artifacts for every change. Trigger architecture governance when work changes a durable system decision or creates a long-lived exception:

- module or capability boundary
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

- current architecture shape
- intended architecture direction
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
- Is any temporary exception paired with a cleanup path?

These standards are guardrails, not dogma. Use them to build systems that are clear, secure, operable, maintainable, and safe to change.

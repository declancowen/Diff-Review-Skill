# Static Analyzer Policy

Use this when static analyzer config, findings, duplication reports, refactor targets, baselines, suppressions, or audit artifacts influence architecture decisions.

The core rule: analyzer output is not architecture by itself. It is evidence about ownership, dependency direction, repeated invariants, module pressure, and transition state. Architecture decides what the evidence means.

## What Analyzer Evidence Can Mean

### Dead Code

Dead code can mean:

- real removable implementation
- public API or plugin/runtime entry point not visible to static analysis
- framework convention or generated contract
- compatibility shim
- test-only support code
- stale architecture exception

Before deleting or suppressing, identify the owner and runtime/public contract. Use trace-style evidence when available. If the code is intentionally retained, prefer modeling the intent in config, exports, dynamic entry points, public package policy, or a tracked expected-unused marker instead of hiding it with broad ignores.

### Duplication

Duplication is an architecture signal, not automatically a refactor order.

Interpret by ownership:

- **Same owner, same invariant:** extract a small helper if it reduces maintenance risk and keeps the public interface narrow.
- **Same owner, different variants:** keep separate if the variation is meaningful; consider a shared lower-level formatter/parser/validator only if the invariant is stable.
- **Cross-owner, same business rule:** move the rule to the authoritative capability/layer. Do not create a generic utility that hides ownership.
- **UI and domain duplicate a rule:** the durable rule belongs in the authoritative domain/data/application layer; UI may keep user-guidance validation only.
- **Route/API duplication:** extract shared transport helpers only when route semantics remain explicit and error/security behavior stays consistent.
- **Test duplication:** decide whether repeated setup is harmless readability or whether a fixture helper should encode a contract. Shared test helpers are architecture surfaces when they simulate persistence, identity, tenancy, time, or external services.
- **Semantic duplication:** treat as a smell map for repeated structure. It can reveal scattered policy even when exact clone gates are clean, but it is too broad to use as a blind blocking gate.

Refactor only when the extraction has a named owner, stable invariant, narrow API, and direct verification. Do not move code to `shared` just because two blocks look alike.

### Refactor / Health Targets

Complexity, size, coupling, churn, and hotspot reports suggest where change cost is high. They do not decide the design.

Use a target to ask:

- What responsibilities are mixed?
- What invariant is hard to see or test?
- What callers depend on this shape?
- Is the module large because it owns a coherent contract, or because orchestration, policy, persistence, presentation, and integration are tangled?
- Would a split reduce real risk, or just distribute complexity across more files?

Good refactors usually separate one of these:

- transport parsing from application command/query handling
- presentation state from domain state
- pure policy from persistence/framework adapters
- data access/read shaping from mutation authority
- integration adapter from product semantics
- repeated test fixture mechanics from assertions

Bad refactors usually:

- create generic helpers with no capability owner
- hide policy in utility modules
- split files without narrowing public interfaces
- remove local readability for a small clone
- leave bypass paths using the old logic

### Module Budgets

Module budgets are architecture pressure, not an aesthetic rule. A budget exception must be a policy decision:

- owner
- reason the module is a central contract or temporary transition point
- cap or scope
- tests/static checks protecting the contract
- revisit trigger

Permanent allowlists should be rare. If a budget allowlist exists only because a split is inconvenient, treat it as transition debt.

### Feature Flags And Environment Gates

Flags and env gates encode architecture because they change runtime behavior by environment, tenant, rollout cohort, or operator action.

For each flag, identify:

- owner
- default in local, test, preview, staging, production
- fail-open or fail-closed behavior
- security/tenancy impact
- cleanup trigger
- verification for both enabled and disabled states

### Coverage Gaps

Static coverage gaps are prioritization evidence, not proof that behavior is untested in every meaningful way. Use them to find missing direct tests around high-risk runtime files, routes, jobs, adapters, public APIs, and UI smoke paths.

## Analyzer Config As Architecture Policy

Treat these config changes as architecture decisions:

- boundary zones and allowed imports
- ignored paths
- public packages
- dynamic/runtime-loaded files
- entry points
- production/test analysis scope
- duplication thresholds and baselines
- health thresholds and module budgets
- suppressions and expected-unused markers
- coverage and runtime evidence sources

Before changing analyzer policy, answer:

- What architecture fact is being modeled?
- Who owns this exception or rule?
- What would make the exception stale?
- Is there a stronger code-level enforcement available?
- Is the change hiding current debt or describing intentional design?

## Fallow Fitness Functions

When Fallow is present, architecture policy should define fitness functions that can be falsified by commands, not by prose:

- **Dead-code fitness:** configured production dead-code gate and full inventory are reported separately.
- **Duplication fitness:** clone groups, duplicated lines, and duplication percentage have a cap or ratchet rule; baseline-equal passes are accepted debt, not cleanup.
- **Health fitness:** critical/high/moderate health findings have thresholds and a remediation owner, or are explicitly advisory with a cap.
- **Boundary fitness:** `list --boundaries` shows whether boundaries are configured; absent boundaries are a design fact, not an assumed rule.
- **Scope fitness:** production-only and full non-production inventories are both named when they differ.
- **Exception fitness:** baselines, allowlists, suppressions, ignored exports, and module-budget exceptions have owner, reason, stale condition, evidence command/date, and revisit trigger.
- **CI fitness:** package scripts and CI workflows agree on which analyzer commands block and which are advisory or `continue-on-error`.

Good architecture language is scope-safe: "production configured dead-code count is clean" or "duplication is budgeted at baseline." Avoid "Fallow is clean" unless every relevant scope is clean.

## Closure Hazards From Analyzer-Driven Refactors

Broad remediation can create new architecture risk while clearing old findings. Check these failure modes before declaring completion:

- **Test-only production exports:** coverage-first work may export internals from production modules so tests can import them. That pollutes the public surface and weakens production dead-code evidence. Fix by moving stable primitives into owner-local modules imported by production and tests, or by testing behavior through the existing public owner.
- **Stale coverage artifacts:** health findings can be wrong after adding tests unless the coverage artifact is refreshed. Run coverage before interpreting coverage-aware health.
- **Duplicate tests introduced by fixes:** route or component regression tests can create clone groups through repeated assertions. Use local test helpers or fixtures that preserve test intent rather than accepting new duplication.
- **Score-vs-finding confusion:** `0` health findings with a score below `100` means remaining aggregate pressure, not a live finding list. Use it for future design planning, not mechanical branch splitting.
- **Public contract key drift:** internal option names can leak into serialized route/query/form/storage/API contracts. Contract tests must assert the public serialized key, especially on validation, failure, retry, and redirect branches.
- **Outdated PR review comments:** once a finding is fixed on a later commit, mark the old thread resolved only after current-tree proof and tests. Do not treat an outdated thread as false without proving behavior.

## Transition Ledger

Architecture reviews and audits should classify analyzer-backed work as:

- **fixed:** code or policy changed and verification proves it
- **must-fix:** live correctness, security, tenancy, data, contract, or operability risk
- **should-fix:** meaningful maintainability risk near active work
- **deferred:** real debt, but broad/risky enough to plan separately
- **accepted:** intentional tradeoff with owner and revisit trigger
- **policy-modeled:** analyzer config now represents an intentional runtime/public architecture fact
- **deployment-gated:** repo evidence is insufficient until deployed services/secrets/traffic prove the path
- **inventory-only:** useful map for future planning, not a current gate

Do not let `accepted`, `deferred`, or `inventory-only` become equivalent to `done`.

Budgets must ratchet intentionally. Raising a duplication, health, or module-size budget requires an accepted-debt entry with owner, reason, new cap, evidence command/date, and revisit trigger. Silent budget increases hide architecture drift.

## Report Review Checklist

When reading an analyzer-backed report or transition plan:

- Separate gates from advisory inventories.
- Compare raw signals, configured signals, changed-code signals, and production-mode signals separately.
- Reconcile stale statements: old backlog counts may no longer match final state.
- Search for allowlists, baselines, suppressions, and thresholds before trusting a zero count.
- Check whether refactors added shared ownership or merely moved complexity.
- Check whether each broad refactor has behavior-preserving tests or invariant proof.
- Verify UI/presentation refactors with browser or visual smoke when user-facing layout, empty states, navigation, or shared presentation primitives changed.
- Verify helper extraction semantics for object identity, mutation vs replacement, ordering, pagination, async timing, and error behavior.
- Check sibling paths for the same bug class after fixing one analyzer finding.
- Check sibling contract serializers after a PR or analyzer finding about one builder, route, form, webhook, storage key, query key, or API payload key.
- Check stale evidence: old counts need `HEAD`, date, command, mode, and scope, or they must be rerun before they support a conclusion.
- Check CI parity: a `continue-on-error` analyzer workflow is advisory even if local scripts are blocking.
- Check validation depth: broad refactors, helper extraction, public-surface movement, and route/server boundary changes need full tests or a documented low-risk rationale for narrower checks.

## Carryover To Review And Audit

`diff-review` should apply this model to changed files and branch deltas.

`repo-audit` should apply this model to repo-wide evidence, trend, transition ledgers, and cleanup plans.

`architecture-standards` owns the interpretation: whether a finding is a boundary issue, source-of-truth issue, public contract issue, transition debt, or harmless local repetition.

Use the `fallow` skill reference `quality-benchmarks.md` as a regression benchmark when a prior architecture pass missed widespread duplication, dead code, health hotspots, or gate/inventory drift.

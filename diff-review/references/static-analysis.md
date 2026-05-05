# Static Analysis In Diff Review

Use this when a diff touches analyzer output, Fallow/Knip/jscpd/dependency tooling, quality gates, boundaries, duplicate/refactor work, suppressions, baselines, module budgets, or audit/review artifacts based on static analysis.

The review goal is not to repeat analyzer output. The goal is to decide whether the change preserves behavior, ownership, and architecture while using analyzer evidence intelligently.

## Review Stance

- Treat analyzer findings as evidence, not findings by themselves.
- Preserve mode semantics: changed-only, production-only, semantic duplication, configured gates, raw inventories, and baselines mean different things.
- Interpret duplication and refactor work through `architecture-standards/references/current-state-diagnosis.md`, `architecture-standards/references/target-state-design.md`, `architecture-standards/references/static-analyzer-policy.md`, and `architecture-standards/references/refactor-design.md` when available.
- Do not call a branch clean just because the configured gate passes if advisory inventories or old caveats remain relevant to the changed files.
- Do not block a branch on advisory inventories unless they expose a live risk in the diff.

## Preflight

Check for:

- analyzer config: `.fallowrc*`, `knip.*`, `.jscpd*`, dependency-cruiser, lint boundary config
- package scripts and CI jobs invoking analyzers
- baselines, suppressions, ignored paths, public package policy
- prior `.reviews/` and `.audits/` entries mentioning analyzer caveats
- changed files in analyzer config, helper modules, boundaries, public APIs, test fixtures, or refactor targets

If Fallow is present, prefer focused JSON probes:

```bash
fallow config --format json --quiet
fallow list --plugins --entry-points --boundaries --format json --quiet
fallow audit --changed-since <base> --format json --quiet --explain
```

Use the project-local package runner when possible, keep stderr separate from JSON stdout, and treat exit code `1` as findings rather than tool failure. Exit code `2` is a tool/config/runtime failure. Do not parse mixed human/progress output.

## Fallow Required Evidence Matrix

When Fallow is installed or configured and the diff touches remediation, static policy, broad refactors, shared helpers, public surfaces, module boundaries, dead code, duplication, or health hotspots, collect or explicitly scope out these lenses before all-clear:

| Evidence | Command | Interpretation |
| --- | --- | --- |
| Loaded policy | `fallow config --format json --quiet` | Which config, rules, ignores, thresholds, baselines, and boundaries are actually in effect |
| Repo shape | `fallow list --plugins --entry-points --boundaries --format json --quiet` | Framework detection, runtime entry points, and whether architecture boundaries are configured |
| Changed-file gate | `fallow audit --changed-since <base> --format json --quiet --explain` | PR signal only; not full repo health |
| Production dead code | `fallow dead-code --production --format json --quiet --summary` | Shipping configured dead-code state |
| Full dead code | `fallow dead-code --format json --quiet --summary` | Advisory/full-scope inventory, including tests and support code |
| Production health | `fallow health --production --max-crap 1000000 --format json --quiet --summary` | Shipping complexity gate without coverage-distorted CRAP failures |
| Full health | `fallow health --format json --quiet --summary` | Advisory hotspot and refactor risk map |
| Production duplication | `fallow dupes --production --ignore-imports --format json --quiet` | Shipping duplication budget state |
| Full duplication | `fallow dupes --format json --quiet` | Advisory inventory; can differ materially from production |
| Fix preview | `fallow fix --dry-run --format json --quiet` | Candidate removals only; review actions against public/runtime intent |

If the branch only changes a narrow file, the changed-file gate plus targeted trace commands may be enough. If the branch claims Fallow remediation, architecture cleanup, broad extraction, or health/duplication reduction, full and production lenses are both required.

## Scope-Safe Conclusion Language

Use precise wording:

- "production configured dead-code count is clean" rather than "dead code is clean"
- "changed-file Fallow audit passed" rather than "Fallow says the repo is clean"
- "duplication is budgeted at the current baseline" rather than "duplication is fixed"
- "full non-production inventory remains advisory" when test/support code still has findings

Old counts are stale unless the review records `HEAD`, date, command, mode, and scope for the evidence being used.

Add probes by changed surface:

- dependency/package/config changes: `dead-code --production`, `trace-dependency`
- file deletion/de-export: `trace-file`, `trace`
- duplication/refactor branch: `dupes --changed-since <base>`, optionally `dupes --mode semantic --changed-since <base>`
- architecture boundary/config change: `list --boundaries`, boundary-specific dead-code filters where supported
- auth/env/rollout change: `flags`
- broad UI presentation refactor: changed audit plus browser/visual smoke
- test fixture/helper refactor: targeted tests plus semantic equivalence review

## Duplication Review

For duplicated-code fixes, review the extraction, not just the count delta.

Check:

- Does the new helper have a clear capability/layer owner?
- Did the extraction preserve each caller's semantics?
- Did it centralize a real invariant or merely hide similar text?
- Did it introduce a dependency direction problem?
- Are error handling, security checks, tenancy filters, sorting, pagination, optimistic state, and async timing preserved?
- Are tests proving the behavior that made the duplication risky?

Red flags:

- new `utils`, `helpers`, or `shared` module with business-specific policy
- UI or route helper now owns a domain rule
- test helper changes object identity, mutation vs replacement, default env restoration, clock behavior, or query ordering
- exact clone count falls but semantic duplication still shows policy scattered across owners

When duplication is broad, ask for the missing design concept, not just the next helper. A branch that removes warnings by scattering many small helpers can still worsen architecture if ownership remains unclear.

If the branch is part of a messy-repo remediation, review whether it improves the current-state failure mode it claims to address. A refactor can pass analyzer gates and still leave unclear ownership, scattered policy, or weak fitness functions intact.

Also review whether the diff sharpens the target state. A remediation that splits files but does not define owners, dependency direction, public surfaces, or enforcement may only redistribute the debt.

Duplication budgets are not completion. A budget increase or a baseline-equal pass needs an accepted-debt record with owner, reason, cap, evidence command/date, and revisit trigger. Without that, lower confidence or keep the issue open.

## Refactor / Health Review

For complexity or module-budget refactors, review responsibility boundaries:

- What responsibility moved?
- What public interface narrowed?
- What bypass path still uses the old logic?
- Did behavior-preserving tests exist before the move or get added with it?
- Did the refactor preserve user-visible UI states and browser behavior?
- Did module budget relief come from real ownership split or file shuffling?

Do not accept "health warning removed" as proof. The proof is preserved behavior plus clearer ownership.

Focused tests are insufficient after broad refactors, helper extraction, public-surface changes, or route/server boundary movement unless the residual risk is explicitly low. Require full tests or a documented reason. This guards against cases where focused tests pass while broader validation catches boundary leaks, import side effects, or hidden caller coupling.

If the diff is part of an audit transition plan, verify the plan's architecture claim: which boundary became clearer, which invariant moved to its owner, and which residual clusters remain.

## Analyzer Policy Review

If the diff changes analyzer config, baselines, thresholds, suppressions, or ignored paths, review it as architecture policy:

- What architecture fact is modeled?
- Why is code change not the better answer?
- Is the exception narrow?
- Is there a cleanup/revisit trigger?
- Does CI enforce the intended gate?
- Are prior audit caveats updated?

## Review File Evidence

When analyzer evidence matters, the review turn should record:

- commands or artifacts used
- analyzer mode and scope
- blocking gates vs advisory inventories
- duplication/refactor architecture interpretation
- accepted/deferred/policy-modeled items
- verification that proves behavior, not only analyzer cleanliness
- residual analyzer caveats that remain non-blocking

## All-Clear Additions

Before all-clear on analyzer/refactor-heavy diffs:

- changed-code analyzer verdict is parsed or intentionally scoped out
- production and full advisory Fallow views are separated when Fallow is present
- CI analyzer behavior was compared with package scripts, including `continue-on-error` versus blocking local gates
- stale analyzer counts are rerun or explicitly marked stale with `HEAD`, date, command, mode, and scope
- accepted debt for baselines, suppressions, allowlists, and budgets has owner, cap, and revisit trigger
- prior analyzer caveats in `.reviews/` / `.audits/` are resolved, still accepted, or irrelevant to this diff
- no new broad suppressions, baselines, or threshold increases hide live risk
- refactor tests/browser smoke match the changed risk surface
- architecture ownership of new shared helpers is clear

## Regression Benchmarks

Load the `fallow` skill reference `quality-benchmarks.md` when reviewing Fallow-backed remediation or when a previous review missed structural debt. In particular, refuse all-clear or lower confidence when:

- Fallow exists but only lint/typecheck/tests were run.
- changed-file audit passes but full duplication or health inventory remains unclassified.
- production dead-code is clean but full dead-code still reports test/helper exports.
- CI runs Fallow as `continue-on-error`, while local scripts contain stricter gates.
- duplication budget passes only because it equals the current baseline without an accepted-debt owner and revisit trigger.

# Static Analysis In Repo Audit

Use this when a repo has static analyzer tooling, analyzer-backed audit artifacts, duplication/refactor reports, baselines, suppressions, quality gates, coverage reports, or architecture boundary checks.

The audit goal is to turn analyzer data into a governed repo-health picture. Analyzer output is one evidence stream; architecture interpretation and risk triage decide what matters.

## Evidence Map

Build an analyzer evidence map before concluding repo health:

- tools present and versions when available
- configs loaded and policy owners
- package scripts and CI gates
- baselines and regression snapshots
- suppressions, ignored paths, public packages, dynamic entry points
- raw inventories
- configured gates
- changed-code gates
- production/test scope
- duplication modes
- health/refactor/hotspot signals
- coverage/runtime evidence
- prior `.audits/` and `.reviews/` caveats

For Fallow, useful discovery commands are:

```bash
fallow schema --format json --quiet
fallow config --format json --quiet
fallow list --plugins --entry-points --boundaries --format json --quiet
```

Use the project-local package runner when possible. Keep stderr separate from JSON stdout, treat exit code `1` as findings, and treat exit code `2` as tool/config/runtime failure. Always record `HEAD`, date, command, mode, and scope for counts that support an audit conclusion.

## Fallow Audit Command Ladder

For a Fallow-backed repo audit, gather these signals or explicitly scope them out:

| Phase | Commands | Purpose |
| --- | --- | --- |
| Capability discovery | `fallow schema --format json --quiet`, `fallow config --format json --quiet`, `fallow list --plugins --entry-points --boundaries --format json --quiet` | Verify version surface, loaded policy, plugins, entry points, and boundary configuration |
| Configured production gates | repo scripts such as `pnpm fallow:gate`, or direct `dead-code --production`, `health --production`, `dupes --production` probes | Shipping-policy state |
| Full inventories | `dead-code`, `health`, and `dupes` without `--production` | Non-production/test/support advisory debt and architecture shape |
| Changed-code audit | `fallow audit --changed-since <base> --format json --quiet --explain` | PR regression signal only |
| Semantic duplication | `fallow dupes --mode semantic --format json --quiet` when duplication is a design question | Scattered structure/policy inventory, not a blind gate |
| Health planning | `fallow health --hotspots --targets --file-scores --format json --quiet` when health is material | Refactor priority and ownership pressure |
| Fix preview | `fallow fix --dry-run --format json --quiet` | Candidate removals requiring public/runtime review |

Do not call the repo healthy from a changed-file audit alone. Do not call it clean from production-only evidence when full inventories still carry relevant advisory debt.

## Gate And Inventory Separation

Do not collapse all analyzer evidence into pass/fail.

Track separately:

- **blocking gates:** current repo policy fails
- **changed-code gates:** PR/branch regression signal
- **raw inventories:** full list without baselines or skip-local filters
- **configured inventories:** repo policy view
- **production-only signals:** shipping/runtime scope
- **semantic duplication:** repeated structure and scattered policy map
- **hotspots/refactor targets:** planning and risk prioritization
- **coverage gaps:** test planning signal
- **feature flags:** lifecycle and environment behavior signal
- **policy drift:** config no longer matches architecture

## Transition Ledger

Every analyzer-backed audit should classify work into:

- fixed
- must-fix
- should-fix
- deferred
- accepted
- policy-modeled
- deployment-gated
- inventory-only

Include owner, evidence, verification, and revisit trigger for anything not fixed.

This matters because "accepted baseline," "deferred refactor," "allowlisted module," and "raw inventory" are different risk states.

Budgets and baselines are accepted debt until reduced or removed. Duplication budgets, suppressions, allowlists, and health exceptions need owner, reason, cap, evidence command/date, and revisit trigger. A passing budget at the current baseline is not the same thing as debt removal.

## Duplication And Refactor Interpretation

Load `architecture-standards/references/current-state-diagnosis.md`, `architecture-standards/references/target-state-design.md`, `architecture-standards/references/static-analyzer-policy.md`, and `architecture-standards/references/refactor-design.md` when duplication or refactor reports are material.

Audit questions:

- What duplicate groups represent repeated business rules?
- Which duplicates are harmless local presentation/test shape?
- Which duplicates cross ownership boundaries?
- Which refactor targets mix presentation, application orchestration, domain policy, persistence, and integration code?
- Did prior remediation split modules by real ownership or just lower metrics?
- Are shared helpers now capability-owned and narrow?
- Are broad UI refactors browser-smoked?
- Are test fixture refactors behavior-preserving?

The audit should synthesize these into current-state diagnosis and design themes. Do not leave the reader with "98 duplicate groups" or "123 health warnings" as the conclusion. Name why the architecture is not functioning: unclear ownership, scattered policy, boundary theater, mixed responsibility modules, unowned contracts, weak fitness functions, or whatever the evidence shows.

Then evaluate the target-state design. A target state is not credible unless it names owners, dependency direction, public surfaces, contracts, enforcement, transition slices, and accepted exceptions for the structural failures the audit found.

## Analyzer Config Review

Treat analyzer config as audit scope:

- boundaries and allowed imports
- ignores and generated/vendor/build exclusions
- public packages and dynamic loading
- baselines and regression settings
- thresholds, health budgets, duplication modes
- suppressions and stale suppression checks
- production mode and coverage inputs

For each exception, ask whether it models a real architecture/runtime fact or hides debt.

## Audit Report Shape

When analyzer evidence is material, the audit should include:

- command/artifact matrix
- `HEAD`, date, command, mode, and scope for every reused count
- mode/scope notes for each signal
- CI parity table: package scripts, CI workflow commands, blocking versus `continue-on-error`
- before/after trend table when history exists
- gate vs inventory table
- top architecture-relevant duplication/refactor themes
- current-state architecture failure modes
- target-state design gaps and missing fitness functions
- design response for each major duplication/refactor cluster
- transition ledger
- CI enforcement status
- verification matrix and skipped/deployment-gated checks
- stale caveats from previous audits/reviews

Use scope-safe language: "production configured dead-code count is clean," "changed-file audit passed," "full inventory remains advisory," or "duplication is budgeted at baseline." Avoid broad "Fallow is clean" unless every stated scope is actually clean.

## Clean Conclusion Bar

A clean repo-audit conclusion requires:

- configured gates are clean or open findings are explicitly scoped
- raw/advisory inventories are not misrepresented as zero if they remain
- accepted/deferred/policy-modeled items have owners and revisit triggers
- analyzer config does not hide live security, tenancy, data, contract, or operability risk
- high-risk refactors have direct verification
- deployment-gated evidence is named separately from repo-code evidence
- broad refactors, helper extractions, and boundary moves have full tests or an explicit low-risk rationale for focused-only validation

## Skill Miss Retrospective Benchmark

Load the `fallow` skill reference `quality-benchmarks.md` when evaluating whether the audit process is strong enough. The canonical miss pattern is a repo that normal review/audit skills could call acceptable while Fallow later exposes material configured dead-code inventory, broad duplication, and critical/high health hotspots.

A passing audit process must identify:

- configured gates and raw/full advisory inventories separately
- production versus full-mode differences
- critical health hotspots and clone clusters as architecture evidence
- residual duplication as accepted debt with owner/cap/revisit trigger
- CI parity, especially `continue-on-error` analyzer jobs versus stricter local gates
- full-validation requirements after broad refactors

If any of those are missing, do not give a clean repo-health conclusion.

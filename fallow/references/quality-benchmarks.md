# Fallow Skill Quality Benchmarks

Use this when improving or evaluating skills that consume Fallow evidence. The benchmark goal is not to mention Fallow. The goal is to prevent false clean conclusions when analyzer evidence is missing, stale, or scoped too narrowly.

## Canonical Miss Pattern

Use this as a generalized miss pattern, not as repo-specific audit data.

Evidence that a competent audit/review/architecture skill should surface before broad cleanup:

- a material configured dead-code inventory
- a material duplication inventory or duplication percentage
- health inventory with critical/high hotspots
- production gates that differ from full-repo inventories
- duplication or health debt accepted as budgeted transition debt
- focused tests passing while broader validation would catch a boundary or import leak

Passing behavior:

- `repo-audit` reports dead-code, health, duplication, configured gates, full inventories, accepted debt, and CI parity separately.
- `architecture-standards` converts clone groups and health hotspots into current-state failure modes, target-state rules, owners, public surfaces, and fitness functions.
- `diff-review` refuses all-clear on broad refactors until changed-file Fallow evidence, production gate evidence, full advisory evidence, and behavior validation are scoped correctly.
- `spec-driven-development` blocks implementation-ready requirements/tasks for audit-remediation work until static analyzer evidence, transition debt, and fitness functions are in the design.

Failing behavior:

- saying "Fallow is clean" when only one configured production gate is clean
- saying "duplication is handled" when the budget merely matches the current baseline
- treating `fallow audit --changed-since` as full repo health
- accepting focused tests as sufficient after moving broad boundaries or helper ownership
- treating a `continue-on-error` CI analyzer step as a blocking gate

## Negative All-Clear Benchmarks

A hardened skill must lower confidence or block a clean conclusion in these cases:

- Fallow is installed or configured, but the review only ran lint, typecheck, and tests.
- `fallow audit --changed-since <base>` passes, but full duplication inventory is high or unclassified.
- production dead-code is clean, but full dead-code reports test/helper exports or other non-production debt.
- CI runs Fallow as `continue-on-error`, while package scripts contain stricter local Fallow gates.
- duplication budget passes only because it equals the current baseline, with no owner, cap, or revisit trigger.
- old audit counts are reused without rerunning, without recording `HEAD`, date, command, mode, and scope.
- a broad refactor is verified only by focused tests after changing shared helpers, route/server boundaries, or public surfaces.

## Required Output Qualities

Skill output should use scope-safe language:

- "production configured dead-code count is clean" instead of "dead code is clean"
- "changed-file audit passed" instead of "repo is clean"
- "duplication is budgeted at baseline" instead of "duplication is fixed"
- "full inventory remains advisory" instead of hiding non-production findings

Accepted debt must be visible:

- owner
- reason
- cap or budget
- revisit trigger
- evidence command and date
- whether it is blocking, advisory, policy-modeled, deployment-gated, or inventory-only

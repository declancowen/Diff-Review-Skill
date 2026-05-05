# Fallow Analysis Primitives

Use this when choosing Fallow commands, interpreting JSON output, or translating Fallow evidence into review, audit, or architecture decisions.

## Command Hygiene For Agents

Prefer project-local commands when available:

```bash
pnpm exec fallow --version
npm exec fallow -- --version
```

Use `npx --yes fallow@<version>` only when the repo intentionally pins that form or no local install exists.

For machine-readable commands:

```bash
fallow health --format json --quiet --explain 2>/dev/null || true
```

Rules:

- Use JSON for analysis; use human/markdown output only for people-facing summaries.
- Keep stderr separate from JSON stdout.
- Treat exit code `1` as findings, not tool failure.
- Treat exit code `2` as invalid input/config/tool failure.
- Never run `fallow watch` in an agent turn.
- Always use `fix --dry-run --yes` before any apply step.

## Capability Discovery

Do not assume package scripts expose every useful analyzer surface.

Use:

```bash
fallow schema --format json --quiet
fallow config --format json --quiet
fallow config --path
fallow config-schema --format json --quiet
fallow list --plugins --entry-points --boundaries --format json --quiet
```

This tells you what the current binary can do, which config loaded, what framework plugins activated, what entry points were detected, and which architecture boundaries are policy.

## Choose The Lens By Question

| Question | Fallow primitive |
| --- | --- |
| What is the current configured gate state? | `fallow --format json --quiet --explain` |
| Is this file/export/dependency actually reached? | `dead-code --trace-file`, `dead-code --trace`, `dead-code --trace-dependency` |
| Did this branch introduce issues? | `audit --changed-since <ref> --format json --quiet --explain` |
| What changed-file quality signal should a PR see? | `audit`, optionally with per-analysis baselines |
| What exact unused category matters? | `dead-code --unused-files`, `--unused-exports`, `--unlisted-deps`, etc. |
| What only matters in shipping/runtime scope? | `dead-code --production` or production mode per analysis |
| Are framework entry exports hiding typos? | `dead-code --include-entry-exports` as a targeted probe |
| Where is exact or mild copy-paste? | `dupes` with configured/default mode |
| Where is similar logic scattered? | `dupes --mode semantic` |
| What is cross-directory only? | `dupes --skip-local` |
| What is high churn plus complexity? | `health --hotspots --ownership` |
| What should be considered for refactor planning? | `health --targets`, `health --file-scores` |
| Where might direct test reachability be weak? | `health --coverage-gaps` |
| What flags/env gates exist? | `flags` |
| What architecture zones and counts exist? | `list --boundaries` |

## Mode Semantics

Different modes answer different questions:

- `--changed-since` reports issues in changed files or clone groups involving changed files. It is not repo-total evidence.
- `audit` combines changed-file dead-code, health, and duplication. Its verdict is a PR signal, not a full audit.
- `--production` excludes test/dev scope and may reveal type-only or script-only dependency behavior. It is not a replacement for full-repo analysis.
- `--include-entry-exports` intentionally challenges framework/public entry exports. Expect false positives; use it for targeted typo/contract checks.
- `dupes --mode semantic` normalizes identifiers and can report many structural similarities. Use it as architecture inventory, not as a blind cleanup gate.
- `--skip-local` focuses on cross-directory duplication. It can miss repeated logic inside one large module.
- `health --coverage-gaps` is static dependency-path coverage, not runtime coverage. Use it for test planning.
- Runtime coverage and paid/cloud workflows are optional. Do not activate or configure them unless requested or already available.

## JSON Output Semantics

Preserve these distinctions:

- `summary` / counts: gate magnitude
- issue arrays: actionable findings
- `actions`: suggested remediation/suppression/config actions, not commands to execute blindly
- `_meta` from `--explain`: definitions and interpretation hints
- `stats`: duplication/file totals and percentages
- `vital_signs`: trendable quality metrics
- `clone_groups` vs `clone_families`: exact instances vs related clone clusters
- `hotspots`, `targets`, `file_scores`: planning signals
- baselines/regression output: identity or count deltas, depending on command

When summarizing, identify whether a number is raw, configured, changed-only, production-only, semantic, skip-local, or baseline-adjusted.

## Evidence Classes

Classify every signal before acting:

- **blocking gate:** current policy says this must fail or be fixed
- **changed-code warning:** relevant to PR review but not necessarily repo-total
- **advisory inventory:** useful map, not an immediate gate
- **architecture signal:** ownership, boundary, source-of-truth, or abstraction question
- **policy drift:** config no longer matches code shape or architecture intent
- **runtime/public exception:** static analysis cannot see a real entry point
- **deployment-gated:** static/local result cannot prove third-party/env behavior

## Deletion And Suppression Guard

Before deleting, de-exporting, or suppressing:

1. Trace the file/export/dependency where possible.
2. Check framework conventions, package exports, generated code, scripts, CLIs, jobs, migrations, routes, config references, and dynamic imports.
3. Decide whether the right action is code deletion, private-local conversion, public API modeling, dynamic entry modeling, dependency move, narrow suppression, or deferral.
4. Run focused verification for the owning behavior.

## Reporting Pattern

Use a ledger instead of a flat list:

- fixed now
- must-fix next
- deferred with reason
- accepted with revisit trigger
- policy-modeled
- deployment-gated
- inventory-only

This prevents a zero gate from hiding advisory debt and prevents advisory inventories from being mistaken for blockers.

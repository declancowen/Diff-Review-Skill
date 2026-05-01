# Fallow Workflows

## Command Recipes

Use the repo's package script, `pnpm exec fallow`, or the package-manager equivalent when Fallow is installed locally. Use `npx --yes fallow` only when the package is not installed locally and the user has approved network/tool execution.

Baseline adoption:

```bash
npx fallow --format json
npx fallow dead-code --format json
npx fallow dupes --format json
npx fallow health --format json
npx fallow fix --dry-run --format json
```

Focused dead-code passes:

```bash
npx fallow dead-code --unresolved-imports --format json
npx fallow dead-code --unlisted-deps --format json
npx fallow dead-code --unused-files --format json
npx fallow list --entry-points
npx fallow dead-code --unused-deps --format json
npx fallow dead-code --unused-exports --unused-types --format json
```

Duplication:

```bash
npx fallow dupes --format json
npx fallow dupes --mode semantic --format json
```

Health:

```bash
npx fallow health --format json
npx fallow health --runtime-coverage ./coverage --format json
```

Auto-fix:

```bash
npx fallow fix --dry-run --format json
```

Only apply fixes after reviewing the preview and confirming scope:

```bash
npx fallow fix --yes
```

PR/CI gate:

```bash
npx fallow audit --format json
npx fallow --ci
```

## Config Policy

Fallow can run without config. Create config when adopting Fallow in an existing repo, when zero-config output has false positives, or when the team needs a durable policy.

Preferred first step:

```bash
npx fallow init
```

Then review the generated `.fallowrc.json` or `fallow.toml`. Important config mechanisms:

- `entry`: project-specific workers, scripts, CLIs, route modules, dynamic roots not detected by framework plugins.
- `ignorePatterns`: generated, vendored, build, fixture, or copied files that should be excluded from all analysis.
- `health.ignore`: files excluded only from complexity analysis while still checked for dead code.
- `publicPackages`: workspace packages whose exports are external API.
- JSDoc visibility tags: `@public`, `@internal`, `@beta`, `@alpha` for export-level API intent.
- `dynamicallyLoaded`: plugin modules, reflection-loaded files, manifest-loaded files, runtime import conventions.
- `ignoreDependencies`: runtime-provided packages, peer deps, CLIs, and intentionally retained packages.
- `@expected-unused`: compatibility shims or future API exports that should self-clean when used.
- `rules`: severity policy (`error`, `warn`, `off`) for rollout.
- `duplicates`: mode, thresholds, and generated-file ignores.
- `health`: max cyclomatic/cognitive/CRAP thresholds and health-only ignores.
- `audit`: changed-file gate policy, usually `new-only` during adoption.
- `boundaries`: architecture zones or presets only when they reflect actual repo structure.
- `production`: production-only analysis when test/demo/dev code would distort shipping-risk decisions.
- `workspaces`: extra workspace patterns not detected from package manager config.

Avoid broad ignores, repeated inline suppressions, and global threshold increases that hide only a few hotspots. A config exception should explain a repo policy or runtime fact, not make the report quiet.

## Run State Detection

Do not infer run state from one artifact. Classify it from the combined evidence:

- **First adoption**: no Fallow config, no committed baselines, no package dependency/script, no CI hook, no prior audit record.
- **Configured without history**: config, baselines, package scripts, CI hooks, or `.fallow/` artifacts exist, but `.audits/fallow.md` is missing or stale. Reconstruct current state from the repo and start a new audit record.
- **Rerun with history**: config plus `.audits/fallow.md` or prior review/audit notes exist. Compare against the previous run.
- **CI/audit-only**: user asks for PR enforcement, `fallow audit`, `--ci`, or CI setup. Confirm repo policy exists before treating this as the right command path.
- **Remediation pass**: user asks to fix known Fallow findings. Read the current report/config first, then rerun focused commands after each batch.

Installation detection:

1. Check package scripts and dependencies for `fallow`.
2. Check lockfile entries when package manifests are ambiguous.
3. If running commands is in scope, try the local command first (`pnpm exec fallow --version`, `npm exec fallow -- --version`, or equivalent).
4. Skip install/download if the local command works.
5. Use `npx --yes fallow ...` only as a fallback.

## First Adoption vs Rerun

First adoption:

1. Collect baseline signals before config generation.
2. Create/tighten config.
3. Fix or model high-confidence findings first.
4. Decide whether CI should warn, baseline existing debt, or block.
5. Document the current policy and open remediation backlog.

Later rerun:

1. Read existing Fallow config, baselines, package scripts, CI hooks, `.audits/fallow.md` if present, and relevant prior `.reviews/`.
2. If docs are missing but config or tool setup exists, treat the run as configured-without-history and rebuild the current-state record instead of reinitializing blindly.
3. Run the baseline signal set again under the current policy.
4. Classify findings as new regression, still-open accepted debt, resolved, stale exception, or policy drift.
5. Revisit optional branches only if repo evidence changed: new packages, new public API surface, new dynamic loader, new coverage artifact, new CI need, or new architecture boundary.
6. Compare counts and top findings against the previous recorded run when available. If raw JSON is too large, preserve summaries that are sufficient to explain deltas.
7. Update `.audits/fallow.md` newest turn first.

## Governance With Optional Skills

Prefer `repo-audit` and `architecture-standards` when they are available in the current Codex environment. Do not assume they exist in every installation. If they are unavailable, continue with the fallback guidance in this file.

Availability check:

1. Use the current session's skill list if it is visible.
2. If skill discovery tools are available, search for `repo-audit` and `architecture-standards`.
3. If unavailable, say so briefly in the assessment and proceed with built-in Fallow governance.

Use `repo-audit` when available for every real Fallow assessment that produces repo health conclusions, remediation planning, or durable documentation. Fallow output is evidence; the audit record is the decision log. If `.audits/fallow.md` is absent, create it and state whether this appears to be first adoption or configured-without-history.

Fallback if `repo-audit` is unavailable: create or update `.audits/fallow.md` anyway, using the "Audit Report Shape" section below. Do not present broad health claims unless the scope, commands, findings, verification, and residual risk are recorded.

The audit record should include:

- what Fallow was asked to analyze
- why optional branches were used or skipped
- which config decisions are repo policy versus temporary rollout choices
- which findings are must-fix, accepted debt, false positives, or deferred
- what verification supports the conclusion
- what should be compared on the next rerun

Use `architecture-standards` when available and a decision affects durable system shape:

- adding or changing Fallow `boundaries`
- marking workspace packages as public API
- deciding whether an export is dead code or public contract
- moving duplicate code into a shared package or shared helper
- changing module placement, dependency direction, route/API ownership, data contracts, runtime entry points, jobs, scripts, or integration boundaries
- widening health thresholds or excluding complex areas from health checks
- deciding whether production-only analysis is appropriate

Fallback if `architecture-standards` is unavailable: apply the same checks directly. Identify the owner, public boundary, dependency direction, bypass paths, enforcement mechanism, and verification before changing config or code.

Architecture governance should result in a concrete decision: fix at the owning boundary, model an intentional exception, add enforcement, or defer with a reason. Avoid turning architecture standards into general cleanup commentary.

## Implementation Governance

When fixing Fallow findings, use a governed remediation loop:

1. Group findings by root cause, owner, and blast radius.
2. Decide the remediation mechanism: delete/refactor code, move logic to the owning boundary, model public/runtime intent in config, add a narrow suppression, or defer.
3. For architecture-sensitive changes, apply `architecture-standards` when available before editing so fixes do not create new coupling, bypasses, or shared abstractions without ownership. If unavailable, do the same ownership and boundary reasoning inline.
4. Keep each batch reviewable: name the files/packages touched, the invariant restored, and the expected Fallow delta.
5. Run focused Fallow commands for the batch, then run the baseline signal set before declaring the batch complete.
6. Update `.audits/fallow.md` with the batch result, exceptions added, verification output, unresolved findings, and follow-up order.

Do not apply `fallow fix --yes` as a blind cleanup. Use `fix --dry-run` first, review the proposed removals/edits against architecture and public API intent, then apply only the safe subset or ask for confirmation when scope is ambiguous.

## Optional Runtime Intelligence

Use runtime intelligence only when the user wants execution evidence or the repo can produce coverage that represents real usage. Do not activate a trial or configure coverage as a default adoption step.

Commands:

```bash
npx fallow license activate --trial --email you@company.com
npx fallow coverage setup
npx fallow health --runtime-coverage ./coverage --format json
```

Before setup, identify the coverage source, whether it is test-only or production-like, and which packages/apps it represents. In reports, distinguish static dead-code candidates from code that is unexecuted in the provided runtime evidence.

## CI and Baselines

Use `fallow audit` after repo policy exists. Rollout options:

- Warn-only: config rules as `warn`; useful early but needs a promotion date.
- Baseline existing debt: save baselines and fail only on new issues.
- Blocking gate: use only when current policy is clean enough to avoid noisy failures.

Baseline commands:

```bash
fallow dead-code --save-baseline fallow-baselines/dead-code.json
fallow health --save-baseline fallow-baselines/health.json
fallow dupes --save-baseline fallow-baselines/dupes.json
```

Keep committed baselines outside `.fallow/`, usually `fallow-baselines/`. Regenerate intentionally, not on every merge.

## Triage With Architecture Standards

Use `architecture-standards` when a Fallow finding touches:

- public package exports or shared package boundaries
- imports that cross app/domain/data/infrastructure layers
- duplicated logic between apps or between app and shared package
- route/API/server action ownership
- generated types, database clients, or persistence contracts
- runtime-loaded modules, scripts, jobs, queues, or integrations
- health hotspots in auth, data integrity, async workflows, public APIs, or operational code

Implementation rule: fix at the owning boundary. Do not move code to `shared` solely because two files look similar; shared abstractions need a stable invariant and ownership.

## Audit Report Shape

When documenting a Fallow assessment in `.audits/fallow.md`, include:

- scope and date
- commands run and whether outputs were JSON/plain text
- inferred run state and the evidence for it
- Fallow version when available
- config state: none, generated, modified, existing, or needs review
- optional branches considered: runtime, CI, baselines, boundaries, MCP/agent setup
- category counts for dead code, duplication, health, audit, and fix preview
- top findings by risk, not just count
- high-confidence cleanup items
- architecture-sensitive items needing design judgement
- exceptions added or recommended, with reason and mechanism
- rerun comparison: new, resolved, accepted, still-open, stale suppressions
- verification commands and gaps
- next remediation order

Do not call the repo clean unless Fallow passes under the chosen policy and the repo-audit clean gates are satisfied for the stated scope.

---
name: fallow
description: >-
  Use when adopting, configuring, running, rerunning, or interpreting Fallow
  for TypeScript/JavaScript codebase intelligence: dead code, duplication,
  health/complexity, fix previews, architecture boundaries, CI audit gates,
  baselines, or Fallow-backed repo audits. Trigger when the
  user mentions Fallow, `npx fallow`, `fallow init`, `fallow audit`, unused
  exports/dependencies/files, duplication analysis, code health hotspots,
  or wants a repeatable Fallow assessment workflow.
---

# Fallow

Use Fallow as a static-analysis signal source, then apply repo-aware judgement before changing code or policy. Fallow finds candidates; Codex decides whether to fix code, model an intentional exception in config, add a narrow suppression, or defer with a documented reason.

This skill must use only the free Fallow CLI and free Fallow features. Do not activate, configure, require, or rely on trial, paid, licensed, hosted, or pro Fallow features.

## Operating Rules

- Free version only. If a command requires a Fallow license or trial activation, stop, report that it is outside this skill's allowed scope, and continue with free static-analysis signals where possible.
- Prefer full-repo adoption commands before PR-gate commands. `fallow audit` / `npx fallow --ci` is for changed-file enforcement after the repo policy exists.
- For agent consumption, prefer `--format json --quiet --explain` where supported. Use human output only for summaries intended for people.
- Treat exit code `1` as "findings reported" and exit code `2` as a tool/config/runtime error. Preserve structured JSON from finding-producing commands instead of stopping at shell failure.
- When running Fallow in shell automation, keep stderr separate from JSON stdout. Do not parse mixed human/progress output.
- Always run destructive or auto-fix operations as preview first: `npx fallow fix --dry-run --yes --format json --quiet`.
- Do not blindly accept generated config or broad suppressions. Review entries, ignores, public packages, thresholds, and baselines against the repository shape.
- Use `fallow schema`, `fallow config`, and `fallow list` as capability/introspection tools. Do not assume package scripts expose the whole analyzer surface.
- Select the analysis mode by question. Changed-file, production, semantic-duplicate, entry-export, free coverage-gap, and baseline modes intentionally mean different things. Licensed runtime intelligence and runtime-coverage modes are out of scope.
- Parse the `actions` arrays on findings as suggestions, not instructions. Evaluate each action against repo ownership, runtime entry points, public API contracts, and verification needs.
- Determine run state from evidence. Missing `.audits/` files do not mean first adoption if config, baselines, package installation, CI hooks, or `.fallow/` artifacts exist.
- On later reruns, treat existing Fallow config, baselines, package scripts, CI hooks, and audit records as current policy/history. Focus on new regressions, stale exceptions, policy drift, and changed hotspots.
- When available, use `repo-audit` as the governance and documentation layer for repo-level assessments. If it is unavailable, still create a concise Fallow assessment record with the same core fields.
- When available, use `architecture-standards` whenever Fallow findings, config policy, or remediation touches ownership, boundaries, public APIs, shared packages, duplication abstractions, data/API contracts, runtime entry points, or hotspot refactors. If it is unavailable, apply the same boundary/ownership checks directly.
- If Fallow reveals widespread duplication, health hotspots, large-file pressure, or advisory inventories after an architecture pass, treat that as evidence the current-state diagnosis or target-state design was incomplete. Do not reduce the response to warning cleanup.
- For implementation work, prefer `architecture-standards` to decide the owning boundary and `repo-audit` to record fix batches, accepted exceptions, verification, and remaining risk, but do not block if those skills are unavailable.
- Before declaring a remediation complete, check for second-order regressions Fallow campaigns often create: test-only exports in production modules, stale coverage artifacts, duplicate test assertions, helper buckets without owners, and public contract key drift after route/helper extraction.
- Never run `fallow watch` in an agent turn; it is interactive and does not exit.

## Workflow

1. **Preflight**
   - Check for Fallow installation in package dependencies, lockfiles, package scripts, local binaries, and CI workflows before using `npx`.
   - Check for `.fallowrc.json`, `.fallowrc.jsonc`, `fallow.toml`, `.fallow.toml`, `fallow-baselines/`, `.fallow/`, `.audits/`, package manager, workspaces, framework entry points, and test/coverage scripts.
   - Discover the active analyzer surface when Fallow is present: `fallow schema`, `fallow config`, `fallow list --plugins --entry-points --boundaries`, and `fallow config-schema` when policy shape matters.
   - Check whether `repo-audit` and `architecture-standards` skills are available in the current environment before relying on them.
   - Classify the run as first adoption, configured-without-history, rerun-with-history, CI/audit-only, or remediation pass. If signals conflict, explain the inferred state and proceed conservatively.
   - If the user is only asking to build or discuss the workflow, do not install or run Fallow.
   - Do not run `fallow license activate`, trial setup, hosted setup, paid feature setup, or licensed runtime-coverage setup under this skill.
   - If Fallow must run and is locally installed, prefer the repo's package script, `pnpm exec fallow`, or the package manager equivalent. Use `npx --yes fallow ...` only when Fallow is not already available and normal tool/network approval allows it.

2. **Baseline Signal Set**
   - First adoption and broad reruns normally collect:
     - `npx fallow --format json --quiet --explain`
     - `npx fallow dead-code --format json --quiet --explain`
     - `npx fallow dupes --format json --quiet --explain`
     - `npx fallow health --format json --quiet --explain`
     - `npx fallow fix --dry-run --yes --format json --quiet`
   - Add focused commands only when the question warrants it and the command is available without a license, such as `dead-code --trace-file`, `dead-code --trace-dependency`, `dead-code --production`, `dead-code --include-entry-exports`, `dupes --mode semantic`, `health --hotspots`, `health --file-scores`, `health --coverage-gaps`, `flags`, `list --entry-points`, `list --boundaries`, or `audit --format json`.
   - Keep blocking gates separate from advisory inventories. A clean gate does not erase semantic duplicates, hotspots, coverage gaps, production-only drift, or feature-flag lifecycle work.

3. **Config Decision**
   - If no config exists and the task is adoption or policy setup, run `npx fallow init` after collecting the first signal set, then review the generated config.
   - Encode repo policy in config for real entry points, generated/vendored files, public packages, dynamic runtime entry points, intentional runtime dependencies, duplication thresholds, health thresholds, audit gate, production mode, workspaces, and boundaries.
   - Apply `architecture-standards` if available before adding boundary rules, public package policy, shared-package exceptions, production-only scope, or broad thresholds. If unavailable, explicitly reason through ownership, public API, dependency direction, and enforcement before changing config.
   - Keep exceptions narrow. Prefer config or visibility tags over repeated inline comments. Use inline suppression only for true one-off false positives.

4. **Triage Order**
   - Clear high-confidence issues first: unresolved imports, unlisted dependencies, unused files after entry-point sanity checks, then unused dependencies.
   - Use trace commands before deletion or suppression when static reachability is ambiguous.
   - Triage unused exports/types/class members by deciding whether each is dead code, public API, dynamic entry, compatibility shim, generated code, or false positive.
   - Consolidate duplication only when it reduces real maintenance risk. Avoid extracting abstractions that blur ownership or increase coupling.
   - Use `health` hotspots, file scores, and targets to prioritize review and refactoring. Do not chase every advisory candidate; preserve the distinction between gate failures and planning signals.
   - Use feature-flag findings to ask lifecycle questions: owner, default, environments, cleanup trigger, rollout risk, and verification.
   - For widespread structural findings, identify the current-state failure mode and the missing target-state rule before changing code: unclear owner, scattered policy, weak public boundary, mixed responsibility module, unowned contract, or missing fitness function.
   - Use `architecture-standards` if available for any triage item whose fix would change module placement, shared abstractions, contracts, state ownership, or public/runtime entry points. If unavailable, apply those checks directly and document the decision.

5. **Implementation Governance**
   - Before fixing, group findings by root cause and owning boundary rather than editing one warning at a time.
   - Prefer code fixes for real issues, config modeling for intentional repo policy, and narrow inline suppressions only for one-off false positives.
   - For each fix batch, state the invariant being restored, the files or package boundary that owns it, and the verification command that will prove it.
   - Rerun focused Fallow commands after each meaningful batch, then rerun the baseline signal set before calling the remediation complete.
   - If a health or coverage-gap command reports that it requires a license, stop using that branch and record the scope gap.
   - If tests import new production helpers, rerun production dead-code to ensure the helpers are real owner-local production surfaces, not test-only exports.
   - If tests were added during zero-duplication work, rerun full duplication after the tests too; duplicated assertions and setup still count under a full zero policy.
   - For broad remediation branches, keep an owner/batch ledger with command evidence and changed public contracts. Prefer smaller owner-owned PRs when possible; if one large PR is necessary, do not rely on hosted diff UI as the only review surface.

6. **Optional Branches**
   - Licensed runtime intelligence and runtime-coverage setup are out of scope. Do not activate a trial or use licensed coverage features.
   - CI/PR gate: only after the repo has a policy and the team has chosen warn, baseline, or blocking rollout.
   - Baselines: use for existing debt when CI needs to block only new issues; store committed baselines outside `.fallow/`.
   - Boundaries: use when the repo has clear architecture zones or import direction rules worth enforcing.
   - MCP/agent setup: use when the user wants structured tool integration beyond shell commands.

7. **Documentation**
   - For a real assessment, write or update `.audits/fallow.md` using `repo-audit` conventions when available; otherwise use the report shape in `references/fallow-workflows.md`. If the file was deleted or missing, recreate it from current evidence and note history is unavailable.
   - Record run-state evidence, free-version constraint, command set, Fallow version when available, config state, blocking gates, advisory inventories, exceptions and reasons, highest-risk findings, remediation order, verification, and residual risk.
   - Preserve enough state for later comparison: config summary, category counts, top findings, and optional raw JSON locations when useful.
   - On reruns, prepend a new turn and compare against previous Fallow state when available: new, resolved, accepted, deferred, deployment-gated, inventory-only, stale suppression, and policy-drift findings.

## References

- Load `references/fallow-workflows.md` when you need concrete command recipes, config mechanisms, rerun behavior, optional CI setup, or report structure.
- Load `references/analysis-primitives.md` when you need to choose the right Fallow lens, interpret output semantics, or translate analyzer evidence into review/audit/architecture decisions.
- Load `references/package-internals.md` when package behavior, wrapper errors, MCP/LSP/Node surfaces, bundled skill guidance, or version-specific capability discovery matters.
- Load `references/quality-benchmarks.md` when hardening review/audit/spec skills, calibrating whether a skill would have caught structural debt, or checking negative all-clear cases.

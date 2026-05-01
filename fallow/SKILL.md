---
name: fallow
description: >-
  Use when adopting, configuring, running, rerunning, or interpreting Fallow
  for TypeScript/JavaScript codebase intelligence: dead code, duplication,
  health/complexity, fix previews, runtime coverage, architecture boundaries,
  CI audit gates, baselines, or Fallow-backed repo audits. Trigger when the
  user mentions Fallow, `npx fallow`, `fallow init`, `fallow audit`, unused
  exports/dependencies/files, duplication analysis, code health hotspots,
  runtime coverage, or wants a repeatable Fallow assessment workflow.
---

# Fallow

Use Fallow as a static-analysis signal source, then apply repo-aware judgement before changing code or policy. Fallow finds candidates; Codex decides whether to fix code, model an intentional exception in config, add a narrow suppression, or defer with a documented reason.

## Operating Rules

- Prefer full-repo adoption commands before PR-gate commands. `fallow audit` / `npx fallow --ci` is for changed-file enforcement after the repo policy exists.
- Always run destructive or auto-fix operations as preview first: `npx fallow fix --dry-run --format json`.
- Do not blindly accept generated config or broad suppressions. Review entries, ignores, public packages, thresholds, and baselines against the repository shape.
- Determine run state from evidence. Missing `.audits/` files do not mean first adoption if config, baselines, package installation, CI hooks, or `.fallow/` artifacts exist.
- On later reruns, treat existing Fallow config, baselines, package scripts, CI hooks, and audit records as current policy/history. Focus on new regressions, stale exceptions, policy drift, and changed hotspots.
- When available, use `repo-audit` as the governance and documentation layer for repo-level assessments. If it is unavailable, still create a concise Fallow assessment record with the same core fields.
- When available, use `architecture-standards` whenever Fallow findings, config policy, or remediation touches ownership, boundaries, public APIs, shared packages, duplication abstractions, data/API contracts, runtime entry points, or hotspot refactors. If it is unavailable, apply the same boundary/ownership checks directly.
- For implementation work, prefer `architecture-standards` to decide the owning boundary and `repo-audit` to record fix batches, accepted exceptions, verification, and remaining risk, but do not block if those skills are unavailable.

## Workflow

1. **Preflight**
   - Check for Fallow installation in package dependencies, lockfiles, package scripts, local binaries, and CI workflows before using `npx`.
   - Check for `.fallowrc.json`, `.fallowrc.jsonc`, `fallow.toml`, `.fallow.toml`, `fallow-baselines/`, `.fallow/`, `.audits/`, package manager, workspaces, framework entry points, and test/coverage scripts.
   - Check whether `repo-audit` and `architecture-standards` skills are available in the current environment before relying on them.
   - Classify the run as first adoption, configured-without-history, rerun-with-history, CI/audit-only, or remediation pass. If signals conflict, explain the inferred state and proceed conservatively.
   - If the user is only asking to build or discuss the workflow, do not install or run Fallow.
   - If Fallow must run and is locally installed, prefer the repo's package script, `pnpm exec fallow`, or the package manager equivalent. Use `npx --yes fallow ...` only when Fallow is not already available and normal tool/network approval allows it.

2. **Baseline Signal Set**
   - First adoption and broad reruns normally collect:
     - `npx fallow --format json`
     - `npx fallow dead-code --format json`
     - `npx fallow dupes --format json`
     - `npx fallow health --format json`
     - `npx fallow fix --dry-run --format json`
   - Add focused commands only when the result warrants it, such as `dead-code --unresolved-imports`, `--unlisted-deps`, `--unused-files`, `--unused-deps`, `dupes --mode semantic`, `list --entry-points`, or `audit --format json`.

3. **Config Decision**
   - If no config exists and the task is adoption or policy setup, run `npx fallow init` after collecting the first signal set, then review the generated config.
   - Encode repo policy in config for real entry points, generated/vendored files, public packages, dynamic runtime entry points, intentional runtime dependencies, duplication thresholds, health thresholds, audit gate, production mode, workspaces, and boundaries.
   - Apply `architecture-standards` if available before adding boundary rules, public package policy, shared-package exceptions, production-only scope, or broad thresholds. If unavailable, explicitly reason through ownership, public API, dependency direction, and enforcement before changing config.
   - Keep exceptions narrow. Prefer config or visibility tags over repeated inline comments. Use inline suppression only for true one-off false positives.

4. **Triage Order**
   - Clear high-confidence issues first: unresolved imports, unlisted dependencies, unused files after entry-point sanity checks, then unused dependencies.
   - Triage unused exports/types/class members by deciding whether each is dead code, public API, dynamic entry, compatibility shim, generated code, or false positive.
   - Consolidate duplication only when it reduces real maintenance risk. Avoid extracting abstractions that blur ownership or increase coupling.
   - Use `health` hotspots to prioritize refactors. Do not chase every file above average; focus on functions above policy thresholds or high-change/high-risk areas.
   - Use `architecture-standards` if available for any triage item whose fix would change module placement, shared abstractions, contracts, state ownership, or public/runtime entry points. If unavailable, apply those checks directly and document the decision.

5. **Implementation Governance**
   - Before fixing, group findings by root cause and owning boundary rather than editing one warning at a time.
   - Prefer code fixes for real issues, config modeling for intentional repo policy, and narrow inline suppressions only for one-off false positives.
   - For each fix batch, state the invariant being restored, the files or package boundary that owns it, and the verification command that will prove it.
   - Rerun focused Fallow commands after each meaningful batch, then rerun the baseline signal set before calling the remediation complete.

6. **Optional Branches**
   - Runtime intelligence: only when coverage exists or the user wants production execution evidence. Use the runtime workflow in `references/fallow-workflows.md`.
   - CI/PR gate: only after the repo has a policy and the team has chosen warn, baseline, or blocking rollout.
   - Baselines: use for existing debt when CI needs to block only new issues; store committed baselines outside `.fallow/`.
   - Boundaries: use when the repo has clear architecture zones or import direction rules worth enforcing.
   - MCP/agent setup: use when the user wants structured tool integration beyond shell commands.

7. **Documentation**
   - For a real assessment, write or update `.audits/fallow.md` using `repo-audit` conventions when available; otherwise use the report shape in `references/fallow-workflows.md`. If the file was deleted or missing, recreate it from current evidence and note history is unavailable.
   - Record run-state evidence, command set, Fallow version when available, config state, exceptions and reasons, highest-risk findings, remediation order, verification, and residual risk.
   - Preserve enough state for later comparison: config summary, category counts, top findings, and optional raw JSON locations when useful.
   - On reruns, prepend a new turn and compare against previous Fallow state when available: new, resolved, accepted, still-open, stale suppression, and policy-drift findings.

## References

- Load `references/fallow-workflows.md` when you need concrete command recipes, config mechanisms, rerun behavior, optional runtime/CI setup, or report structure.

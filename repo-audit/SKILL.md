---
name: repo-audit
description: Run a full codebase audit covering bugs, security, architecture, performance, operability, refactoring opportunities, tech debt, external findings, and escaped bug patterns — with root cause analysis, codebase-aware context, repo-total re-audit, invariant/variant proof, and iterative turn-based tracking. Use this skill whenever the user asks to audit a repo, review the whole codebase, assess code quality, find tech debt, do a health check, perform security/performance/architecture review, or wants the full picture beyond a single diff.
---

# Repo Audit

Audit the current repository state like a senior production-risk and architecture reviewer. The goal is to identify meaningful correctness, security, operability, architecture, performance, and maintainability risks, then provide a prioritized remediation path.

Use progressive disclosure: keep this file as the operating router, and load focused references only when needed.

## Reference Map

- `scripts/audit-preflight.sh`: collect repo shape, branch/PR context, existing audits/reviews, hotspots, risky surfaces, and candidate verification commands.
- `references/audit-workflow.md`: full audit/re-audit workflow and repo-context gathering.
- `references/audit-gates.md`: clean-bill bar, risk scoring, invariant/variant gates, resolution gate, challenger pass, confidence penalties.
- `references/audit-archetypes.md`: contract/shared-ui/optimistic/fallback/security/migration/architecture/performance checklists.
- `references/audit-finding-format.md`: finding types, severity, RCA, impact, solution options, remediation radius, prevention artifacts.
- `references/audit-file-format.md`: `.audits/{scope}.md` header and turn format.
- `references/verification-guidance.md`: risk-based test/check expectations and test adequacy.
- `references/static-analysis.md`: use when the repo has static analyzer tooling, Fallow/Knip/jscpd/dependency tools, duplication/refactor reports, quality gates, baselines, suppressions, coverage reports, or analyzer-backed audit artifacts.
- `fallow` skill references `analysis-primitives.md` and `quality-benchmarks.md`: use when Fallow is installed/configured or when audit conclusions depend on analyzer evidence quality.
- `references/bug-class-taxonomy.md`: reusable classes for external findings and repeated misses.
- `references/external-finding-import.md`: normalize GitHub/Devin/CI/security/user findings.
- `references/miss-retrospective-template.md`: learn from missed audit findings.
- `references/escaped-audit-benchmarks.md` and `references/benchmark-scoring.md`: calibrate the process against known miss patterns.
- `references/all-clear-antipatterns.md`: anti-patterns to check before saying healthy/clean.
- `references/severity-calibration.md`: rank hidden workflow/data/compatibility/partial-failure/architecture risks.
- `references/architecture-review-bridge.md`: decide when to invoke `architecture-standards`.
- Stack references: load relevant framework/language files from `references/` when the detected stack requires it.

## Core Workflow

1. Run `scripts/audit-preflight.sh` when risk/context warrants it.
2. Read all `.audits/*.md`; they are the authoritative audit history.
3. Scan relevant `.reviews/*.md` when review history may contain escaped-finding or hotspot context.
4. Determine scope: full codebase by default unless user requested a focused audit.
5. Detect repo shape, stack, entry points, config, data/schema, auth, jobs, integrations, tests, and deployment.
6. If static analyzer tooling or reports exist, load `references/static-analysis.md` and build an analyzer evidence map: gates, advisory inventories, duplication/refactor architecture signals, config policy, baselines, suppressions, trend signals, and residual evidence. If Fallow is installed or configured, preserve its mode semantics: changed-only, production, full inventory, configured gate, semantic duplication, and baseline views are separate audit evidence.
7. For architecture audits or messy-repo remediation, load `references/architecture-review-bridge.md` and score current-state fitness and target-state design together.
8. Assign health rating, risk score, and audit archetype tags.
9. Build repo-total audit maps for high-risk capabilities and shared surfaces.
10. Trace code paths deeply enough to understand invariants, ownership, callers, consumers, bypass paths, and operational impact.
11. Apply invariant/variant proof for Medium+ risk.
12. Triage external findings against the current tree before fixing or clearing them.
13. When external PR analysis or post-audit feedback finds a miss, import it into the audit ledger, classify the missed lens, and update prevention rules or skill guidance when the miss is systemic.
14. For large remediation branches, audit by local repo state and owner/capability batches. Treat hosted PR diff limits as an evidence gap to compensate for, not a reason to skip branch-total review.
15. Run verification appropriate to risk.
16. Write or update `.audits/{scope}.md`.
17. Do not give a clean conclusion unless `audit-gates.md` is satisfied.

## Auditor Stance

- Start from system shape, user/business journeys, data sensitivity, and failure consequences.
- Treat auth/tenancy, data integrity, contracts, migrations, async work, public APIs, shared abstractions, and deployment/infra as high-risk by default.
- Do not stop at surface files; trace callers, consumers, shared types, schemas, config, jobs, scripts, tests, and operational side effects.
- Score target-state design against current-state evidence. A plausible architecture direction is weak if duplication, hotspots, bypasses, module budgets, or analyzer policy show the repo cannot actually hold it.
- Treat monolithic components/functions, test-only production exports, stale analyzer evidence, and public contract key drift as architecture/audit signals, not just local cleanup issues.
- Treat oversized remediation PRs as reviewability risk. Prefer future work split by owner/capability; when a single branch is necessary, require a batch ledger, branch-total diff review, and external-review monitoring evidence.
- Separate must-fix risks from broad refactor preferences.
- If the audit is partial, say exactly what remains unreviewed.

## Mandatory Gates

Load `audit-gates.md` when any of these apply:

- Medium+ risk
- Turn 2+ re-audit
- external findings are supplied
- previous false clean conclusion or escaped finding exists
- large remediation branch, broad refactor campaign, or hosted PR diff limitation exists
- broad UI/presentation refactor changed layout, navigation, dialogs, menus, empty states, or shared primitives
- shared contract, auth, data integrity, migration, async, fallback, optimistic state, architecture boundary, public API, or infra changed

Before clean conclusion:

- repo-total current state was reassessed
- every high-risk area in scope was reviewed
- high-risk connected paths were traced
- hotspot ledger was checked
- static analyzer gates, advisory inventories, duplication/refactor signals, and policy drift were reviewed or explicitly scoped out
- Fallow evidence, when available, is quantified with gate/inventory/mode separation, CI parity, accepted-debt records, and stale-evidence checks
- relevant verification ran or gaps are explicit
- no open Critical/High findings remain in scope
- weakest invariant/variant has direct evidence
- challenger pass completed for High/Critical risk
- `all-clear-antipatterns.md` does not expose weak proof

## External Findings

When the user pastes GitHub/Devin/CI/security/user findings:

1. Load `external-finding-import.md`.
2. Classify each as `live`, `already fixed`, `stale`, `intentional`, or `needs confirmation`.
3. Load `bug-class-taxonomy.md` and assign bug classes.
4. If a prior audit should have caught it, load `miss-retrospective-template.md`.
5. Search sibling/bypass paths for repeated live classes.
6. If the finding exposes a repeatable audit miss, update the audit file with the missed lens and prevention artifact; recommend skill/process updates when the same miss could recur across repos.

Do not call a finding stale because line numbers moved; inspect current behavior.

## Audit File Discipline

Use `audit-file-format.md`.

- One audit file per audit scope.
- Newest turn first.
- Header tracks project context, scope, hotspots, status, and findings summary.
- Each turn states outcome, health, risk, archetypes, confidence, coverage, triage, bug classes/invariants, repo totality, sibling closure, remediation impact, validation, residual risk, and recommendations.
- Findings keep stable IDs forever.

## Final Output To User

Be direct:

- If findings exist, lead with the highest-severity issues and concrete file/line references.
- If clean in scope, state what was audited and what verification passed.
- If partial, name unreviewed subsystems, weak evidence, and next checks.
- Do not present broad repo health if the scope or verification was narrow.

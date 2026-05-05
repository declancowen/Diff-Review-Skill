---
name: diff-review
description: Review local git diffs for bugs, security issues, regressions, external findings, and code quality before pushing to origin — with root cause analysis, codebase-aware context, branch-total re-review, invariant/variant proof, and iterative turn-based tracking. Use this skill whenever the user asks to review a diff, check changes before pushing, review staged changes, compare branches, run a pre-PR review, re-review after fixes, check review status, triage GitHub/Devin/CI findings, or says things like "review my changes", "check my diff", "what did I break", "run the review again", or "did I fix the issues".
---

# Diff Review

Review current code changes like a senior production-risk reviewer, not a linter. The goal is to find meaningful bugs, security issues, regressions, compatibility gaps, and risky architecture drift before changes reach origin.

Use progressive disclosure: keep this file as the operating router, and load focused references only when needed.

## Reference Map

- `scripts/review-preflight.sh`: collect branch, PR, changed files, review history, hotspots, and candidate verification commands.
- `references/review-workflow.md`: full review/re-review workflow and code-context gathering.
- `references/review-gates.md`: all-clear bar, risk scoring, invariant/variant gates, resolution gate, challenger pass, confidence penalties.
- `references/review-archetypes.md`: contract/shared-ui/optimistic/fallback/security/migration/performance checklists.
- `references/finding-format.md`: finding types, severity, RCA, impact, solution options, remediation radius, prevention artifacts.
- `references/review-file-format.md`: `.reviews/{content-area}.md` header and turn format.
- `references/verification-guidance.md`: risk-based test/check expectations and test adequacy.
- `references/static-analysis.md`: use when a diff touches static analyzer findings, Fallow/Knip/jscpd/dependency tools, duplication, refactors, module boundaries, suppressions, quality gates, or analyzer-backed audit/review artifacts.
- `fallow` skill references `analysis-primitives.md` and `quality-benchmarks.md`: use when Fallow is installed/configured or when analyzer evidence affects all-clear confidence.
- `references/bug-class-taxonomy.md`: reusable classes for external findings and repeated misses.
- `references/external-finding-import.md`: normalize GitHub/Devin/CI/user findings.
- `references/miss-retrospective-template.md`: learn from missed review findings.
- `references/escaped-review-benchmarks.md` and `references/benchmark-scoring.md`: calibrate the process against known miss patterns.
- `references/all-clear-antipatterns.md`: anti-patterns to check before saying all clear.
- `references/severity-calibration.md`: rank hidden workflow/data/compatibility/partial-failure risks.
- `references/architecture-review-bridge.md`: decide when to invoke `architecture-standards`.
- Stack references: load relevant framework/language files from `references/` when the detected stack requires it.

## Core Workflow

1. Run `scripts/review-preflight.sh` when risk/context warrants it.
2. Read all `.reviews/*.md`; they are the authoritative turn history.
3. Determine the review target: local working changes first, explicit PR/review context second, branch-vs-base third.
4. Establish intended change from user request, PR/issue/commit context, and changed files.
5. Assign risk score and change archetype tags.
6. If static analyzer policy or artifacts exist, load `references/static-analysis.md` and interpret duplication/refactor findings through ownership, invariant, and transition-state lenses. If Fallow is installed or configured, also preserve Fallow mode semantics from the `fallow` skill: changed-only, production, full inventory, configured gate, semantic duplication, and baseline views are distinct evidence.
7. If the diff claims architecture remediation, load `references/architecture-review-bridge.md` and review both the current-state problem being reduced and the target-state rule being strengthened.
8. Review current-turn delta and cumulative branch state.
9. Read changed files fully, then trace callers, consumers, shared types, schemas, config, tests, and bypass paths.
10. Apply invariant/variant proof for Medium+ risk.
11. Triage external findings against the current tree before fixing or clearing them.
12. For large PRs, treat hosted diff views as advisory when they are truncated, delayed, or awkward to inspect. Use local branch-vs-base diff, changed-file lists, and owner/batch ledgers as the review source of truth; use GitHub for comments, threads, checks, and latest-SHA state.
13. For PR-analysis loops, do not trigger duplicate automated reviews while one is already acknowledged or running; poll comments, review threads, and checks, then act only on new feedback.
14. Run verification appropriate to risk.
15. Write or update `.reviews/{content-area}.md`.
16. Do not give all-clear unless `review-gates.md` is satisfied.

## Reviewer Stance

- Start by understanding intent, then review for unintended behavior.
- Treat shared abstractions, contracts, state reconciliation, auth/tenancy, migrations, async work, and public APIs as high-risk by default.
- Never treat a fix as isolated to edited lines; check callers, consumers, shared types, state transitions, persistence, config, tests, and adjacent error paths.
- Prefer findings that reduce production/user/data/security risk over noisy style comments.
- For architecture-remediation diffs, require evidence that the change improves a named current-state failure mode and moves toward a specific target-state design. Warning-count reduction is not enough.
- For analyzer-driven refactors, require a final production dead-code sweep as well as full dead-code, duplication, and health checks; coverage-first work can accidentally create test-only production exports.
- For route/API/auth/storage contract changes, assert the serialized public contract, not just internal helper options or happy-path behavior.
- For broad UI/presentation refactors, require browser or visual smoke on representative changed screens unless the review explicitly scopes that risk out.
- If the review is partial, say exactly what remains unreviewed.

## Mandatory Gates

Load `review-gates.md` when any of these apply:

- Medium+ risk
- Turn 2+ re-review
- external findings are supplied
- previous false all-clear or escaped finding exists
- large PR, broad remediation branch, or hosted diff tooling limitation exists
- broad UI/presentation refactor changed layout, navigation, dialogs, menus, empty states, or shared primitives
- shared contract, auth, data integrity, migration, async, fallback, optimistic state, or public API changed

Before all-clear:

- branch-total current state was reassessed
- every changed file in scope was reviewed
- high-risk connected paths were traced
- hotspot ledger was checked
- relevant static analyzer gates, advisory inventories, duplication/refactor signals, and policy drift were parsed or explicitly scoped out
- Fallow evidence, when available, is scope-safe: changed-file audit, production gate, full advisory inventory, CI parity, accepted debt, and stale evidence are separated before any clean conclusion
- relevant verification ran or gaps are explicit
- no open Critical/High findings remain
- weakest invariant/variant has direct evidence
- challenger pass completed for High/Critical risk
- `all-clear-antipatterns.md` does not expose weak proof

## External Findings

When the user pastes GitHub/Devin/CI/user findings:

1. Load `external-finding-import.md`.
2. Classify each as `live`, `already fixed`, `stale`, `intentional`, or `needs confirmation`.
3. Load `bug-class-taxonomy.md` and assign bug classes.
4. If a prior review should have caught it, load `miss-retrospective-template.md`.
5. Search sibling/bypass paths for repeated live classes.
6. If the source is an automated PR review, resolve outdated threads only after the fix is pushed or current-tree proof exists, the thread is actually obsolete, and the review file records the resolution evidence. Do not spam review triggers while the reviewer is still busy.

Do not call a finding stale because line numbers moved; inspect current behavior.

## Review File Discipline

Use `review-file-format.md`.

- One review file per content area.
- Newest turn first.
- Header tracks scope, hotspots, status.
- Each turn states outcome, risk, archetypes, confidence, coverage, triage, bug classes/invariants, branch totality, sibling closure, remediation impact, validation, residual risk, and recommendations.
- Findings keep stable IDs forever.

## Final Output To User

Be direct:

- If findings exist, list them first by severity with file/line references.
- If clean, state what was checked and what verification passed.
- If partial, name the unreviewed paths and why confidence is limited.
- Do not hide serious residual risk behind a broad "looks good".

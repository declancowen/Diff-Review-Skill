# Review Gates

Use this before concluding a diff review, especially for medium/high-risk branches.

## All-Clear Bar

Do not say "all clear" unless:

- intended change is understood and diff matches it
- every changed file in scope was reviewed
- high-risk connected paths were traced far enough
- relevant checks were run or missing verification is explicitly accepted as low risk
- no open Critical or High findings remain
- residual uncertainty is minor enough to ship defensibly

For Medium+ risk, also read `all-clear-antipatterns.md`.

## Risk Score

- **Low:** localized change, small blast radius, strong direct coverage, easy rollback.
- **Medium:** multiple files/flows, moderate shared-surface impact, some uncertainty.
- **High:** shared abstractions, contracts, auth/data integrity, migrations, concurrency, broad blast radius.
- **Critical:** money, permissions, destructive data paths, one-way transforms, infra toggles, severe failure consequences.

Expected review depth:

- Low: targeted review and targeted verification.
- Medium: full flow tracing, targeted verification, safety-net checks.
- High: full flow tracing, broader verification, compatibility/release-safety review, challenger pass.
- Critical: strongest available verification, explicit residual risks, challenger pass.

Use `severity-calibration.md` for ambiguous or externally supplied findings.

## Invariant-First Gate

For meaningful shared UI, contract, persistence, optimistic-state, batch-operation, or fallback-path changes, identify:

- authority: who owns IDs/defaults/validation/permissions/timestamps/persisted values
- preservation: what fields/relationships must not change
- state variants: empty, legacy-invalid, read-only/editable, parent/child, filtered/grouped, duplicate labels
- interaction variants: click, keyboard, menu, modal, inline editor, autosave/explicit save
- lifecycle: can the owner unmount before async/confirmation completes?
- identity: are keys/lookups/cache IDs unique under duplicate render/scope?
- atomicity: what happens on partial batch/fan-out failure?

For Medium+ risk, record main invariants checked. For High/Critical risk, attack the weakest invariant directly.

## Variant Matrix

Build a small matrix when a shared component, selector, helper, dialog, menu, or store action changes:

- value: empty, populated, invalid legacy, `null`, `undefined`
- mode: editable, read-only, inline, detail, surface/list/card, create, rename/update
- scope: tenant/workspace/team/project, no scope, duplicate labels, stale/retained scope
- flow: click, keyboard, programmatic submit, optimistic submit, server failure, retry, reconciliation
- container: mounted component, menu/popover, nested dialog, route transition, fallback/skeleton, retained data

## Resolution Gate

Mark a finding resolved only when:

- root cause is addressed
- sibling/family sweep is complete
- remediation shape is coherent across the family
- impact surface was assessed across callers, consumers, dependencies, contracts, and side effects
- must-fix adjacent weaknesses are fixed, carried, or explicitly blocked
- non-primary paths were checked where plausible
- targeted verification ran
- recurrence risk was reduced with a prevention artifact or consciously ruled out
- no obvious companion change is missing

Otherwise use `Partially addressed` or `Still open`.

## Challenger Pass

Required for High/Critical reviews. Assume one serious issue remains and hunt in:

- weakest-evidence areas
- untouched dependencies
- deleted safeguards
- compatibility assumptions
- migrations/rollout paths
- tests that may create false confidence
- non-primary callers and bypass paths

## Confidence Penalties

Lower confidence when:

- sibling closure is incomplete
- only primary path was tested
- only route/UI path was reviewed for a contract bug
- non-primary caller audit was skipped where bypasses likely exist
- external findings were not current-tree triaged
- branch-totality was not reassessed on Turn 2+
- hotspot ledger was not checked
- adjacent resolved findings were not revalidated after nearby change

## Final Self-Audit

Before "no findings" or "all clear", answer:

- what serious issue could still be missing?
- which bug class is most represented by this branch?
- which assumption matters most?
- which high-risk path has weakest evidence?
- which sibling surface could still carry the same bug?
- which state variant was least checked?
- if this caused an incident tomorrow, where would you investigate first?

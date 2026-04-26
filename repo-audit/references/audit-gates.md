# Audit Gates

Use this before concluding a repo audit or re-audit.

## Clean-Bill Bar

Do not say "healthy" or "clean in audited scope" unless:

- audit scope is understood and actually examined
- every high-risk area in scope was reviewed
- high-risk connected paths were traced far enough
- relevant checks were run or missing verification is explicitly accepted as low risk
- no open Critical or High findings remain in scope
- residual uncertainty is minor enough to call the scope healthy defensibly

For Medium+ risk, read `all-clear-antipatterns.md`.

## Risk Score

- **Low:** localized slice, small blast radius, strong direct coverage.
- **Medium:** multiple subsystems/flows, moderate shared-surface impact, some uncertainty.
- **High:** shared abstractions, contracts, auth/data integrity, migrations, concurrency, broad blast radius.
- **Critical:** money, permissions, destructive data paths, one-way transforms, infra toggles, severe consequences.

Expected audit depth:

- Low: targeted audit and targeted verification.
- Medium: full flow tracing, targeted verification, safety-net checks.
- High: full flow tracing, broader verification, compatibility/release-safety review, challenger pass.
- Critical: strongest available verification, explicit residual risks, challenger pass.

Use `severity-calibration.md` for ambiguous findings.

## Invariant-First Gate

For shared UI, contract, persistence, optimistic-state, batch-operation, fallback-path, background-job, or architecture-boundary concerns, identify:

- authority: who owns IDs/defaults/validation/permissions/retries/persisted values
- preservation: what fields/relationships/scope must not change
- state variants: empty, legacy-invalid, read-only/editable, parent/child, duplicate labels, old client/job payloads
- entrypoint variants: UI, API, direct mutation, job, script, import, webhook, migration
- lifecycle: can owner disappear before async/stream/job cleanup completes?
- identity: are keys/lookups/cache IDs unique under duplicate render/scope/imports?
- atomicity: what happens on partial batch/fan-out/job/migration failure?

For Medium+ risk, record main invariants checked. For High/Critical risk, attack the weakest invariant directly.

## Variant Matrix

Build a small matrix for shared components, selectors, helpers, routes, stores, services, workers, jobs, schemas, or boundaries:

- value: empty, populated, invalid legacy, `null`, `undefined`
- mode: editable, read-only, create, update, fallback, worker/job, migration/import
- scope: tenant/workspace/team/project/account, no scope, duplicate labels, stale/retained scope
- flow: click, API submit, programmatic submit, optimistic submit, job retry, server failure, reconciliation
- runtime: component/process, transient container, route transition, stream restart, worker restart

## Resolution Gate

Mark a finding resolved only when:

- root cause is addressed
- sibling/family sweep is complete
- remediation shape is coherent
- impact surface was assessed across callers, consumers, dependencies, contracts, operations, and side effects
- must-fix adjacent weaknesses are fixed, carried, or explicitly blocked
- non-primary/bypass paths were checked where plausible
- targeted verification ran
- recurrence risk was reduced with prevention artifact or consciously ruled out
- no obvious companion change is missing

## Challenger Pass

Required for High/Critical audits. Assume one serious issue remains and hunt in:

- weakest-evidence areas
- untouched dependencies
- deleted safeguards
- compatibility assumptions
- migrations/rollout paths
- test blind spots
- stale architecture assumptions
- non-primary callers and operational bypass paths

## Confidence Penalties

Lower confidence when:

- sibling closure is incomplete
- only primary path was tested
- only one layer was reviewed for contract/architecture bug
- non-primary caller audit was skipped where bypasses likely exist
- external findings were not current-tree triaged
- repo-total reassessment was not done on Turn 2+
- hotspot ledger was not checked
- resolved adjacent findings were not revalidated after nearby change

## Final Self-Audit

Before "no new findings" or "clean", answer:

- what serious issue could still be missing?
- which bug class is most represented by this repo/scope?
- which assumption matters most?
- which high-risk path has weakest evidence?
- which sibling subsystem could still carry the same bug?
- which state variant was least checked?
- if this caused a major incident tomorrow, where would you investigate first?

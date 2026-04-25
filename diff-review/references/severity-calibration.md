# Severity Calibration

Use this when ranking findings. Many important review misses are not crashes; they are hidden broken flows, data integrity risks, compatibility traps, or partial-success bugs.

## Critical

Use when shipping can plausibly cause:

- security breach, auth/authz bypass, tenant data exposure
- data loss, data corruption, duplicate authoritative IDs, irreversible destructive action
- payment/billing/entitlement error with real user or financial impact
- migration/backfill failure that can lock, corrupt, or irreversibly transform production data
- production outage or deployment break with no safe rollback

## High

Use when shipping can plausibly cause:

- persistent data inconsistency that affects reads/updates later
- server/client contract drift on a shared API, schema, or backend handler
- compatibility break for existing stored data or old clients on a common settings/edit path
- partial-success batch behavior with stale derived state or misleading failure response
- cross-tenant/team/workspace scope confusion
- hidden broken primary workflow with no clear recovery path
- optimistic/persisted drift that can keep the UI wrong or block future mutations

## Medium

Use when shipping can plausibly cause:

- broken secondary affordance with another reasonable path available
- visible UX regression on a non-critical flow
- stale or confusing UI state that recovers on refresh
- performance regression on moderate-frequency paths
- missing validation that produces recoverable user-facing errors
- maintainability issue likely to cause near-term bugs if the area keeps changing

## Low

Use when the issue is:

- dead code, naming, minor duplication, or small cleanup with low bug risk
- cosmetic inconsistency without functional impact
- documentation/test clarity issue that does not hide a live bug
- performance concern on a cold path with small bounded data

## Escalators

Increase severity when:

- the path is shared or authoritative
- the user cannot recover without support or manual data repair
- failures are silent or look successful
- old data or old clients are likely affected
- the bug corrupts IDs, parent relationships, permissions, or membership scope
- one bad item can poison a batch, cache, read model, or optimistic queue
- the same bug class appears elsewhere in the branch

## De-escalators

Lower severity when:

- the impact is purely visual and localized
- there is a clear alternate path and no data/state risk
- the behavior is intentionally changed and documented
- the issue is limited to rare admin-only or dev-only tooling
- automated coverage already proves the risky variant and the finding is mostly cleanup

## Calibration Rule

If a finding sounds like "clicking does nothing," do not automatically rate it Low. Ask what state it leaves behind, whether another affordance works, whether data was already mutated, and whether the user can understand/recover.

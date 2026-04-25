# Severity Calibration

Use this when ranking audit findings. Many important repo-audit findings are not crashes; they are hidden broken flows, data integrity risks, compatibility traps, partial-success bugs, architecture seams, or operational failure modes.

## Critical

Use when the repo can plausibly cause:

- security breach, auth/authz bypass, tenant data exposure
- data loss, data corruption, duplicate authoritative IDs, irreversible destructive action
- payment/billing/entitlement error with real user or financial impact
- migration/backfill failure that can lock, corrupt, or irreversibly transform production data
- production outage or deployment break with no safe rollback
- secrets exposure or unsafe infrastructure default in a deployable path

## High

Use when the repo can plausibly cause:

- persistent data inconsistency that affects reads/updates later
- server/client contract drift on a shared API, schema, worker, event, or backend handler
- compatibility break for existing stored data, old clients, or background jobs on a common path
- partial-success batch behavior with stale derived state or misleading failure response
- cross-tenant/team/workspace/account scope confusion
- hidden broken primary workflow with no clear recovery path
- optimistic/persisted/read-model drift that can keep UI or downstream state wrong
- architecture boundary drift that duplicates policy or leaves an authoritative bypass path

## Medium

Use when the repo can plausibly cause:

- broken secondary affordance with another reasonable path available
- visible UX regression on a non-critical flow
- stale or confusing UI state that recovers on refresh/retry
- performance regression on moderate-frequency paths
- missing validation that produces recoverable user-facing errors
- maintainability issue likely to cause near-term bugs if the area keeps changing
- operational gap with manual recovery available

## Low

Use when the issue is:

- dead code, naming, minor duplication, or small cleanup with low bug risk
- cosmetic inconsistency without functional impact
- documentation/test clarity issue that does not hide a live bug
- performance concern on a cold path with small bounded data
- architecture preference without evidence of current or likely harm

## Escalators

Increase severity when:

- the path is shared or authoritative
- the user cannot recover without support or manual data repair
- failures are silent or look successful
- old data, old clients, jobs, or scripts are likely affected
- the bug corrupts IDs, parent relationships, permissions, membership, or tenant scope
- one bad item can poison a batch, cache, read model, optimistic queue, job, or stream
- the same bug class appears elsewhere in the repo
- the failure mode crosses service/package boundaries

## De-escalators

Lower severity when:

- the impact is purely visual and localized
- there is a clear alternate path and no data/state risk
- the behavior is intentionally changed and documented
- the issue is limited to rare admin-only, dev-only, or one-off migration tooling
- automated coverage already proves the risky variant and the finding is mostly cleanup

## Calibration Rule

If a finding sounds like "clicking does nothing" or "this path is stale," do not automatically rate it Low. Ask what state it leaves behind, whether another entrypoint works, whether data was already mutated, whether old data is blocked, and whether the user/operator can understand and recover.

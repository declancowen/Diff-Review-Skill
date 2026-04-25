# Architecture Review Bridge

Use this when an audit finding cannot be safely handled as a local code issue because it touches ownership, boundaries, shared contracts, or long-lived module shape. This does not replace the `architecture-standards` skill; it tells the auditor when to invoke it.

## Invoke Architecture Standards When

- **Ownership is unclear:** which layer should own IDs, defaults, validation, permission checks, reconciliation, or operational behavior?
- **A shared abstraction is drifting:** multiple screens/routes/services/jobs implement the same rule differently.
- **A fix would duplicate policy:** the same guard would need to be copied into many handlers or packages.
- **A contract spans layers:** UI, schema, route, store, service, backend handler, worker, and persistence all need aligned behavior.
- **Remediation changes dependency direction:** presentation wants domain/server code, domain wants framework code, or shared code wants app-specific dependencies.
- **A compatibility decision is product/platform-level:** create and update constraints differ, old stored data needs migration, or old clients/workers need a grace path.
- **State authority is split:** optimistic store, server handler, read model, fallback seed, and background job each claim ownership of the same field.
- **Operational ownership is unclear:** retry, idempotency, rollback, monitoring, or incident recovery is not owned by a clear layer.

## Architecture Review Questions

- What is the single source of truth for this rule?
- Which layer should reject invalid data, and which layer should only help users avoid errors?
- Does the fix strengthen boundaries or spread business logic into presentation/transport code?
- Can sibling surfaces share a helper without importing the wrong layer?
- Is intentional divergence documented at the boundary, or only implied by local code?
- Does the read model/fallback/cache/job path preserve the same invariant as the write path?
- Does the architecture provide a safe migration and rollback path for existing data?

## Output In Repo Audit

When architecture guidance is needed, include:

- **Boundary decision:** where the rule should live
- **Local fix shape:** what changes now
- **Shared fix shape:** helper/schema/adapter/contract if needed
- **Operational shape:** retry, idempotency, rollback, monitoring, or migration if relevant
- **Intentional divergence:** why any sibling path differs
- **Deferred architecture debt:** what is not fixed now and why

## Do Not

- Do not use architecture review to justify broad refactors without a live risk.
- Do not move logic "up" or "down" layers without checking existing dependency direction.
- Do not create a shared helper if it hides important contextual differences.
- Do not accept a local patch when the same invariant remains broken in another authoritative path.

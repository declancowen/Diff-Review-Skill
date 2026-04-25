# Architecture Review Bridge

Use this when a diff-review finding cannot be safely fixed as a local patch because it touches ownership, boundaries, shared contracts, or long-lived module shape. This does not replace the `architecture-standards` skill; it tells the reviewer when to invoke it.

## Invoke Architecture Standards When

- **Ownership is unclear:** which layer should own IDs, defaults, validation, permission checks, or reconciliation?
- **A shared abstraction is drifting:** multiple screens/routes/components implement the same rule differently.
- **A fix would duplicate policy:** the same guard would need to be copied into many local handlers.
- **A contract spans layers:** UI, schema, route, store, backend handler, and persistence all need aligned behavior.
- **Remediation changes dependency direction:** UI wants to import server/domain code, schema wants app state, or shared code wants framework-specific dependencies.
- **A compatibility decision is product/platform-level:** create and update constraints differ, old stored data needs a migration, or old clients need a grace path.
- **State authority is split:** optimistic store, server handler, read model, and fallback seed each claim ownership of the same field.

## Architecture Review Questions

- What is the single source of truth for this rule?
- Which layer should reject invalid data, and which layer should only help users avoid errors?
- Does the fix strengthen boundaries or spread business logic into presentation code?
- Can sibling surfaces share a helper without importing the wrong layer?
- Is intentional divergence documented at the boundary, or only implied by local code?
- Does the read model/fallback/cache path preserve the same invariant as the write path?

## Output In Diff Review

When architecture guidance is needed, include:

- **Boundary decision:** where the rule should live
- **Local fix shape:** what changes now
- **Shared fix shape:** helper/schema/adapter/contract if needed
- **Intentional divergence:** why any sibling path differs
- **Deferred architecture debt:** what is not fixed now and why

## Do Not

- Do not use architecture review to justify broad refactors without a live risk.
- Do not move logic "up" or "down" layers without checking existing dependency direction.
- Do not create a shared helper if it hides important contextual differences.
- Do not accept a local patch when the same invariant remains broken in another authoritative path.

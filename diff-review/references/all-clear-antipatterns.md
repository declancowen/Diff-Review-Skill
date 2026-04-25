# All-Clear Anti-Patterns

Read this before saying "all clear" on Medium+ risk reviews, repeated re-review loops, or any branch with external findings.

## Anti-Patterns

### "Tests Passed, Therefore Safe"

Passing tests only support an all-clear if they exercise the risky invariant or a convincing proxy. If the bug class involves legacy data, partial failure, transient UI lifetime, or scope duplication, generic tests are weak evidence.

Required correction: name which invariant each important test proves.

### "Line Number Moved, Therefore Stale"

External findings often have stale line numbers but live behavior. Do not mark stale until the current behavior is inspected.

Required correction: classify current-tree behavior as live/stale/intentional with evidence.

### "Not Touched This Turn"

On Turn 2+, the branch state is the target. A prior risky area can still block readiness even when the latest patch is elsewhere.

Required correction: re-read hotspot and prior-finding areas before branch all-clear.

### "Intentional" Without Product Evidence

Some semantic changes are deliberate. But "seems intentional" is not enough when the behavior affects users, data, or compatibility.

Required correction: cite product request, code comment, existing pattern, or explicit user confirmation.

### "Happy Path Only"

Reviewing populated/editable/current-user/default-state paths misses many real bugs.

Required correction: run a variant matrix: empty, legacy-invalid, `null`/`undefined`, scoped duplicate, child/parent, transient container, and failure path where relevant.

### "Primary Affordance Only"

Button works, but keyboard/menu/API/inline path does not. Or route path validates but store/direct mutation bypasses it.

Required correction: compare all action entrypoints for guards, payloads, side effects, and confirmations.

### "Local Fix Looks Plausible"

A local fix can still violate the bug family's shared invariant or break adjacent consumers.

Required correction: map remediation impact surface before resolving: upstream callers, downstream consumers, sibling paths, schemas, stores, and persistence.

### "Compatibility Equals Server Contract"

Server may already reject old data, but surfacing that rejection client-side can still block unrelated edits for existing users.

Required correction: check old stored values and create/update constraint differences.

### "No New Findings Means All Clear"

No fresh finding is not enough if branch-totality proof, hotspot recheck, challenger pass, or verification is missing.

Required correction: mark partial or blocked until proof obligations are met.

## Final Phrase Test

Before final all-clear, this sentence should be true:

"I attacked the most likely bug class for this branch against its weakest state variant, checked the highest-risk sibling path, and ran or named the relevant verification."

If not, do not say all clear.

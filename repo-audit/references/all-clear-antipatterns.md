# Clean-Conclusion Anti-Patterns

Read this before saying "healthy", "clean in audited scope", or "no major issues" on Medium+ risk audits, repeated re-audit loops, or any repo with external findings.

## Anti-Patterns

### "Tests Passed, Therefore Healthy"

Passing tests only support a clean conclusion if they exercise the risky invariant or a convincing proxy. If the bug class involves legacy data, partial failure, transient ownership, scope duplication, or architecture drift, generic tests are weak evidence.

Required correction: name which invariant each important test proves.

### "Line Number Moved, Therefore Stale"

External findings often have stale line numbers but live behavior. Do not mark stale until current behavior is inspected.

Required correction: classify current-tree behavior as live/stale/intentional with evidence.

### "Not Touched This Turn"

On Turn 2+, the current repo state is the target. A prior risky area can still block a healthy conclusion even when the latest fix is elsewhere.

Required correction: re-read hotspots, prior findings, and same-family areas before clean conclusion.

### "Intentional" Without Product Or Architecture Evidence

Some semantic and architectural changes are deliberate. But "seems intentional" is not enough when behavior affects users, data, compatibility, or operations.

Required correction: cite product request, architecture rule, code comment, existing pattern, or explicit user/team confirmation.

### "Happy Path Only"

Auditing populated/current-user/default-state paths misses many real bugs.

Required correction: run a variant matrix: empty, legacy-invalid, `null`/`undefined`, scoped duplicate, fallback, transient owner, batch partial failure, and bypass path where relevant.

### "Primary Entrypoint Only"

UI works, but API/job/script/import/webhook/direct mutation does not. Or route validates but store/server mutation bypasses it.

Required correction: compare all entrypoints for guards, payloads, side effects, permission checks, and error handling.

### "Local Fix Looks Plausible"

A local fix can still violate the bug family's shared invariant or break adjacent consumers.

Required correction: map remediation impact surface before resolving: upstream callers, downstream consumers, sibling paths, schemas, stores, jobs, persistence, and operations.

### "Compatibility Equals Server Contract"

Server may already reject old data, but surfacing that rejection earlier or more broadly can still block unrelated edits for existing users.

Required correction: check old stored values, old clients/jobs, and create/update constraint differences.

### "No New Findings Means Healthy"

No fresh finding is not enough if repo-totality proof, hotspot recheck, challenger pass, or verification is missing.

Required correction: mark partial or blocked until proof obligations are met.

## Final Phrase Test

Before a clean conclusion, this sentence should be true:

"I attacked the most likely bug class for this repo against its weakest state variant, checked the highest-risk sibling or bypass path, and ran or named the relevant verification."

If not, do not say the audited scope is clean.

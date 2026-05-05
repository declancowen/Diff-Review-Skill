# External Finding Import

Use this when the user supplies findings from GitHub, Devin, CI, security tools, production incidents, or another reviewer during a repo audit.

## Import Steps

1. **Normalize each finding.**
   - title
   - source
   - severity if supplied
   - file/line if supplied
   - claimed failure mode
   - current-tree status: `live`, `already fixed`, `stale`, `intentional`, or `needs confirmation`

2. **Classify each finding.**
   - load `bug-class-taxonomy.md`
   - assign one or more bug classes
   - name the invariant that should have caught it
   - name the variant/sibling/bypass path that needs checking

3. **Separate action from learning.**
   - live bug: fix or keep open
   - stale: explain what current code changed and why the behavior is no longer live
   - intentional: cite product/design/architecture evidence, not just opinion
   - needs confirmation: state the exact unknown
   - all statuses: still record the missed audit lens if it escaped a prior pass

4. **Write a compact import table in the audit file.**

```markdown
| Source | Finding | Current status | Bug class | Missed invariant/variant | Action |
|--------|---------|----------------|-----------|--------------------------|--------|
| Devin | Batch notification partial success | live | Atomicity | mixed valid+invalid batch | fix |
| GitHub | Dead code after empty control hide | stale | Variant State | editable child empty state | no code change |
```

5. **Run a sibling search for repeated live classes.**
   - one live Authority bug means inspect other generated fields, scripts, imports, jobs, and direct callers
   - one live Compatibility bug means inspect create vs update schemas, migrations, and old stored data
   - one live Affordance/Entrypoint Parity bug means compare UI, API, job, script, webhook, and direct mutation paths
   - one live contract-key bug means inspect sibling builders, routes, form handlers, query parameters, cookies, storage keys, webhook payloads, and failure/redirect branches that serialize the same public contract

6. **Capture process learning.**
   - if an external finding escaped a previous clean audit/review, record the missed lens and the prevention artifact in the audit turn
   - if the miss came from analyzer-driven refactoring, check for test-only production exports, stale coverage evidence, and mode-collapsed "clean" claims
   - if the source is automated PR analysis, wait for in-progress reviews rather than triggering duplicates; use resolved/outdated thread state only after current-tree proof
   - for large PRs, compare feedback to the latest commit/SHA and local branch diff; hosted diff truncation or delayed comments are context, not proof that the finding is stale

## Do Not

- Do not treat pasted line numbers as authoritative; inspect current behavior.
- Do not call a finding stale because the code moved; prove the behavior is gone.
- Do not mix intentional product/architecture changes with bugs. Mark them accepted only with evidence.
- Do not fix only the pasted line when the bug class implies a sibling or bypass path.
- Do not close the learning loop at "fixed"; update the audit/review prevention record when the miss reveals a reusable review or architecture gap.

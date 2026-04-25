# External Finding Import

Use this when the user pastes findings from GitHub, Devin, CI, another reviewer, or production after a local review has already run.

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
   - name the variant/sibling path that needs checking

3. **Separate action from learning.**
   - live bug: fix or keep open
   - stale: explain what current code changed and why the behavior is no longer live
   - intentional: cite product/design evidence, not just opinion
   - needs confirmation: state the exact unknown
   - all statuses: still record the missed review lens if it escaped a prior pass

4. **Write a compact import table in the review file.**

```markdown
| Source | Finding | Current status | Bug class | Missed invariant/variant | Action |
|--------|---------|----------------|-----------|--------------------------|--------|
| Devin | Batch notification partial success | live | Atomicity | mixed valid+invalid batch | fix |
| GitHub | Dead code after empty control hide | stale | Variant State | editable child empty state | no code change |
```

5. **Run a sibling search for repeated live classes.**
   - one live Authority bug means inspect other generated fields and direct callers
   - one live Compatibility bug means inspect create vs update schemas and old stored data
   - one live Affordance Parity bug means compare button, keyboard, menu, inline, and API paths

## Do Not

- Do not treat pasted line numbers as authoritative; inspect current behavior.
- Do not call a finding stale because the diff moved; prove the behavior is gone.
- Do not mix intentional product changes with bugs. Mark them accepted only with evidence.
- Do not fix only the pasted line when the bug class implies a sibling path.

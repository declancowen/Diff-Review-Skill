# Miss Retrospective Template

Use this when a repo audit missed a bug, security issue, architectural risk, or production-relevant finding.

The goal is to improve audit quality, not assign blame.

## Template

```markdown
## Miss Retrospective — {date}

### Escaped Finding

- **Source:** {GitHub review | Devin review | CI | user report | production | security tool}
- **Finding:** {short title}
- **Severity:** {Critical | High | Medium | Low}
- **Current-tree status:** {live | already fixed | stale | intentional | needs confirmation}
- **Bug class:** {taxonomy class names}
- **Affected path:** {file/function/user flow/API/job/script/system path}

### What The Audit Missed

- **Missed signal in code:** {what was visible but not acted on}
- **Missing trace:** {caller/consumer/sibling/fallback/job/script path not inspected}
- **Missing variant:** {empty/null/legacy/scope/lifecycle/partial failure/etc. variant not tested}
- **False confidence source:** {passing tests, happy-path reasoning, generic clean bill, assumed architecture}

### Better Audit Obligation

- **Invariant that should have been named:** {authority/preservation/identity/etc.}
- **Variant matrix row that should have been checked:** {specific variant}
- **Sibling/bypass path that should have been searched:** {specific family}
- **Question that would have found it:** {one concrete auditor question}

### Prevention

- **Product prevention artifact:** {test/guard/schema/assertion/helper/monitoring/none with reason}
- **Audit prevention artifact:** {taxonomy update/benchmark case/checklist wording/none with reason}
- **Benchmark candidate:** {yes/no; if yes, what input should a future auditor catch?}

### Follow-up

- **Immediate fix needed:** {yes/no}
- **Skill update needed:** {yes/no}
- **Open uncertainty:** {anything unresolved}
```

## Rules

- Classify every external finding against the current tree before fixing it.
- Do not mark a finding stale just because line numbers moved; inspect the behavior.
- Do not add narrow library-specific checklist items for one-off misses. Add or reuse a bug class and proof obligation.
- If a miss came from a family already in the taxonomy, tighten the proof obligation rather than creating a duplicate class.
- If a miss does not fit the taxonomy, add a candidate class to the audit file first; only promote it to the taxonomy after it appears useful beyond one incident.

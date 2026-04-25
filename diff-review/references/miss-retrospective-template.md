# Miss Retrospective Template

Use this when the user supplies GitHub/Devin/CI/user findings after a diff-review pass missed them, or when the review gave an all-clear too early.

The goal is to improve the review process, not to relitigate blame.

## Template

```markdown
## Miss Retrospective — {date}

### Escaped Finding

- **Source:** {GitHub review | Devin review | CI | user report | production}
- **Finding:** {short title}
- **Severity:** {Critical | High | Medium | Low}
- **Current-tree status:** {live | already fixed | stale | intentional | needs confirmation}
- **Bug class:** {taxonomy class names}
- **Affected path:** {file/function/user flow/API path}

### What The Review Missed

- **Missed signal in the diff:** {what was visible but not acted on}
- **Missing code trace:** {caller/consumer/sibling/fallback path not inspected}
- **Missing variant:** {empty/null/legacy/scope/lifecycle/keyboard/etc. variant not tested}
- **False confidence source:** {passing test, happy-path reasoning, generic all-clear, assumed intent}

### Better Review Obligation

- **Invariant that should have been named:** {authority/preservation/identity/etc.}
- **Variant matrix row that should have been checked:** {specific variant}
- **Sibling/path that should have been searched:** {specific family}
- **Question that would have found it:** {one concrete reviewer question}

### Prevention

- **Product prevention artifact:** {test/guard/schema/assertion/helper/none with reason}
- **Review prevention artifact:** {taxonomy update/benchmark case/checklist wording/none with reason}
- **Benchmark candidate:** {yes/no; if yes, what input should a future reviewer catch?}

### Follow-up

- **Immediate fix needed:** {yes/no}
- **Skill update needed:** {yes/no}
- **Open uncertainty:** {anything unresolved}
```

## Rules

- Classify every external finding against the current tree before fixing it.
- Do not mark a finding stale just because line numbers moved; inspect the behavior.
- Do not add a new checklist item for a one-off library detail. Add or reuse a bug class and proof obligation.
- If a miss came from a family already in the taxonomy, tighten the proof obligation rather than creating a duplicate class.
- If a miss does not fit the taxonomy, add a candidate class to the review file first; only promote it to the taxonomy after it appears useful beyond one incident.

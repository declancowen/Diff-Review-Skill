# Audit File Format

Use this when creating or updating `.audits/{scope}.md`.

## Rules

- One markdown file per audit scope.
- Newest turn appears first after the header.
- Header tracks project context, cumulative scope, hotspots, audit status, and findings summary.
- Turn state lives in the audit file, not a sidecar.
- `.audits/` stores audit evidence; durable tests belong in normal test directories.

## Header Skeleton

```markdown
# Audit: {scope}

## Project context

| Field | Value |
|-------|-------|
| **Repository** | {repo} |
| **Remote** | {remote} |
| **Branch** | {branch} |
| **Stack** | {stack} |
| **Codebase size** | {file/line summary} |

## Audit scope

- `{area/path}` — added Turn N

## Hotspots

- `{risk family}` — added Turn N

## Audit status

| Field | Value |
|-------|-------|
| **Audit started** | {date time} |
| **Last audited** | {date time} |
| **Total turns** | {N} |
| **Open findings** | {count} |
| **Resolved findings** | {count} |
| **Accepted findings** | {count} |

## Findings summary

| Severity | Open | Resolved | Accepted |
|----------|------|----------|----------|
| Critical | X | X | X |
| High | X | X | X |
| Medium | X | X | X |
| Low | X | X | X |
```

## Turn Skeleton

```markdown
## Turn N — {date time}

| Field | Value |
|-------|-------|
| **Commit** | {sha} |
| **IDE / Agent** | {agent} |

**Summary:** {...}
**Outcome:** {clean in audited scope | partial audit | blocked by open findings | blocked by missing verification}
**Health rating:** {Healthy | Needs attention | Significant issues | Critical}
**Risk score:** {low | medium | high | critical} — {why}
**Change archetypes:** {tags}
**Confidence:** {high | medium | low} — {why}
**Coverage note:** {...}
**Finding triage:** {...}
**Bug classes / invariants checked:** {...}
**Repo totality:** {...}
**Sibling closure:** {...}
**Remediation impact surface:** {...}
**Residual risk / unknowns:** {...}

### Architecture overview

{Turn 1 or repo-level audits only}

### Validation

- `{command}` — passed/failed/not run

### Repo-totality proof

- **Non-delta files/systems re-read:** {...}
- **Prior open findings rechecked:** {...}
- **Prior resolved/adjacent areas revalidated:** {...}
- **Hotspots or sibling paths revisited:** {...}
- **Dependency/adjacent surfaces revalidated:** {...}
- **Why this is enough:** {...}

### Challenger pass

- `{done | not needed | blocked}` — {...}

### Resolved / Carried / New findings

{finding sections}

### Recommendations

1. **Fix first:** {...}
2. **Then address:** {...}
3. **Patterns noticed:** {...}
4. **Suggested approach:** {...}
5. **Progress since last turn:** {...}
6. **Defer on purpose:** {...}
```

## Key Requirements

- Every turn states outcome, health, risk, confidence, coverage, triage, repo totality, validation, and residual risk.
- Turn 2+ proves repo-totality concretely; generic "rechecked repo" is insufficient.
- External findings get current-tree triage and bug-class classification.
- Serious findings require sibling closure and remediation impact notes.
- Clean findings still require proof.
- If anything important was not audited, mark partial and name what remains.

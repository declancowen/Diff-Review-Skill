# Review File Format

Use this when creating or updating `.reviews/{content-area}.md`.

## Rules

- One markdown file per content area.
- Newest turn appears first after the header.
- Header tracks project context, cumulative scope, hotspots, and review status.
- Turn state lives in the review file, not a sidecar.
- `.reviews/` is local review state and can be committed with the branch when useful.
- Durable regression tests belong in normal test directories, not `.reviews/`.

## Header Skeleton

```markdown
# Review: {content area}

## Project context

| Field | Value |
|-------|-------|
| **Repository** | {repo} |
| **Remote** | {remote} |
| **Branch** | {branch} |
| **Stack** | {stack} |

## Scope

- `{path}` — added Turn N

## Hotspots

- `{bug family}` — added Turn N

## Review status

| Field | Value |
|-------|-------|
| **Review started** | {date time} |
| **Last reviewed** | {date time} |
| **Total turns** | {N} |
| **Open findings** | {count} |
| **Resolved findings** | {count} |
| **Accepted findings** | {count} |
```

## Turn Skeleton

```markdown
## Turn N — {date time}

| Field | Value |
|-------|-------|
| **Commit** | {sha} |
| **IDE / Agent** | {agent} |

**Summary:** {...}
**Outcome:** {all clear | all clear with low-risk unknowns | partial review | blocked by open findings | blocked by missing verification}
**Risk score:** {low | medium | high | critical} — {why}
**Change archetypes:** {tags}
**Intended change:** {...}
**Intent vs actual:** {...}
**Confidence:** {high | medium | low} — {why}
**Coverage note:** {...}
**Finding triage:** {...}
**Bug classes / invariants checked:** {...}
**Branch totality:** {...}
**Sibling closure:** {...}
**Remediation impact surface:** {...}
**Residual risk / unknowns:** {...}

### Validation

- `{command}` — passed/failed/not run

### Branch-totality proof

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
5. **Defer on purpose:** {...}
```

## Key Requirements

- Every turn states outcome, risk, confidence, coverage, triage, branch totality, validation, and residual risk.
- Turn 2+ proves branch-totality concretely; generic "rechecked branch" is insufficient.
- External findings get current-tree triage and bug-class classification.
- Serious findings require sibling closure and remediation impact notes.
- No findings still requires proof.
- If anything important was not reviewed, mark partial and name what remains.

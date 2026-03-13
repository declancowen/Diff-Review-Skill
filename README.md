# Diff Review Skill

A local code review system that analyses git diffs before they reach origin. Goes beyond surface-level diff scanning — it reads the surrounding codebase for context, performs root cause analysis, and tracks findings across iterative review turns.

## What it does

- Reviews local git diffs for bugs, security issues, and code quality
- Reads surrounding codebase for full-stack context (not just the diff)
- Tracks findings across multiple review cycles with persistent IDs
- Produces a single markdown review file per content area in `.reviews/`

## How to use it

Just ask naturally. Any of these will trigger the skill:

- "Review my changes"
- "Check my diff before I push"
- "Look at my staged changes"
- "Compare my branch to main"
- "What did I break?"
- "Run the review again"
- "Did I fix the issues?"
- "Sanity check my work"

## Workflow

```
1. Ask for a review → agent analyses the diff, writes findings to .reviews/
2. Fix the issues
3. Ask for another review → agent compares against prior findings, updates statuses
4. Repeat until clean
5. Commit your code + the review file together
```

The review file stays uncommitted while you iterate. When everything's clear, commit it alongside your code as a record of what was checked.

## Finding types

| Prefix | Type | What it means |
|--------|------|---------------|
| `B` | Bug | Something is broken or will break |
| `S` | Security | Vulnerability, exposure, or access control gap |
| `F` | Flag | Looks off but might be intentional — needs confirmation |
| `O` | Observation | Not broken, but worth noting (tech debt, improvements) |

Each finding gets a unique ID like `B1-01` (bug, turn 1, first finding) that persists across turns so you can track resolution.

## Severity levels

- **Critical** — Must fix. Active bugs, security holes, data loss risk.
- **High** — Should fix soon. Problems that compound over time.
- **Medium** — Should fix. Improves velocity, reduces risk.
- **Low** — Nice to fix. Quality improvements, consistency.

## The `.reviews/` directory

```
.reviews/
├── auth-session-refactor.md
├── checkout-flow-fixes.md
└── supabase-rls-policies.md
```

- One markdown file per content area, named descriptively
- All turns, findings, and resolutions live in a single file
- NOT gitignored — ships with your branch as a review record
- Clean up before merging to main:

```bash
rm -rf .reviews/ && git add -A .reviews/ && git commit -m "chore: remove review artifacts before merge"
```

With squash merges, this happens automatically.

## Features

- **Auto-detects** repo structure, tech stack, and monorepo setup
- **Reads codebase context** — imports, consumers, shared types, full data flow
- **Root cause analysis** for every finding (not just "what" but "why")
- **Solution options** — quick fix and proper fix for each issue
- **Investigation prompts** — specific questions to check before choosing a fix
- **MCP integration** — uses connected MCP servers (Supabase, Firebase, GitHub, etc.) for live context in read-only mode

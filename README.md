# Diff Review Skill

A local code review system that analyses git diffs before they reach origin. Goes beyond surface-level diff scanning — it reads the surrounding codebase for context, performs root cause analysis, and tracks findings across iterative review turns.

Most review tools look at a PR in isolation — just the lines that changed. This skill does the opposite. It looks at the diff in the context of your codebase. For every changed file, it reads the full file, traces imports, checks consumers, follows the data flow. It understands what your code does, not just what you changed.

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

## How the review loop works

Each time you ask for a review, that's a "turn." The skill doesn't start from scratch each time — it builds on what it already knows.

**Turn 1** — the initial review. The agent diffs your branch, reads the changed files and their surrounding codebase (imports, consumers, types, the full data flow), and creates a review file named after what the diff is about. If your diff touches auth session handling, the file is `.reviews/auth-session-refactor.md`. If it's checkout flow fixes, it's `.reviews/checkout-flow-fixes.md`. The review file is tied to the content of your diff, not the branch name. Findings are written up with root cause analysis, solution options, and prioritised recommendations for what to fix first.

**Turn 2+** — you've made fixes and ask for another review. The agent re-diffs, picks up the existing review file for that content area, re-reads the codebase, and compares the current state of the diff against every prior finding:

- Findings that are fixed get marked as **Resolved** with a note on how
- Findings that are partially addressed get updated with current status
- Findings still untouched get **Carried** forward
- New issues introduced by the fixes get flagged as new findings
- If a fix introduced a new variant of the original problem, it gets flagged as a **Regression** referencing the original finding

Every turn ends with updated recommendations — a prioritised action plan covering what to fix first, dependencies between fixes, patterns emerging across the changes, and whether the fixes actually addressed root causes or just symptoms. Not a repeat of individual findings, but the bigger picture of what to do next.

The review file is a living document. One file, all turns, all findings, all resolutions. When you're done, it's a complete record of what was reviewed and how it was resolved.

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

## Stack detection and references

On the first turn, the skill auto-detects your tech stack from project config files and loads stack-specific review criteria from the `references/` folder. This means the review isn't generic — it knows what to look for in your stack.

Supported stacks:

| Category | Stacks |
|----------|--------|
| Mobile | React Native / Expo, Flutter, iOS native, Android native |
| Web | Next.js, Nuxt / Vue, Angular, Svelte, React, Vanilla |
| Backend | Node.js, Python, Go, Rust, Java / Kotlin, Ruby / Rails, PHP / Laravel |
| Services | Supabase, Firebase |
| Infra | Docker, CI/CD, Terraform / CDK / Serverless |
| Cross-cutting | TypeScript (loaded alongside any TS project) |

Stack detection only runs on Turn 1 and gets cached in the review file header. Subsequent turns skip it unless the diff includes new config files.

## Monorepo support

If the skill detects a monorepo (pnpm workspaces, Lerna, Nx, Turborepo), it scopes stack detection to affected packages and flags cross-package concerns:

- Shared package changes — do consumers handle the new interface?
- Workspace dependency version consistency
- Build order impacts
- Cross-package type export validity
- Config inheritance issues

## What each finding includes

Every finding goes deeper than "here's a problem." Each one includes:

- **Root cause analysis** — why the issue exists, not just what it is. Was it a misunderstanding of the API? A side effect of a refactor? A copy-paste from code that worked in a different context?
- **Codebase implication** — the blast radius. Which features or user flows does this affect? Could it cause data corruption? Does the same issue exist elsewhere? What happens in production if this ships as-is?
- **Solution options** — at least two where possible: a quick fix for the immediate issue and a proper fix if time allows for the right architectural approach.
- **Investigation prompt** — a specific question to check before choosing a fix. Things like "Check whether `UserProfile.addresses` can be null in production" or "Confirm with the team whether `skipValidation` is intentional for admin users." Genuine questions, not interrogations.

## Design intent awareness

Not everything that looks wrong is a bug. Before flagging something, the skill checks for signals it might be intentional:

- A comment explaining the approach
- A consistent pattern used elsewhere in the codebase
- A deliberate tradeoff (e.g. denormalised data for performance)
- Feature flags or gradual rollout patterns

When something looks off but could be a conscious decision, it gets classified as a Flag rather than a Bug. You confirm or dismiss it, and the next turn updates accordingly.

## MCP integration

If you have MCP servers connected, the skill uses them in read-only mode to gather live context that local files can't provide:

- **Supabase** — table schemas, RLS policies, edge functions, auth config
- **Firebase** — security rules, Firestore indexes, auth providers
- **GitHub** — open issues, PR history, CI status for changed files
- **Docs / Notion / Confluence** — related design docs or architecture decisions

If an MCP server would be useful but isn't connected, the skill notes it in the review file as an action item so you know what to check manually.

## Edge cases

- **Large diffs (500+ lines)** — warns you and suggests breaking into logical chunks
- **Empty diff** — helps figure out why (wrong branch? forgot to stage?)
- **Multiple content areas** — creates separate review files if the branch touches unrelated areas
- **Fresh start** — can archive an existing review and start clean if needed
- **Parallel branches** — each review is its own file, no conflicts

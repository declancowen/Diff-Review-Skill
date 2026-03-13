---
name: diff-review
description: Review local git diffs for bugs, security issues, and code quality before pushing to origin — with root cause analysis, codebase-aware context, and iterative turn-based review tracking. Use this skill whenever the user asks to review a diff, check changes before pushing, review staged changes, compare branches, do a local code review, pre-PR review, re-review after fixes, check review status, or says things like "review my changes", "check my diff", "what did I break", "review before I push", "look at my staged changes", "compare my branch to main", "run the review again", "did I fix the issues", or "what's still open from the last review". Also trigger when the user mentions reviewing code changes even casually, like "can you look at what I changed" or "sanity check my work".
---

# Diff Review

A local code review system that analyses git diffs before they reach origin. Goes beyond surface-level diff scanning — it reads the surrounding codebase for context, performs root cause analysis, and tracks findings across iterative review turns in a single file per content area.

## Core concepts

**Turn**: A single review cycle. Turn 1 is the initial review. Each subsequent turn reviews the current state, compares against prior findings, and updates statuses. All turns live in one file — the review document.

**Finding**: A specific issue, flag, or design question. Each finding gets a unique ID (`F1-01`, `F2-01`) that persists across turns so resolution can be tracked inline.

**Review file**: One markdown file per content area in `.reviews/`, named after what's being reviewed (e.g. `auth-session-refactor.md`). A branch can have multiple review files if it touches unrelated areas. Each file contains all turns, all findings, all resolutions for that content area. This is purely local diff analysis — the files live in `.reviews/` and get committed alongside the code when the review is complete.

## Workflow

```
1. User asks for a review
2. Agent reads all .md files in .reviews/ — they're all review context
   - No files → Turn 1. Analyse the diff, name the file by content area, write findings.
   - Files exist → Read them all for context. The relevant file is the one covering
                   the areas touched by the current diff. Append the next turn to it.
                   If the current diff covers a new area not in any existing review,
                   create a new file.
3. User fixes issues
4. User asks for another review → back to step 2
5. When satisfied, user commits their code + the review file together
```

The review file is a working document that stays uncommitted throughout the review cycle. You commit it once at the end alongside your code. If you switch machines or lose the local file mid-review, you'll need to reference the file path manually to pick it back up — that's the tradeoff for keeping the workflow simple.

---

## Step 1: Initialise

### 1a. Set up `.reviews/` directory

```bash
mkdir -p .reviews
```

The `.reviews/` directory is NOT gitignored. The review file stays uncommitted during the entire review cycle — it's a local working document. You commit it once at the end alongside your code when the review is complete and you're ready to push.

**Cleanup convention:** Before merging to main/develop, delete `.reviews/`:
```bash
rm -rf .reviews/ && git add -A .reviews/ && git commit -m "chore: remove review artifacts before merge"
```
With squash merges, this happens automatically.

### 1b. Read existing reviews and determine turn

```bash
ls .reviews/*.md 2>/dev/null
```

Read all `.md` files in `.reviews/`. They're all review context — the agent picks up the full picture of what's been reviewed, what's open, what's resolved across all files. If no `.md` files exist, this is a new review (Turn 1).

### 1c. Get the diff

Always exclude `.reviews/` from the diff:

```bash
# Get all changes on this branch (most common — everything that's changed vs main/develop)
git diff main...HEAD -- . ':!.reviews/'

# Or staged changes if working incrementally
git diff --staged -- . ':!.reviews/'

# Or unstaged working changes
git diff -- . ':!.reviews/'
```

The diff command is just the mechanism to get the changes. Use whichever method surfaces the user's current work — ask if unclear.

**Turn 1 — naming the review file:**

After getting the diff, read the changed files and summarise what the changes are about. Name the review file after the content area, not the branch:

- Auth session handling changes → `.reviews/auth-session-refactor.md`
- Checkout flow bugfixes → `.reviews/checkout-flow-fixes.md`
- Supabase RLS policy updates → `.reviews/supabase-rls-policies.md`
- Mixed changes across areas → `.reviews/sprint-4-auth-and-checkout.md`

The filename should be descriptive enough that someone looking at `.reviews/` can tell what was reviewed without opening the file. Use lowercase kebab-case.

```bash
REVIEW_FILE=".reviews/{content-area-slug}.md"
```

**Scope is cumulative across turns.** The review file has a "Scope" section in the header that lists all files and areas touched across all turns. Each turn may add new files to the scope as fixes introduce changes to new areas. Update the scope section each turn — don't replace it, append to it. This gives a complete picture of everything that was reviewed.

Grab context:
```bash
git diff --staged --stat -- . ':!.reviews/'
git log --oneline -5
git branch --show-current
```

---

## Step 2: Detect repo structure and tech stack

**Turn 1:** Run full detection and record the results in the review file header. This only needs to happen once — the stack doesn't change between turns on the same branch.

**Turn 2+:** Read the stack and repo type from the review file header. Skip detection entirely unless the diff includes new config files (e.g. a new `Dockerfile` added, `package.json` dependencies changed significantly) — in which case, re-detect and update the header.

### 2a. Monorepo detection

```bash
ls pnpm-workspace.yaml lerna.json nx.json turbo.json 2>/dev/null
ls -d packages/ apps/ services/ libs/ modules/ 2>/dev/null
cat package.json 2>/dev/null | grep -E '"workspaces"'
```

**If monorepo:** scope stack detection to affected packages only. Flag cross-package concerns.
**If single repo:** detect from project root.

### 2b. Stack detection

Look at project config files and load the relevant reference files from `references/`. Multiple should apply.

```bash
ls package.json tsconfig.json Cargo.toml pyproject.toml go.mod Gemfile pom.xml build.gradle Podfile composer.json pubspec.yaml 2>/dev/null
cat package.json 2>/dev/null | head -50
ls app.json expo.json next.config.* nuxt.config.* vite.config.* angular.json svelte.config.* 2>/dev/null
ls Dockerfile docker-compose.yml *.tf serverless.yml cdk.json 2>/dev/null
```

**Mobile:** react-native-expo, flutter, ios-native, android-native
**Web:** nextjs, nuxt-vue, angular, svelte, react-web, vanilla-web
**Backend:** python, go, rust, java-kotlin, ruby-rails, php-laravel, node-backend
**Services:** supabase, firebase
**Infra:** docker, ci-cd, infra
**Cross-cutting:** typescript (load alongside any TS project)

### 2c. Capture environment metadata

**Turn 1:** Run full environment capture after stack detection, so you only check relevant runtimes. Record everything in the review file header and in the Turn 1 metadata.

**Turn 2+:** Only capture per-turn context (date, time, commit SHA, IDE). The OS, package manager, and runtime versions are already in the header from Turn 1 — don't re-detect them unless the user has switched machines (which would be obvious from a different OS).

**Always capture (every turn):**
```bash
REVIEW_DATE=$(date +"%Y-%m-%d")
REVIEW_TIME=$(date +"%H:%M:%S %Z")
COMMIT_SHA=$(git rev-parse --short HEAD)
COMMIT_FULL=$(git rev-parse HEAD)

IDE="unknown"
if [ -n "$CLAUDE_CODE" ]; then IDE="Claude Code"
elif [ -n "$CURSOR_TRACE_ID" ] || [ -n "$CURSOR" ]; then IDE="Cursor"
elif [ -n "$WINDSURF_SESSION" ]; then IDE="Windsurf"
elif [ -n "$VSCODE_PID" ]; then IDE="VS Code"
elif [ -n "$TERM_PROGRAM" ]; then IDE="$TERM_PROGRAM"
fi
```

**Turn 1 only — full environment (cached in header):**
```bash
REMOTE_URL=$(git remote get-url origin 2>/dev/null || echo "no remote")
REPO_NAME=$(basename "$(git rev-parse --show-toplevel)")
OS_INFO=$(uname -s -r 2>/dev/null || echo "unknown")

# Package manager
PKG_MANAGER="unknown"
if [ -f "pnpm-lock.yaml" ]; then PKG_MANAGER="pnpm $(pnpm --version 2>/dev/null)"
elif [ -f "yarn.lock" ]; then PKG_MANAGER="yarn $(yarn --version 2>/dev/null)"
elif [ -f "package-lock.json" ]; then PKG_MANAGER="npm $(npm --version 2>/dev/null)"
elif [ -f "bun.lockb" ]; then PKG_MANAGER="bun $(bun --version 2>/dev/null)"
fi

# Runtimes — only capture what's relevant to the detected stack
# JS/TS projects:
NODE_VERSION=$(node --version 2>/dev/null)
# Python projects:
PYTHON_VERSION=$(python3 --version 2>/dev/null)
# Go/Rust/Java — only if detected:
GO_VERSION=$(go version 2>/dev/null | awk '{print $3}')
RUST_VERSION=$(rustc --version 2>/dev/null)
```

---

## Step 3: Gather codebase context (full-stack awareness)

The diff alone is not enough. For every file in the diff, read the full file to understand surrounding code. Also read related files — imports, consumers, shared types.

**For each changed file:**
```bash
cat <file>

# Who consumes this file?
grep -rl "import.*from.*<module-name>" --include="*.ts" --include="*.tsx" --include="*.js" --include="*.jsx" . 2>/dev/null | head -20

# What does this file depend on?
grep -E "^import|^from|require\(" <file> | head -20
```

**For API/backend changes:** check route definitions, middleware, database schema, shared types, env config.
**For frontend changes:** check component tree (who renders this?), state management, API client functions, navigation/routing.

**Think in terms of the full data flow:**
```
User action → UI component → API call → Route handler → Business logic → Database → Response → UI update
```

Does this change break any link in that chain? Does it assume something upstream or downstream that isn't guaranteed?

### 3b. Use MCP servers for live context (if available)

If MCP servers are connected, use them in **read-only mode** to gather live context that local files can't provide. Never make changes through MCP — only read.

**Supabase MCP:** Query table schemas, RLS policies, edge functions, and auth config to verify that code assumptions match the live database. For example, if the diff changes a query, check the actual table schema and indexes.

**Firebase MCP:** Check security rules, Firestore indexes, auth providers configuration.

**Google Drive / Notion / Confluence MCP:** Look up related design docs, architecture decisions, or API specs if referenced in comments or commit messages.

**GitHub MCP:** Check open issues, PR history, or CI status related to the changed files.

**Any other connected MCP:** If it provides relevant read-only context, use it.

**If an MCP server is not available but would be useful:** Note this in the review file. For example: "Unable to verify Supabase RLS policies — no Supabase MCP connected. Recommend manually checking that the `profiles` table has appropriate RLS for the new `role` column." This gives the user a clear action item.

---

## Step 4: Analyse the diff

### Review categories

#### 4a. Bugs and logic errors (CRITICAL)
- Off-by-one errors, boundary conditions
- Null/undefined handling — are new code paths safe?
- Race conditions, especially in async code
- State mutations that could cause unexpected behaviour
- Logic contradicting the apparent intent
- Incomplete refactors — renamed in one place but not another
- Error handling gaps

#### 4b. Security issues (CRITICAL)
- Secrets, API keys, tokens in the diff
- SQL injection, XSS, injection vectors
- Auth/authz bypasses
- Insecure data handling — PII logged, sensitive data in URLs
- Dependency changes — untrusted or known-vulnerable packages
- CORS or permission changes widening the attack surface

#### 4c. Code quality and maintainability (IMPORTANT)
- Dead code introduced or left behind
- Duplicated logic that should be extracted
- Naming that obscures intent
- Missing or misleading comments on complex logic
- Overly complex functions
- Type safety erosion

#### 4d. Stack-specific concerns (IMPORTANT)
Load from the relevant reference file(s) for detailed criteria per stack.

#### 4e. Monorepo-specific concerns (IMPORTANT — only if monorepo)
- Shared package changes — do consumers handle the new interface?
- Workspace dependency version consistency
- Build order impacts
- Cross-package type export validity
- Config inheritance issues

#### 4f. Design intent vs bug (IMPORTANT)

Not everything that looks wrong is a bug. Before flagging, check for signals it might be intentional:
- A comment explaining the approach
- A consistent pattern used elsewhere in the codebase
- A deliberate tradeoff (e.g. denormalised data for performance)
- Feature flags or gradual rollout patterns

When you suspect a design decision, classify as a **Flag** rather than a **Bug**.

#### 4g. Operational risk (MODERATE)
- Database migrations that could fail or lock tables
- Config changes that affect deployment
- Environment variable additions
- Breaking API contract changes

---

## Step 5: Root cause analysis for each finding

Every finding needs depth. Provide ALL of the following:

### Finding ID and classification

Every finding is one of four types. Choose the one that fits — if you're unsure between two, pick the more severe one.

| Prefix | Type | Definition |
|--------|------|------------|
| `B` | **Bug** | Something is broken or will break. The code doesn't do what it's supposed to — null references, logic errors, race conditions, missing error handling, incorrect return values, unhandled edge cases. Concrete, testable, wrong. |
| `S` | **Security** | A vulnerability, exposure, or access control gap. Exposed secrets, injection vectors, missing auth checks, RLS policy gaps, insecure data handling, CORS misconfigurations. Gets its own type because the response is different — security issues need specific remediation, not just a code fix. |
| `F` | **Flag** | Something looks off but might be intentional. Unusual patterns, suspicious logic, missing validation that could be deliberate, unconventional architecture choices without documentation. The developer needs to confirm whether it's a problem or a conscious design decision. If confirmed as a problem, it becomes a Bug or Security finding in the next turn. If confirmed as intentional, it becomes Accepted. |
| `O` | **Observation** | Not broken, not suspicious, but worth noting. Architecture patterns that could be improved, tech debt, refactoring opportunities, performance considerations, code quality improvements, dependency issues, operational readiness gaps. Things that would make the codebase better but aren't actively breaking anything. |

Format: `{prefix}{turn}-{sequence}` — e.g. `B1-01` (bug, turn 1, first finding), `S1-02` (security, turn 1, second), `O2-01` (observation, turn 2, first new finding).

These IDs persist across turns. `B1-01` is always `B1-01`, even when resolved in Turn 3.

### Severity

Every finding gets a severity rating regardless of type. A Bug can be Low (cosmetic). An Observation can be High (architectural debt compounding fast). A Flag can be Critical (potential auth bypass needing immediate confirmation).

- **Critical** — Must fix. Active bugs, security holes, data loss risk.
- **High** — Should fix soon. Problems that compound over time.
- **Medium** — Should fix. Improves velocity, reduces risk.
- **Low** — Nice to fix. Quality improvements, consistency.

### Root cause
Explain WHY the issue exists, not just what it is:
- Misunderstanding of the API or framework?
- Side effect of a refactor that missed this path?
- Data model assumption that doesn't hold in all cases?
- Copy-pasted from code that worked in a different context?
- Gap because the original author didn't consider this flow?

### Codebase implication
What's the blast radius? Go beyond the changed file:
- Which features or user flows does this affect?
- Could this cause data corruption, not just a UI glitch?
- Does this affect other services or packages?
- Is this a pattern — does the same issue exist elsewhere?
- What happens in production if this ships as-is? Be specific.

### Solution options
At least two approaches where possible:
- **Quick fix**: Minimal change that resolves the immediate issue
- **Proper fix**: Right architectural approach if time allows

### Investigation prompt
A specific question or check the developer should do before choosing a fix:
- "Check whether `UserProfile.addresses` can be null in production by querying the database"
- "Look at how `OrderService.processPayment` handles retries — if idempotent, this race condition is less severe"
- "Confirm with the team whether `skipValidation` is intentional for admin users"

---

## Step 6: Write (or update) the branch review file

All output goes into a single file: `.reviews/{content-area-slug}.md`

**Turn 1:** Create the file with the header and first turn.
**Turn 2+:** Append the new turn to the existing file. Update the header status counts and scope. Mark prior findings as resolved, carried, or accepted inline.

### File format

```markdown
# Review: {content area description}

## Project context (captured on Turn 1 — not re-detected on subsequent turns)

| Field | Value |
|-------|-------|
| **Repository** | {repo-name} |
| **Remote** | {remote-url} |
| **Branch** | {branch-name} |
| **Repo type** | {single repo / monorepo (type)} |
| **Stack** | {e.g. React Native / Expo / Supabase / TypeScript} |
| **Packages affected** | {monorepo only, or "n/a"} |
| **OS** | {OS info} |
| **Package manager** | {pnpm/yarn/npm + version} |
| **Node** | {version, if relevant to stack} |
| **Python** | {version, if relevant to stack} |

## Scope (cumulative — updated each turn as new files are touched)

Files and areas reviewed across all turns:
- `src/hooks/useAuth.ts` — added Turn 1
- `src/api/client.ts` — added Turn 1
- `src/utils/cache.ts` — added Turn 1
- `src/hooks/useSession.ts` — added Turn 2 (introduced during fix for F1-01)
- `src/middleware/auth.ts` — added Turn 2

## Review status (updated every turn)

| Field | Value |
|-------|-------|
| **Review started** | {date} {time} |
| **Last reviewed** | {date} {time} |
| **Total turns** | {N} |
| **Open findings** | {count} |
| **Resolved findings** | {count} |
| **Accepted findings** | {count} |

---

## Turn 2 — {date} {time}

| Field | Value |
|-------|-------|
| **Commit** | {sha} |
| **IDE / Agent** | {IDE} |

**Summary:** {2-3 sentence overview of what changed and the review outcome}

| Status | Count |
|--------|-------|
| New findings | X |
| Resolved from Turn 1 | Y |
| Carried from Turn 1 | Z |
| Accepted | W |

### Resolved from Turn 1

#### B1-01 ~~[BUG] Critical~~ → RESOLVED — {short description}
**How it was fixed:** {description of the fix}
**Verified:** {confirmation the fix addresses the root cause}

#### F1-03 ~~[FLAG] Low~~ → ACCEPTED — {short description}
**Reason:** {why accepted — intentional design, known tradeoff, out of scope}

### Carried from Turn 1

#### S1-02 [SECURITY] High — STILL OPEN — {short description}
**Status:** {unchanged | partially addressed}
**Notes:** {any updates based on new context}

### New findings

#### O2-01 [OBSERVATION] Medium — `{file}:{line}` — {short description}

**What's happening:**
{Describe the issue in context of the codebase, not just the diff}

**Root cause:**
{Why this issue exists}

**Codebase implication:**
{What breaks, who's affected, blast radius}

**Solution options:**
1. **Quick fix:** {minimal change}
2. **Proper fix:** {architectural approach}

**Investigate:**
{Specific question or check to do before fixing}

> {relevant diff snippet}

---

## Turn 1 — {date} {time}

| Field | Value |
|-------|-------|
| **Commit** | {sha} |
| **IDE / Agent** | {IDE} |

**Summary:** {2-3 sentence overview of what changed and overall assessment}

| Status | Count |
|--------|-------|
| Findings | X |

### Findings

#### B1-01 [BUG] Critical — `src/hooks/useAuth.ts:42` — Session token not refreshed on re-auth

**What's happening:**
{...}

**Root cause:**
{...}

**Codebase implication:**
{...}

**Solution options:**
1. **Quick fix:** {...}
2. **Proper fix:** {...}

**Investigate:**
{...}

> {diff snippet}

#### S1-02 [SECURITY] High — `src/api/client.ts:15` — API key exposed in client bundle

{...same format...}

#### F1-03 [FLAG] Low — `src/utils/cache.ts:88` — Cache TTL set to 0

{...same format...}
```

### Key rules for the file format

- **Newest turn at the top** (after the header). The current state should be immediately visible.
- **Project context is written once on Turn 1.** Stack, repo type, environment — all cached in the header. Not re-detected on subsequent turns unless config files changed in the diff.
- **Review status is updated every turn.** Counts, last reviewed timestamp, total turns.
- **Per-turn metadata is lightweight.** Just commit SHA, date/time, and IDE. Everything else is in the header.
- **Every finding keeps its original ID forever.** `B1-01` is always `B1-01`, even when resolved in Turn 3. Four prefixes: B (bug), S (security), F (flag), O (observation).
- **Resolved and accepted findings are updated in their resolution turn**, not in their original turn. The original turn stays as-is — it's the historical record.
- **Omit sections that are empty.** If Turn 2 has no new findings, skip "New findings". If nothing was resolved, skip "Resolved".

---

## Step 7: Re-review workflow (Turn 2+)

When the user asks to re-review after making fixes:

1. **Read all `.md` files in `.reviews/`** — they're all context. The relevant review file is the one that covers the current diff's content area. Parse its header for cached stack/environment, cumulative scope, and all prior findings with their statuses.
2. **Get the current diff** (always excluding `.reviews/`). The diff may now include new files that weren't in Turn 1 — that's expected, scope grows as fixes touch new areas
3. **Update the cumulative scope** in the header — add any new files that appear in this turn's diff
4. **Re-read the codebase context** for all files in the diff, plus files referenced in prior open findings (to check if they've been fixed)
5. **For each prior open finding, check the current code:**
   - **Resolved**: The code that caused the finding has been fixed. The fix addresses the root cause, not just the symptom. Write a resolution note.
   - **Partially addressed**: Some improvement but the core issue remains. Update notes.
   - **Still open**: No relevant change. Carry forward.
   - **Regression**: A fix introduced a new variant of the original problem. Create a new finding referencing the original.
   - **Accepted**: User explicitly confirmed it's intentional or out of scope. Record their reasoning.
6. **Analyse the diff for new findings** — fixes can introduce new bugs
7. **Append the new turn to the review file** and update the header status counts
8. **If all findings are resolved and no new issues found:** write a final turn confirming the review is clean. Update the header to show 0 open findings. Tell the user: all clear to submit. The code is ready to commit and push.

---

## File structure

```
.reviews/
├── auth-session-refactor.md       # named after the content area, not the branch
├── checkout-flow-fixes.md         # another review
├── supabase-rls-policies.md       # another review
```

One file per review. All turns inline. No subdirectories, no JSON sidecars. The markdown file is the single source of truth.

The filename describes what's being reviewed — someone looking at `.reviews/` should be able to tell what each file covers without opening it.

The file stays uncommitted while you're iterating. When the review is complete (all clear), commit everything together:
```bash
git add -A
git commit -m "feat: auth refactor (reviewed)"
```

The review file ships with the branch as a record of what was checked, what was found, and how it was resolved. Anyone reviewing the PR can read it for context.

---

## Edge cases

- **Very large diffs (500+ lines):** Warn the user. Suggest breaking into logical chunks. Focus on highest-risk files first.
- **Binary files or assets:** Skip but note them.
- **Merge commits:** Suggest reviewing only feature branch changes.
- **Empty diff:** Help the user figure out why — wrong branch? Forgot to stage?
- **User wants to accept a finding:** Mark as accepted with reasoning. Don't revisit in future turns.
- **Fresh start on existing review:** Ask the user if they want to archive the existing file (rename to `.reviews/{slug}.archived.md`) or continue from the last turn.
- **Multiple branches in parallel:** Each review is its own file named by content area — no conflicts even if working on multiple branches.

---

## Tone

Be direct and specific. Reference exact lines and file names. If something's a bug, call it a bug. If something looks intentional but risky, say so and explain the tradeoff.

Acknowledge good work. If a fix properly addresses a root cause, say so in the resolution note. The goal is to be the kind of reviewer you'd actually want on your team: thorough, honest, constructive, and builds confidence that the code is solid before it goes out.

Investigation prompts should be genuine questions, not interrogations. "Check whether X is possible in production" is better than "You failed to consider X."

#!/usr/bin/env bash
set -euo pipefail

section() {
  printf '\n## %s\n\n' "$1"
}

code_block() {
  printf '```text\n'
  if ! "$@"; then
    printf '%s\n' "<command failed: $*>"
  fi
  printf '```\n'
}

repo_root="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
cd "$repo_root"

base_ref="${1:-${AUDIT_BASE:-}}"
if [ -z "$base_ref" ]; then
  for candidate in origin/main main origin/master master origin/develop develop; do
    if git rev-parse --verify "$candidate" >/dev/null 2>&1; then
      base_ref="$candidate"
      break
    fi
  done
fi

branch="$(git branch --show-current 2>/dev/null || echo detached)"
head_sha="$(git rev-parse --short HEAD 2>/dev/null || echo unknown)"
full_sha="$(git rev-parse HEAD 2>/dev/null || echo unknown)"
upstream="$(git rev-parse --abbrev-ref --symbolic-full-name '@{u}' 2>/dev/null || echo none)"
remote="$(git remote get-url origin 2>/dev/null || echo none)"
timestamp="$(date +"%Y-%m-%d %H:%M:%S %Z")"

printf '# Repo Audit Preflight\n\n'
printf -- '- **Captured:** %s\n' "$timestamp"
printf -- '- **Repo:** %s\n' "$repo_root"
printf -- '- **Remote:** %s\n' "$remote"
printf -- '- **Branch:** %s\n' "$branch"
printf -- '- **Upstream:** %s\n' "$upstream"
printf -- '- **HEAD:** %s (%s)\n' "$head_sha" "$full_sha"
printf -- '- **Base ref:** %s\n' "${base_ref:-none detected}"

if command -v gh >/dev/null 2>&1; then
  section "Pull Request"
  if ! gh pr view --json number,url,state,isDraft,headRefName,baseRefName --jq '"#\(.number) \(.url) state=\(.state) draft=\(.isDraft) \(.headRefName)->\(.baseRefName)"' 2>/dev/null; then
    printf 'No GitHub PR detected for the current branch.\n'
  fi
fi

section "Working Tree"
code_block git status --short --branch

section "Repo Shape"
printf 'Top-level files/directories:\n\n'
code_block find . -maxdepth 2 -not -path './.git*' -not -path './node_modules*' -not -path './.next*' -not -path './dist*' -not -path './build*' -print

printf '\nFile extension counts:\n\n'
code_block sh -c "find . -type f -not -path './.git/*' -not -path './node_modules/*' -not -path './.next/*' -not -path './dist/*' -not -path './build/*' -not -path './.audits/*' -not -path './.reviews/*' | sed -n 's/.*\\.//p' | sort | uniq -c | sort -rn | head -25"

section "Important Config"
code_block sh -c "ls package.json pnpm-workspace.yaml turbo.json nx.json lerna.json tsconfig.json next.config.* vite.config.* docker-compose.yml Dockerfile .github/workflows/*.yml 2>/dev/null || true"

section "Git Delta Context"
printf 'Unstaged/staged name-status:\n\n'
code_block sh -c "git diff --name-status -- . ':!.audits/' ':!.reviews/'; git diff --staged --name-status -- . ':!.audits/' ':!.reviews/'"

if [ -n "$base_ref" ]; then
  printf '\nBranch diff stat vs `%s`:\n\n' "$base_ref"
  code_block git diff --stat "$base_ref"...HEAD -- . ':!.audits/' ':!.reviews/'
fi

section "Potential Hotspots"
if command -v rg >/dev/null 2>&1; then
  printf 'High-risk files by path heuristic:\n\n'
  rg --files . -g '!node_modules' -g '!.git' -g '!.next' -g '!dist' -g '!build' -g '!.audits' -g '!.reviews' \
    | rg '(^app/api/|^api/|^server/|^src/server/|^convex/|schema|validator|route|middleware|provider|store|selector|migration|queue|cache|auth|permission|policy|worker|job|webhook|scripts/)' \
    | head -200 \
    | sed 's/^/- `/' | sed 's/$/`/' || true

  printf '\nTODO/FIXME/HACK density sample:\n\n'
  rg -n 'TODO|FIXME|HACK|XXX|workaround|temporary' . \
    -g '!node_modules' -g '!.git' -g '!.next' -g '!dist' -g '!build' -g '!.audits' -g '!.reviews' \
    | head -80 || true
else
  printf 'ripgrep unavailable; inspect hotspots manually.\n'
fi

section "Existing Audit And Review Context"
if ls .audits/*.md >/dev/null 2>&1; then
  printf 'Audit files:\n\n'
  ls .audits/*.md | sed 's/^/- `/' | sed 's/$/`/'
else
  printf 'No `.audits/*.md` files found.\n'
fi

if ls .reviews/*.md >/dev/null 2>&1; then
  printf '\nReview files that may contain escaped-finding context:\n\n'
  ls .reviews/*.md | sed 's/^/- `/' | sed 's/$/`/'
fi

if command -v rg >/dev/null 2>&1; then
  printf '\nHotspot/status lines:\n\n'
  rg -n '^(## Hotspots|## Audit status|## Review status|\| \*\*Open findings\*\*|\| \*\*Total turns\*\*|\| \*\*Last audited\*\*|\| \*\*Last reviewed\*\*)' .audits .reviews 2>/dev/null || true
fi

section "Candidate Verification Commands"
if [ -f package.json ] && command -v node >/dev/null 2>&1; then
  node - <<'NODE' || true
const fs = require("fs")
const pkg = JSON.parse(fs.readFileSync("package.json", "utf8"))
const scripts = pkg.scripts || {}
const names = Object.keys(scripts).filter((name) =>
  /(test|type|lint|build|check|verify|ci|smoke|audit)/i.test(name)
)
if (names.length === 0) {
  console.log("No obvious package scripts found.")
} else {
  for (const name of names) {
    console.log(`- ${name}: ${scripts[name]}`)
  }
}
NODE
else
  printf 'No package.json detected or node unavailable. Inspect stack-specific test commands manually.\n'
fi

section "Audit Prompts"
cat <<'EOF'
- Assign risk score and audit archetype tags before auditing.
- Classify external findings with `references/bug-class-taxonomy.md`.
- For Medium+ risk, name key invariants and weakest state variants.
- For High/Critical risk, run a challenger pass before clean conclusion.
- Before a clean conclusion, check `references/all-clear-antipatterns.md`.
EOF

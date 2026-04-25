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

base_ref="${1:-${REVIEW_BASE:-}}"
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

changed_file_tmp="$(mktemp)"
trap 'rm -f "$changed_file_tmp"' EXIT

if [ -n "$base_ref" ]; then
  {
    git diff --name-only "$base_ref"...HEAD -- . ':!.reviews/' 2>/dev/null || true
    git diff --name-only -- . ':!.reviews/' 2>/dev/null || true
    git diff --staged --name-only -- . ':!.reviews/' 2>/dev/null || true
  } | sort -u > "$changed_file_tmp"
else
  {
    git diff --name-only -- . ':!.reviews/' 2>/dev/null || true
    git diff --staged --name-only -- . ':!.reviews/' 2>/dev/null || true
  } | sort -u > "$changed_file_tmp"
fi

printf '# Diff Review Preflight\n\n'
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

section "Current-Turn Delta"
printf 'Unstaged changes:\n\n'
code_block git diff --name-status -- . ':!.reviews/'
printf '\nStaged changes:\n\n'
code_block git diff --staged --name-status -- . ':!.reviews/'

section "Cumulative Branch Diff"
if [ -n "$base_ref" ]; then
  printf 'Diff stat vs `%s`:\n\n' "$base_ref"
  code_block git diff --stat "$base_ref"...HEAD -- . ':!.reviews/'
  printf '\nName/status vs `%s`:\n\n' "$base_ref"
  code_block git diff --name-status "$base_ref"...HEAD -- . ':!.reviews/'
else
  printf 'No base ref detected. Pass one explicitly: `review-preflight.sh origin/main`.\n'
fi

section "Changed File Buckets"
if [ ! -s "$changed_file_tmp" ]; then
  printf 'No changed files detected outside `.reviews/`.\n'
else
  printf 'All changed files:\n\n'
  sed 's/^/- `/' "$changed_file_tmp" | sed 's/$/`/'

  printf '\nLikely tests/specs:\n\n'
  if grep -Ei '(^|/)(__tests__|tests?|specs?)/|\.(test|spec)\.[tj]sx?$' "$changed_file_tmp" >/dev/null; then
    grep -Ei '(^|/)(__tests__|tests?|specs?)/|\.(test|spec)\.[tj]sx?$' "$changed_file_tmp" | sed 's/^/- `/' | sed 's/$/`/'
  else
    printf 'none detected\n'
  fi

  printf '\nLikely high-risk/shared surfaces:\n\n'
  if grep -Ei '(^app/api/|^convex/|^server/|^src/server/|schema|validator|route|middleware|provider|store|selector|migration|queue|cache|auth|permission|policy|components/.*/(shared|.*dialog|.*menu|.*surface)|^hooks/|^lib/domain|^lib/store)' "$changed_file_tmp" >/dev/null; then
    grep -Ei '(^app/api/|^convex/|^server/|^src/server/|schema|validator|route|middleware|provider|store|selector|migration|queue|cache|auth|permission|policy|components/.*/(shared|.*dialog|.*menu|.*surface)|^hooks/|^lib/domain|^lib/store)' "$changed_file_tmp" | sed 's/^/- `/' | sed 's/$/`/'
  else
    printf 'none detected by heuristic\n'
  fi
fi

section "Existing Review Context"
if ls .reviews/*.md >/dev/null 2>&1; then
  printf 'Review files:\n\n'
  ls .reviews/*.md | sed 's/^/- `/' | sed 's/$/`/'
  if command -v rg >/dev/null 2>&1; then
    printf '\nHotspot/status lines:\n\n'
    rg -n '^(## Hotspots|## Review status|\| \*\*Open findings\*\*|\| \*\*Total turns\*\*|\| \*\*Last reviewed\*\*)' .reviews/*.md || true
  fi
else
  printf 'No `.reviews/*.md` files found.\n'
fi

section "Candidate Verification Commands"
if [ -f package.json ] && command -v node >/dev/null 2>&1; then
  node - <<'NODE' || true
const fs = require("fs")
const pkg = JSON.parse(fs.readFileSync("package.json", "utf8"))
const scripts = pkg.scripts || {}
const names = Object.keys(scripts).filter((name) =>
  /(test|type|lint|build|check|verify|ci)/i.test(name)
)
if (names.length === 0) {
  console.log("No obvious package scripts found.")
} else {
  for (const name of names) {
    console.log(`- ${name}: ${scripts[name]}`)
  }
}
NODE
elif [ -f package.json ]; then
  printf 'package.json exists, but node is unavailable to inspect scripts.\n'
else
  printf 'No package.json detected. Inspect stack-specific test commands manually.\n'
fi

section "Review Prompts"
cat <<'EOF'
- Assign risk score and change archetype tags before reviewing.
- Classify external findings with `references/bug-class-taxonomy.md`.
- For Medium+ risk, name the key invariants and weakest state variants.
- For High/Critical risk, run a challenger pass before all-clear.
- Before all-clear, check `references/all-clear-antipatterns.md`.
EOF

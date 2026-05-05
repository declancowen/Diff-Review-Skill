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

fallow_available() {
  if [ -f package.json ] && command -v pnpm >/dev/null 2>&1 && pnpm exec fallow --version >/dev/null 2>&1; then
    return 0
  fi
  command -v fallow >/dev/null 2>&1
}

run_fallow() {
  if [ -f package.json ] && command -v pnpm >/dev/null 2>&1 && pnpm exec fallow --version >/dev/null 2>&1; then
    pnpm exec fallow "$@"
  elif command -v fallow >/dev/null 2>&1; then
    fallow "$@"
  else
    return 127
  fi
}

summarize_fallow_json() {
  local label="$1"
  shift
  local output status
  if output="$(run_fallow "$@" 2>/dev/null)"; then
    status=0
  else
    status=$?
  fi
  if [ "$status" -eq 127 ]; then
    printf -- '- %s: unavailable\n' "$label"
    return 0
  fi
  if [ "$status" -eq 2 ]; then
    printf -- '- %s: tool/config error (exit 2)\n' "$label"
    return 0
  fi
  printf '%s' "$output" | node -e '
const label = process.argv[1]
let input = ""
process.stdin.on("data", (chunk) => { input += chunk })
process.stdin.on("end", () => {
  const text = input.trim()
  if (!text) {
    console.log(`- ${label}: no json output`)
    return
  }
  const objectStart = text.indexOf("{")
  const arrayStart = text.indexOf("[")
  const jsonStart = objectStart === -1 ? arrayStart : arrayStart === -1 ? objectStart : Math.min(objectStart, arrayStart)
  const jsonText = jsonStart > 0 ? text.slice(jsonStart) : text
  let report
  try {
    report = JSON.parse(jsonText)
  } catch {
    console.log(`- ${label}: non-json output`)
    return
  }
  const parts = []
  const summary = report.summary || {}
  const stats = report.stats || {}
  const add = (name, value) => {
    if (value !== undefined && value !== null) parts.push(`${name}=${value}`)
  }
  add("verdict", report.verdict)
  add("total_issues", report.total_issues ?? summary.total_issues)
  add("dead_code", summary.dead_code_issues)
  add("complexity", summary.complexity_findings ?? summary.functions_above_threshold)
  add("critical", summary.severity_critical_count)
  add("high", summary.severity_high_count)
  add("moderate", summary.severity_moderate_count)
  add("clone_groups", summary.duplication_clone_groups ?? stats.clone_groups)
  add("duplicated_lines", stats.duplicated_lines)
  if (typeof stats.duplication_percentage === "number") {
    add("duplication_pct", `${stats.duplication_percentage.toFixed(2)}%`)
  }
  if (Array.isArray(report.findings)) add("findings", report.findings.length)
  if (Array.isArray(report.fixes)) add("fix_preview", report.fixes.length)
  if (report.health_score) add("score", `${report.health_score.score}/${report.health_score.grade}`)
  if (report.boundaries) {
    const boundaries = report.boundaries
    const configured =
      boundaries.configured !== undefined
        ? boundaries.configured
        : Boolean((boundaries.zones || []).length || (boundaries.rules || []).length)
    add("boundaries", configured ? "configured" : "not-configured")
  }
  console.log(`- ${label}: ${parts.length ? parts.join(" ") : "json-ok"}`)
})
' "$label"
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

section "Static Analyzer / Architecture Policy Signals"
printf 'Analyzer and architecture-policy files:\n\n'
code_block sh -c "ls .fallowrc.json .fallowrc.jsonc fallow.toml .fallow.toml knip.json knip.jsonc knip.ts .jscpd.json .jscpd.jsonc .dependency-cruiser.* dependency-cruiser.config.* eslint.config.* fallow-baselines/* .fallow/* 2>/dev/null || true"

if [ -f package.json ] && command -v node >/dev/null 2>&1; then
  printf '\nAnalyzer-related package scripts:\n\n'
  node - <<'NODE' || true
const fs = require("fs")
const pkg = JSON.parse(fs.readFileSync("package.json", "utf8"))
const scripts = pkg.scripts || {}
const matches = Object.entries(scripts).filter(([name, cmd]) =>
  /(fallow|knip|jscpd|depcruise|dependency|arch|boundary|cycle|dead|dupe|health|coverage|audit|baseline)/i.test(`${name} ${cmd}`)
)
if (matches.length === 0) {
  console.log("No analyzer-related package scripts found.")
} else {
  for (const [name, cmd] of matches) {
    console.log(`- ${name}: ${cmd}`)
  }
}
NODE
fi

if [ -d .github/workflows ] && command -v rg >/dev/null 2>&1; then
  printf '\nCI analyzer parity signals:\n\n'
  rg -n 'fallow|knip|jscpd|depcruise|dependency|arch|boundary|dead|dupe|health|audit|continue-on-error|pnpm (fallow|check|audit)' .github/workflows 2>/dev/null || printf 'No analyzer-related CI signals found.\n'
fi

printf '\nFallow evidence summary:\n\n'
if fallow_available && command -v node >/dev/null 2>&1; then
  summarize_fallow_json "config" config --format json --quiet
  summarize_fallow_json "project-shape" list --plugins --entry-points --boundaries --format json --quiet
  if [ -n "$base_ref" ]; then
    summarize_fallow_json "changed-file-audit" audit --changed-since "$base_ref" --production-dead-code --production-health --production-dupes --max-crap 1000000 --format json --quiet --explain
  else
    printf -- '- changed-file-audit: skipped (no base ref)\n'
  fi
  summarize_fallow_json "production-dead-code" dead-code --production --format json --quiet --summary
  summarize_fallow_json "full-dead-code" dead-code --format json --quiet --summary
  summarize_fallow_json "production-health" health --production --max-crap 1000000 --format json --quiet --summary
  summarize_fallow_json "full-health" health --format json --quiet --summary
  summarize_fallow_json "production-dupes" dupes --production --ignore-imports --top 1 --format json --quiet
  summarize_fallow_json "full-dupes" dupes --top 1 --format json --quiet
  summarize_fallow_json "fix-preview" fix --dry-run --format json --quiet
else
  printf 'Fallow not available through project-local pnpm or PATH.\n'
fi

if command -v rg >/dev/null 2>&1; then
  printf '\nAnalyzer and transition caveats in audits/reviews:\n\n'
  rg -n 'fallow|knip|jscpd|dead code|dupl|health|hotspot|module budget|large file|baseline|allowlist|suppression|current-state|target-state|transition|boundary|architecture|fitness function' .audits .reviews 2>/dev/null | head -160 || true
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
- If analyzer signals exist, separate configured gates from advisory inventories and classify baselines, suppressions, allowlists, and transition debt.
- For architecture audits, score current-state fitness and target-state design together.
- For Medium+ risk, name key invariants and weakest state variants.
- For High/Critical risk, run a challenger pass before clean conclusion.
- Before a clean conclusion, check `references/all-clear-antipatterns.md`.
EOF

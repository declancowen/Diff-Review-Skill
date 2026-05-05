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

section "Static Analyzer / Architecture Policy Signals"
printf 'Analyzer and architecture-policy files:\n\n'
code_block sh -c "ls .fallowrc.json .fallowrc.jsonc fallow.toml .fallow.toml knip.json knip.jsonc knip.ts .jscpd.json .jscpd.jsonc .dependency-cruiser.* dependency-cruiser.config.* eslint.config.* 2>/dev/null || true"

if [ -f package.json ] && command -v node >/dev/null 2>&1; then
  printf '\nAnalyzer-related package scripts:\n\n'
  node - <<'NODE' || true
const fs = require("fs")
const pkg = JSON.parse(fs.readFileSync("package.json", "utf8"))
const scripts = pkg.scripts || {}
const matches = Object.entries(scripts).filter(([name, cmd]) =>
  /(fallow|knip|jscpd|depcruise|dependency|arch|boundary|cycle|dead|dupe|health|coverage|audit)/i.test(`${name} ${cmd}`)
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
else
  printf 'Fallow not available through project-local pnpm or PATH.\n'
fi

if command -v rg >/dev/null 2>&1; then
  printf '\nAnalyzer and transition caveats in reviews/audits:\n\n'
  rg -n 'fallow|knip|jscpd|dead code|dupl|health|hotspot|module budget|large file|baseline|allowlist|suppression|current-state|target-state|transition|boundary|architecture' .reviews .audits 2>/dev/null | head -120 || true
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
- If static analyzer or architecture-policy signals exist, classify gates, inventories, baselines, suppressions, and transition-state caveats before all-clear.
- For architecture-remediation diffs, name the current-state failure mode and target-state rule being improved.
- For Medium+ risk, name the key invariants and weakest state variants.
- For High/Critical risk, run a challenger pass before all-clear.
- Before all-clear, check `references/all-clear-antipatterns.md`.
EOF

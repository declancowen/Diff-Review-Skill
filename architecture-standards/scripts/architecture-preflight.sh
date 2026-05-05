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
  add("total_issues", report.total_issues ?? summary.total_issues)
  add("complexity", summary.functions_above_threshold)
  add("critical", summary.severity_critical_count)
  add("high", summary.severity_high_count)
  add("moderate", summary.severity_moderate_count)
  add("clone_groups", stats.clone_groups)
  add("duplicated_lines", stats.duplicated_lines)
  if (typeof stats.duplication_percentage === "number") {
    add("duplication_pct", `${stats.duplication_percentage.toFixed(2)}%`)
  }
  if (Array.isArray(report.findings)) add("findings", report.findings.length)
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

printf '# Architecture Preflight\n\n'
printf -- '- **Captured:** %s\n' "$(date +"%Y-%m-%d %H:%M:%S %Z")"
printf -- '- **Repo:** %s\n' "$repo_root"
printf -- '- **Branch:** %s\n' "$(git branch --show-current 2>/dev/null || echo unknown)"
printf -- '- **HEAD:** %s\n' "$(git rev-parse --short HEAD 2>/dev/null || echo unknown)"

section "Repo Shape"
code_block sh -c "find . -maxdepth 3 \\( -path './.git' -o -path '*/.git' -o -path '*/.git/*' -o -path '*/node_modules' -o -path '*/node_modules/*' -o -path '*/.next' -o -path '*/.next/*' -o -path '*/dist' -o -path '*/dist/*' -o -path '*/build' -o -path '*/build/*' -o -path '*/.vercel' -o -path '*/.vercel/*' -o -path '*/.partykit' -o -path '*/.partykit/*' -o -path '*/coverage' -o -path '*/coverage/*' -o -path '*/.turbo' -o -path '*/.turbo/*' \\) -prune -o -not -name '.DS_Store' -not -name '*.tsbuildinfo' -print"

section "Architecture Docs And Decisions"
code_block sh -c "find . -maxdepth 4 \\( -path './.git' -o -path '*/.git' -o -path '*/.git/*' -o -path '*/node_modules' -o -path '*/node_modules/*' -o -path '*/.next' -o -path '*/.next/*' -o -path '*/.vercel' -o -path '*/.vercel/*' -o -path '*/.partykit' -o -path '*/.partykit/*' \\) -prune -o \\( -iname '*adr*' -o -iname '*architecture*' -o -path './docs/*' -o -path './.spec/*' \\) -not -name '.DS_Store' -print | sort | head -200"

section "Module Boundary Signals"
code_block sh -c "ls package.json pnpm-workspace.yaml turbo.json nx.json lerna.json tsconfig.json tsconfig.*.json eslint.config.* next.config.* vite.config.* 2>/dev/null || true"

section "Static Analysis And Target-State Signals"
printf 'Analyzer and boundary-policy files:\n\n'
code_block sh -c "ls .fallowrc.json .fallowrc.jsonc fallow.toml .fallow.toml knip.json knip.jsonc knip.ts .jscpd.json .jscpd.jsonc .dependency-cruiser.* dependency-cruiser.config.* fallow-baselines/* .fallow/* 2>/dev/null || true"

if [ -f package.json ] && command -v node >/dev/null 2>&1; then
  printf '\nAnalyzer, architecture, and boundary scripts:\n\n'
  node - <<'NODE' || true
const fs = require("fs")
const pkg = JSON.parse(fs.readFileSync("package.json", "utf8"))
const scripts = pkg.scripts || {}
const matches = Object.entries(scripts).filter(([name, cmd]) =>
  /(fallow|knip|jscpd|depcruise|dependency|arch|boundary|cycle|dead|dupe|health|coverage|audit|baseline|module|budget)/i.test(`${name} ${cmd}`)
)
if (matches.length === 0) {
  console.log("No analyzer or architecture scripts found.")
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

printf '\nFallow architecture evidence summary:\n\n'
if fallow_available && command -v node >/dev/null 2>&1; then
  summarize_fallow_json "config" config --format json --quiet
  summarize_fallow_json "project-shape" list --plugins --entry-points --boundaries --format json --quiet
  summarize_fallow_json "production-health" health --production --max-crap 1000000 --format json --quiet --summary
  summarize_fallow_json "full-health" health --format json --quiet --summary
  summarize_fallow_json "production-dupes" dupes --production --ignore-imports --top 1 --format json --quiet
  summarize_fallow_json "full-dupes" dupes --top 1 --format json --quiet
else
  printf 'Fallow not available through project-local pnpm or PATH.\n'
fi

if command -v rg >/dev/null 2>&1; then
  printf '\nCurrent-state / target-state / transition evidence:\n\n'
  rg -n 'current-state|target-state|transition|fitness function|module budget|large file|allowlist|baseline|suppression|duplication|health|hotspot|boundary|ownership|invariant' .audits .reviews docs .spec 2>/dev/null | head -180 || true
fi

section "High-Risk Architecture Surfaces"
if command -v rg >/dev/null 2>&1; then
  rg --files . -g '!**/node_modules/**' -g '!**/.git/**' -g '!**/.next/**' -g '!**/dist/**' -g '!**/build/**' -g '!**/.vercel/**' -g '!**/.partykit/**' -g '!**/coverage/**' \
    | rg '(^app/api/|^api/|^server/|^src/server/|^convex/|schema|validator|route|middleware|provider|store|selector|migration|queue|cache|auth|permission|policy|worker|job|webhook|scripts/|infrastructure|domain|application|data)' \
    | head -250 \
    | sed 's/^/- `/' | sed 's/$/`/' || true
else
  printf 'ripgrep unavailable; inspect high-risk surfaces manually.\n'
fi

section "Architecture Smell Search"
if command -v rg >/dev/null 2>&1; then
  printf 'Generic buckets and possible god modules:\n\n'
  rg --files . -g '!**/node_modules/**' -g '!**/.git/**' -g '!**/.next/**' -g '!**/dist/**' -g '!**/build/**' -g '!**/.vercel/**' -g '!**/.partykit/**' -g '!**/coverage/**' \
    | rg '/(utils|helpers|services|managers|common|shared)/|Service\\.|Manager\\.|helper' \
    | head -120 || true

  printf '\nTODO/FIXME/HACK architecture clusters:\n\n'
  rg -n 'TODO|FIXME|HACK|XXX|workaround|temporary|tech debt|cleanup|refactor|deprecat' . \
    -g '!**/node_modules/**' -g '!**/.git/**' -g '!**/.next/**' -g '!**/dist/**' -g '!**/build/**' \
    -g '!**/.vercel/**' -g '!**/.partykit/**' -g '!**/coverage/**' \
    | head -120 || true
else
  printf 'ripgrep unavailable; skip smell search.\n'
fi

section "Verification / Enforcement Signals"
if [ -f package.json ] && command -v node >/dev/null 2>&1; then
  node - <<'NODE' || true
const fs = require("fs")
const pkg = JSON.parse(fs.readFileSync("package.json", "utf8"))
const scripts = pkg.scripts || {}
for (const [name, cmd] of Object.entries(scripts)) {
  if (/(lint|type|test|build|check|verify|dep|arch|boundary|cycle|ci)/i.test(name + " " + cmd)) {
    console.log(`- ${name}: ${cmd}`)
  }
}
NODE
else
  printf 'No package.json detected or node unavailable.\n'
fi

section "Architecture Prompts"
cat <<'EOF'
- What capability owns the rule being changed?
- What layer owns the invariant?
- What imports or APIs prevent bypass?
- What code-level enforcement exists: tests, schemas, types, runtime guards, lint, dependency rules?
- Does current-state evidence contradict the claimed architecture?
- What target-state rule, owner, and fitness signal should eliminate this class of debt?
- What fallback/cache/job/script path can bypass the intended boundary?
- Is this architecture debt must-fix, cheap/safe, or defer?
EOF

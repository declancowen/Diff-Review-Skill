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
- What fallback/cache/job/script path can bypass the intended boundary?
- Is this architecture debt must-fix, cheap/safe, or defer?
EOF

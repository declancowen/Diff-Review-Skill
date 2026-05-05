# Fallow Package Internals

Use this when you need to understand what the npm package actually ships, why a command behaves like a subprocess, or which integration surface is better for an agent workflow.

This reference is based on inspecting the local `fallow@2.58.0` npm package layout. Re-check with the installed package when version-sensitive behavior matters.

## Package Shape

The npm package is a thin JavaScript wrapper around platform-specific native binaries.

Important parts:

- `bin/fallow`, `bin/fallow-lsp`, and `bin/fallow-mcp` are Node launchers.
- `scripts/platform-package.js` maps OS, CPU architecture, and Linux libc family to an optional binary package.
- Optional packages are named under `@fallow-cli/*`, such as `@fallow-cli/darwin-arm64` or `@fallow-cli/linux-x64-gnu`.
- The launcher resolves the matching optional package, finds the native binary, and forwards CLI arguments using `execFileSync`.
- The package also ships a version-matched `skills/fallow/` directory with richer command, MCP, and pattern references.

Agent consequence: shell output and exit codes come from the native binary, but installation and binary resolution errors come from the Node wrapper. Keep those failure modes separate.

## Execution Surfaces

Fallow can be used through several surfaces:

- **CLI:** best default for repo audits, remediation batches, CI parity, and reproducible command logs.
- **MCP server:** useful when a host exposes `fallow-mcp`; provides structured tools for analysis, changed checks, duplicate search, health, runtime coverage, project info, boundaries, and flags.
- **LSP:** editor-oriented surface, generally not the right choice for non-interactive agent turns.
- **Node bindings:** package guidance points to `@fallow-cli/fallow-node` for long-running Node processes where subprocess overhead and JSON parsing are undesirable.

Do not assume the CLI is the only source of capability. Use `fallow schema`, `fallow config-schema`, `fallow list`, and package-shipped skill references to discover available commands and options.

## Process And Error Semantics

Because the CLI wrapper forwards the native process status:

- exit code `0` means no blocking issue for that command/policy
- exit code `1` can mean findings were reported
- exit code `2` is a tool/config/runtime problem
- wrapper errors mention unsupported platform, missing optional package, or missing binary path

For JSON workflows, keep stderr separate from stdout. A wrapper/platform error is not analyzer evidence.

## Capability Lessons

The package-shipped skill and CLI references exposed several primitives that are easy to miss from basic usage:

- `schema`, `config`, `config-schema`, and `plugin-schema` are discovery tools.
- `list --plugins --entry-points --boundaries` reveals how Fallow sees the repo.
- `dead-code --trace-file`, `--trace-dependency`, `--production`, and `--include-entry-exports` answer different reachability questions.
- `dupes --mode semantic`, `--skip-local`, `--changed-since`, and regression baselines answer different duplication questions.
- `health --hotspots`, `--file-scores`, `--targets`, `--coverage-gaps`, `--ownership`, `--score`, `--trend`, and snapshots turn health into prioritization evidence.
- `audit` is a changed-code combined gate, not a full substitute for full-repo inventories.
- `flags` provides lifecycle evidence for rollout and cleanup design.
- MCP tool responses and JSON findings can include `actions`; treat them as proposals, not authority.

## Skill Design Implications

Fallow should feed other skills as evidence:

- `repo-audit` separates configured gates from advisory inventories and records transition states.
- `architecture-standards` turns repeated findings into current-state failure modes and target-state rules.
- `diff-review` checks whether a branch improves the structural failure it claims to address.
- `spec-driven-development` converts audit evidence into transition slices, requirements, tasks, and fitness functions.

The key package lesson is not a specific command. It is that Fallow exposes multiple analysis lenses. Skills must preserve mode semantics before drawing architecture conclusions.

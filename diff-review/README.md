# Diff Review

Reviews local git diffs before they reach origin, with emphasis on bugs, security issues, regressions, and code quality risks.

Use this skill when you want a code-review pass on local changes, staged files, a branch diff, or a re-review after fixes.

Works well with `architecture-standards` when you want stronger architectural reasoning behind findings and remediation options.

## Folder Contents

- `SKILL.md` contains the full skill instructions and trigger rules.
- `agents/openai.yaml` defines the agent configuration for the skill.
- `references/` contains stack-specific review guidance used during investigation.

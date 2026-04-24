# Review And Architecture Skills

This repository contains three skills as sibling directories:

- `diff-review`
- `repo-audit`
- `architecture-standards`

## Contents

`diff-review`
- Reviews local git diffs for bugs, security issues, and code quality before pushing.
- Includes stack-specific review references plus the skill agent config.

`repo-audit`
- Runs full repository audits across correctness, security, architecture, performance, and maintainability.
- Includes stack-specific audit references plus the skill agent config.

`architecture-standards`
- Provides architecture guidance for design, refactoring, scaffolding, and architectural code review.
- Includes the skill definition and agent config.

## Layout

```text
.
├── architecture-standards/
│   ├── SKILL.md
│   └── agents/openai.yaml
├── diff-review/
│   ├── SKILL.md
│   ├── agents/openai.yaml
│   └── references/
├── repo-audit/
│   ├── SKILL.md
│   ├── agents/openai.yaml
│   └── references/
└── README.md
```

# Review And Architecture Skills

This repository contains three skills as sibling directories:

- `diff-review`
- `repo-audit`
- `architecture-standards`

## Contents

`diff-review`
- Reviews local git diffs for bugs, security issues, and code quality before pushing.
- Includes the skill definition, agent config, review references, and helper scripts.

`repo-audit`
- Runs full repository audits across correctness, security, architecture, performance, and maintainability.
- Includes stack-specific audit references plus the skill agent config.

`architecture-standards`
- Provides architecture guidance for design, refactoring, scaffolding, and architectural code review.
- Includes the skill definition and agent config.

## How They Work Together

- `diff-review` and `repo-audit` are the investigation skills. They focus on finding bugs, risks, regressions, and weak design decisions in real code.
- `architecture-standards` is the design and boundary guide. It helps shape remediation, evaluate architectural quality, and keep fixes proportionate to the actual problem.
- If `architecture-standards` is installed alongside the review skills, it can be used to strengthen investigation quality, architectural reasoning, and fix recommendations.
- `diff-review` and `repo-audit` still work independently if `architecture-standards` is not installed.

## Layout

```text
.
├── architecture-standards/
│   ├── README.md
│   ├── SKILL.md
│   └── agents/openai.yaml
├── diff-review/
│   ├── README.md
│   ├── SKILL.md
│   ├── agents/openai.yaml
│   ├── references/
│   └── scripts/
├── repo-audit/
│   ├── README.md
│   ├── SKILL.md
│   ├── agents/openai.yaml
│   └── references/
└── README.md
```

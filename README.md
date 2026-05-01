# Review And Architecture Skills

This repository contains four skills as sibling directories:

- `diff-review`
- `repo-audit`
- `architecture-standards`
- `fallow`

## Contents

`diff-review`
- Reviews local git diffs for bugs, security issues, and code quality before pushing.
- Includes the skill definition, agent config, stack references, review process references, and `scripts/review-preflight.sh`.

`repo-audit`
- Runs full repository audits across correctness, security, architecture, performance, and maintainability.
- Includes the skill definition, agent config, stack references, audit process references, and `scripts/audit-preflight.sh`.

`architecture-standards`
- Provides architecture guidance for design, refactoring, scaffolding, and architectural code review.
- Includes the skill definition, agent config, architecture reference packs, and `scripts/architecture-preflight.sh`.

`fallow`
- Guides free-version Fallow adoption, configuration, reruns, remediation, and interpretation for TypeScript/JavaScript codebase intelligence.
- Includes the skill definition, agent config, and Fallow workflow reference pack.

## How They Work Together

- `diff-review` and `repo-audit` are the investigation skills. They focus on finding bugs, risks, regressions, and weak design decisions in real code.
- `architecture-standards` is the design and boundary guide. It helps shape remediation, evaluate architectural quality, and keep fixes proportionate to the actual problem.
- `fallow` is the free-version static-analysis signal source for TypeScript/JavaScript repos. It helps surface dead code, duplication, health hotspots, audit gates, and baseline policy without relying on trial, paid, licensed, hosted, pro, or runtime-coverage features.
- If `architecture-standards` is installed alongside the review skills, it can be used to strengthen investigation quality, architectural reasoning, and fix recommendations.
- If `fallow` is installed alongside `repo-audit`, Fallow output can be recorded as audit evidence instead of being presented as raw tool output alone.
- The skills still work independently if companion skills are not installed.

## Layout

```text
.
├── architecture-standards/
│   ├── README.md
│   ├── SKILL.md
│   ├── agents/openai.yaml
│   ├── references/
│   │   ├── architecture-shapes.md
│   │   ├── layer-standards.md
│   │   └── ...
│   └── scripts/
│       └── architecture-preflight.sh
├── diff-review/
│   ├── README.md
│   ├── SKILL.md
│   ├── agents/openai.yaml
│   ├── references/
│   │   ├── nextjs.md
│   │   ├── review-workflow.md
│   │   └── ...
│   └── scripts/
│       └── review-preflight.sh
├── fallow/
│   ├── README.md
│   ├── SKILL.md
│   ├── agents/openai.yaml
│   └── references/
│       └── fallow-workflows.md
├── repo-audit/
│   ├── README.md
│   ├── SKILL.md
│   ├── agents/openai.yaml
│   ├── references/
│   │   ├── nextjs.md
│   │   ├── audit-workflow.md
│   │   └── ...
│   └── scripts/
│       └── audit-preflight.sh
└── README.md
```

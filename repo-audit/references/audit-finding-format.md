# Audit Finding Format

Use this when writing or resolving audit findings.

## Finding Types

IDs are stable forever: `{prefix}{turn}-{sequence}`.

- `B`: Bug.
- `S`: Security issue.
- `F`: Flag, suspicious but may be intentional.
- `O`: Observation, architecture/tech debt/refactoring opportunity.

Severity:

- Critical: must fix
- High: should fix soon
- Medium: should fix
- Low: nice to fix

Use `severity-calibration.md` when severity is ambiguous.

## Required Finding Fields

Each finding should include:

- ID, type, severity, file/line or subsystem
- what is happening
- root cause
- codebase implication and blast radius
- evidence
- solution options
- remediation radius
- prevention artifact
- investigation prompt

## Root Cause Prompts

Ask:

- conscious shortcut?
- inherited legacy pattern?
- framework/library misunderstanding?
- architecture boundary unclear?
- missing convention or enforcement?
- prior review/audit process gap?

## Codebase Implication

Explain:

- affected features/user flows
- affected packages/services/jobs
- upstream callers and downstream consumers
- 3/6/12 month maintenance impact
- operational/security/data risk
- adjacent workflows requiring revalidation
- whether it blocks future improvements

## Solution Options

Use where helpful:

- **Quick fix:** minimal safe patch.
- **Proper fix:** boundary/root-cause fix.
- **Strategic fix:** broader refactor/migration when justified.

For each option, name validation touchpoints: consumers, schemas, state transitions, permissions, retries, caching, migration safety, operations, and tests.

## Remediation Radius

Classify adjacent work:

- **Must fix now:** leaves live bug, broken dependent path, violated invariant, likely regression, or serious operational/security risk if skipped.
- **Should fix now if cheap/safe:** bounded fragility reduction near active work.
- **Defer:** broad refactor, speculative cleanup, style, or disproportionate architecture work.

## Prevention Artifact

Prefer one of:

- regression test
- stronger validation/type/schema
- invariant assertion/runtime guard
- lint/static/dependency rule
- observability/logging/alert
- helper extraction or risky duplication deletion
- migration/backfill guard

If none is appropriate, say why.

## Resolution Note

When resolving, include:

- how it was fixed
- adjacent work handled
- follow-on findings opened
- verification proving root cause is addressed
- prevention artifact
- sibling/non-primary/bypass paths checked

# Finding Format

Use this when writing or resolving findings.

## Finding Types

IDs are stable forever: `{prefix}{turn}-{sequence}`.

- `B`: Bug, something broken or likely to break.
- `S`: Security issue.
- `F`: Flag, suspicious but may be intentional.
- `O`: Observation, useful improvement or tech debt.

Severity applies to every type:

- Critical: must fix
- High: should fix soon
- Medium: should fix
- Low: nice to fix

Use `severity-calibration.md` when severity is ambiguous.

## Required Finding Fields

Each finding should include:

- ID, type, severity, file/line
- what is happening
- root cause
- codebase implication and blast radius
- concrete evidence
- solution options
- remediation radius
- prevention artifact
- investigation prompt if a decision is needed

## Root Cause Prompts

Ask:

- misunderstanding of framework/API?
- missed path in refactor?
- data model assumption that fails?
- copied code from a different context?
- original author only considered primary flow?
- architecture boundary unclear?

## Codebase Implication

Explain:

- affected user flows/features
- upstream callers and downstream consumers
- data corruption or persistence risk
- services/packages affected
- production consequence if shipped
- sibling pattern risk

## Solution Options

Prefer at least two when useful:

- **Quick fix:** minimal safe patch.
- **Proper fix:** boundary/root-cause fix.

For each option, name validation touchpoints: consumers, schemas, state transitions, permissions, retries, caching, migration safety, and tests.

## Remediation Radius

Classify adjacent work:

- **Must fix now:** leaves live bug, broken dependent path, violated invariant, or likely new regression if skipped.
- **Should fix now if cheap/safe:** bounded fragility reduction.
- **Defer:** broad refactor, speculative cleanup, style, or disproportionate architecture work.

## Prevention Artifact

Prefer one of:

- regression test
- stronger validation/type/schema
- invariant assertion/runtime guard
- lint/static rule
- observability/logging/alert
- helper extraction or risky duplication deletion

If none is appropriate, say why.

## Resolution Note

When resolving, include:

- how it was fixed
- adjacent work handled
- follow-on findings opened
- verification that proves root cause is addressed
- prevention artifact
- sibling/non-primary paths checked

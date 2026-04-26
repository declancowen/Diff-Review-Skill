# Verification Guidance

Use this to choose and assess checks for a repo audit.

## Verification Matrix

| Risk | Minimum expectation |
|------|---------------------|
| Low | Targeted tests/repro plus fastest relevant safety net |
| Medium | Targeted tests, core safety nets, and one broader check |
| High | Targeted tests, broader package/integration coverage, core safety nets, build/contract checks, compatibility and release-safety review |
| Critical | High-level checks plus strongest available verification for failure modes, rollback, migrations, and operational readiness |

If expected verification cannot run, state why and lower confidence.

## Common Commands

Choose repo-appropriate commands:

```bash
pnpm test
pnpm typecheck
pnpm lint
pnpm build
pnpm exec vitest run path/to/test
pytest path/to/tests
go test ./...
cargo test
bundle exec rspec
```

## Test Adequacy

Ask:

- Does the test cover the actual failure mode?
- Does it cover a sibling/non-primary/bypass path?
- Does it prove the bug family is closed or only one path?
- Are mocks hiding the integration edge?
- Did changed tests weaken assertions or encode the new bug?

Passing tests are strong evidence only when they exercise the risky invariant or a convincing proxy.

## Audit-Specific Checks

For repo-level audits, consider:

- typecheck/lint/build
- package/workspace tests
- contract/schema tests
- migration/backfill dry-runs where possible
- dependency/security audit if relevant
- CI workflow inspection
- smoke/e2e only for critical journeys, not as a replacement for focused tests

## Changed Tests

Review changed tests like code:

- assertion strength
- fixture realism
- removed coverage
- snapshot churn
- mocks that hide real contracts

## Generated Artifacts

When lockfiles, generated clients, migrations, snapshots, or compiled artifacts change, verify they match source changes and are not accidental churn.

## Temporary Repro

One-off scripts or repro notes belong in the audit turn and should be deleted/ignored unless the user explicitly wants them preserved. Permanent regression coverage belongs in normal test directories.

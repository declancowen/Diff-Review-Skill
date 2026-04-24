# CI/CD Review Criteria

Covers GitHub Actions, GitLab CI, CircleCI, and similar.

## Secret and permission exposure
- Secrets referenced in workflow that aren't set in the repo/org settings — silent failures
- `GITHUB_TOKEN` permissions too broad — use `permissions:` block with minimum required
- Secrets logged via `echo`, debug mode, or error output — check `run` steps carefully
- Third-party actions at `@master` or `@main` — pin to specific commit SHA for supply chain safety
- `pull_request_target` trigger with checkout of PR code — allows untrusted code to access secrets
- Workflow dispatch inputs not validated — can be abused if workflow has elevated permissions

## Workflow logic
- Missing `concurrency` group — multiple runs of same workflow conflict
- `continue-on-error: true` masking failures that should break the build
- Caching keys that don't include lockfile hash — stale dependencies
- Steps that depend on previous steps without explicit `needs` or `if` conditions
- Matrix builds without failure isolation — one failure cancels all
- Timeout not set — stuck jobs consume runner minutes indefinitely

## Build and test
- Tests skipped or commented out in CI config
- Test commands that pass even when tests fail (exit code swallowed)
- Build artifacts not uploaded or cached between jobs — redundant work
- Node/Python/Go version not pinned — inconsistent across runs
- Missing linting or type checking steps that exist locally

## Deployment
- Deploy steps that run on all branches instead of protected branches only
- Missing environment protection rules (approvals, wait timers)
- Rollback mechanism not defined — if deploy fails, what happens?
- Database migrations running in CI without testing against actual schema
- Environment variables different between CI and production — drift risk

## Performance
- Installing all dependencies when only a subset is needed for the job
- Docker builds without layer caching in CI
- Running full test suite on docs-only changes — add path filters
- Large artifacts uploaded/downloaded unnecessarily between jobs

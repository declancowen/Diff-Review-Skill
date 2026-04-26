# Cross-Cutting Standards

Use this when checking security, performance, reliability, observability, testability, or cost.

## Security And Privacy

- Enforce authentication and authorization server-side.
- Prefer least privilege for users, services, jobs, and infrastructure roles.
- Default deny where risk justifies it.
- Use RBAC for broad role access; add ABAC/relationship policies when access depends on resource attributes, ownership, hierarchy, or tenant context.
- Validate input shape at the edge; enforce business rules inward.
- Encode/sanitize output where injection risk exists.
- Keep secrets out of code, logs, analytics, and client bundles.
- Encrypt sensitive data where risk/compliance requires it.
- Minimize sensitive data collection and retention.
- Make tenancy isolation explicit in queries, cache keys, jobs, and mutations.

Common failures:

- authorization only in frontend
- scattered inconsistent permission checks
- tenant scoping by convention instead of guardrails
- sensitive data in logs or analytics

## Performance And Scale

- Define latency and throughput expectations for critical paths.
- Remove waterfall and N+1 patterns before adding caches.
- Parallelize only independent work, with bounded concurrency.
- Batch reads/writes when it materially reduces roundtrips.
- Use projections, partial selects, and streaming for large payloads.
- Cache only with explicit owner, key scope, invalidation, TTL, warmup, and fallback behavior.
- Measure hot paths before complex optimization.

Common failures:

- cache without invalidation
- unbounded page sizes or in-memory full dataset loads
- excessive fan-out or pool exhaustion
- optimizing theoretical hot spots while ignoring measured bottlenecks

## Reliability And Resilience

- Time out external calls.
- Retry only transient failures with backoff and jitter.
- Make retried operations idempotent.
- Protect against duplicate delivery and partial failure.
- Use graceful degradation when business semantics allow it.
- Use backpressure/admission control when the system can be overwhelmed.
- Keep state changes and emitted side effects consistent through outbox/transactional patterns where needed.
- Use compensating actions when distributed work cannot be atomic.

Common failures:

- aggressive/infinite retries
- side effects before durable commit
- silent divergence after partial failure
- async work without status visibility or dead-letter recovery

## Observability And Operability

- Emit structured logs with stable keys.
- Capture metrics for traffic, errors, latency, saturation, and business-critical outcomes.
- Trace critical paths across service/job boundaries.
- Carry correlation IDs across requests and background work.
- Define health/readiness/dependency checks where needed.
- Alert on user/business impact, not noisy raw thresholds.
- Make operational ownership visible for critical systems.
- Prefer feature flags for sensitive rollout/rollback.

Common failures:

- verbose but unqueryable logs
- metrics with no actionability
- critical background flows with no visibility

## Maintainability And Testability

- Keep responsibilities crisp and public surfaces narrow.
- Put core logic where it can be tested cheaply and deterministically.
- Use unit tests for rules, integration tests for boundaries, contract tests for integrations, and e2e tests for critical journeys.
- Use architecture tests/lint rules when boundaries matter and are repeatedly violated.
- Name modules after capabilities, not generic technical buckets.
- Prefer explicit control flow over hidden framework magic when correctness matters.

Common failures:

- too many e2e tests for logic that should be unit tested
- shared test helpers hiding architecture problems
- folder layering without dependency layering

## Efficiency And Cost

- Use infrastructure proportional to the problem.
- Avoid service sprawl, duplicated storage, and chatty internal APIs.
- Understand cost of retention, indexing, replication, fan-out, and egress.
- Design archival, retention, and purge before large datasets accumulate.
- Favor simpler operations unless complexity buys a clear benefit.

Common failures:

- splitting services before workload/team needs justify it
- retaining all historical data forever
- internal call chains adding latency/cost without value

# Java / Kotlin Backend Review Criteria

Covers Spring Boot, Micronaut, Quarkus, and general JVM backend.

## Spring-specific
- `@Transactional` missing on methods that should be atomic
- `@Transactional` on private methods — won't work due to proxy-based AOP
- `@Autowired` on fields instead of constructor injection — harder to test
- Missing `@Validated` or `@Valid` on request DTOs
- `@Async` without custom executor — uses default which may have limited pool size
- Profile-specific beans not properly scoped — leaking dev config to production
- `@RequestMapping` without explicit HTTP method — accepts all methods

## Kotlin-specific
- Nullable types used where non-null is safe — unnecessary null checks
- `!!` non-null assertion without justification — will throw NPE at runtime
- Data class used for mutable state — data classes are for immutable value objects
- Coroutine scope not structured — use `coroutineScope` or `supervisorScope`, not `GlobalScope`
- Extension functions that are too broad — polluting the namespace

## Database and JPA
- N+1 queries — missing `@EntityGraph` or `JOIN FETCH`
- `FetchType.EAGER` on collections — loads all related entities always
- Missing `@Column(nullable = false)` where null shouldn't be allowed
- JPA entity equals/hashCode based on ID — breaks before persist (ID is null)
- Missing database index annotations on frequently queried fields
- Flyway/Liquibase migrations that are destructive without rollback plan

## Concurrency
- Shared mutable state without synchronisation — race conditions
- `synchronized` blocks too broad (performance) or too narrow (still racy)
- `CompletableFuture` chains without exception handling
- Thread pool sizes not configured — defaults may not suit workload
- `volatile` missing on fields accessed by multiple threads

## Security
- SQL injection via string concatenation in JPQL or native queries
- Missing input validation — request body fields not checked
- CORS configuration too permissive in `WebMvcConfigurer`
- Security filter chain order — new filters in wrong position
- Sensitive data in logs — PII, tokens, passwords
- Dependencies with known CVEs — check with `mvn dependency-check:check` or `gradle dependencyCheckAnalyze`

## Error handling
- Generic exception handlers catching too broadly — `catch (Exception e)` hides bugs
- HTTP status codes wrong — 200 for errors, 500 for validation failures
- Stack traces returned to client in error responses
- Custom exceptions without proper HTTP status mapping

## Performance
- Blocking calls in reactive chains (WebFlux) — defeats the purpose
- Missing connection pool configuration (HikariCP defaults may not be optimal)
- JSON serialisation of large object graphs — missing `@JsonIgnore` or DTOs
- Startup time — unnecessary bean scanning or eager initialisation

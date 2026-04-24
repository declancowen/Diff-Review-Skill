# PHP / Laravel Review Criteria

## Eloquent and database
- N+1 queries — missing `with()` or `load()` for relationships
- Mass assignment vulnerability — `$fillable` or `$guarded` not updated for new columns
- Raw queries with string concatenation — SQL injection (use query builder bindings)
- Missing database index on columns used in `where`, `orderBy`, or join conditions
- Migrations without `down()` method — can't rollback
- `firstOrCreate` / `updateOrCreate` without unique constraints — race condition duplicates
- Soft deletes not considered in queries — missing `withTrashed()` where needed

## Controllers and routing
- Authorisation missing on new routes — `Gate`, `Policy`, or middleware not applied
- Form request validation missing or incomplete for new fields
- Route model binding type mismatch — expecting `int` but receiving `string`
- API resource/transformer not updated when model attributes change
- Missing rate limiting on sensitive endpoints

## Security
- `{!! !!}` Blade syntax with user input — XSS (use `{{ }}` for escaped output)
- CSRF token validation disabled on routes that need it
- Mass assignment — `$request->all()` passed directly to `create()` or `update()`
- File upload without validation on type, size, and filename sanitisation
- `env()` called outside of config files — returns `null` when config is cached
- Debug mode or error detail exposure in production config

## Queues and jobs
- Jobs without `tries`, `timeout`, or `backoff` configuration
- Non-idempotent jobs — duplicate execution causes data corruption
- Large payloads serialised in job — pass IDs and re-fetch from database
- Failed job handling missing — no `failed()` method or notification

## Service container and architecture
- Circular dependency injection — constructor injection loop
- Singleton binding when request-scoped is needed (or vice versa)
- Service provider `register()` resolving other services — not yet registered
- Fat controllers — business logic should be in services, actions, or domain layer

## Performance
- Missing caching on expensive queries or API calls
- Eager loading not used in API endpoints returning collections
- Missing pagination — `all()` or `get()` without `paginate()` on list endpoints
- Blade views with inline queries — should be passed from controller

## Config and deployment
- `.env` changes that need to be reflected in production
- Config cache invalidation needed after config file changes
- Composer dependency changes — `composer.lock` committed?
- PHP version compatibility of new language features

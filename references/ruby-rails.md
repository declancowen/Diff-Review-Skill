# Ruby on Rails Review Criteria

## Active Record
- N+1 queries — missing `includes`, `preload`, or `eager_load`
- `where` with string interpolation — SQL injection risk (use parameterised queries)
- Missing database index on columns used in `where`, `order`, or `joins`
- Migrations without rollback — `change` method can't reverse all operations
- Destructive migrations without data backfill plan
- `update_all` or `delete_all` without sufficient `where` clause — affects entire table
- Callbacks (`before_save`, `after_create`) with side effects that make testing brittle
- Missing validation at model level — relying only on controller/form validation
- `find` vs `find_by` — `find` raises exception, `find_by` returns nil

## Controllers
- Strong parameters not updated for new attributes — mass assignment gap
- Business logic in controllers that belongs in models or service objects
- Missing authorisation checks (Pundit, CanCanCan) on new actions
- `before_action` filters too broad or too narrow for new routes
- Response format not handled — missing `respond_to` for JSON/HTML

## Security
- `html_safe` or `raw` used on user-supplied content — XSS
- CSRF protection disabled without justification (`skip_before_action :verify_authenticity_token`)
- Session configuration changes — cookie settings, expiry
- `permit!` on params — allows all attributes, bypasses strong parameters
- Rack middleware changes affecting security headers

## Background jobs
- Jobs without error handling or retry configuration
- Non-idempotent jobs — running twice produces incorrect results
- Large objects serialised into job arguments (should pass IDs and re-fetch)
- Missing queue specification — all jobs on default queue

## Routes
- Routes exposed that should be admin-only or internal
- Nested resources too deep (> 2 levels)
- Missing constraints on route params (format, ID pattern)

## Performance
- Queries in views/partials — should be in controller or presenter
- Missing caching (`fragment_cache`, `Russian doll caching`) on expensive partials
- Asset pipeline or Webpacker changes that affect bundle size
- Missing pagination on index actions — loading all records

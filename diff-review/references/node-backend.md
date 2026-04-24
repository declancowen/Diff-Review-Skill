# Node.js Backend Review Criteria

Applies to Express, Fastify, Hono, NestJS, and other Node.js server frameworks.

## Middleware and routing
- Middleware ordering — auth middleware must come before protected route handlers
- Error-handling middleware missing or in wrong position (must be last, must have 4 params in Express)
- `async` route handlers without try/catch or async error wrapper — unhandled rejections crash the process
- Route path conflicts — overlapping patterns where order determines which matches
- Missing `return` after `res.send()` / `res.json()` — code continues executing after response sent

## Input validation
- Request body, params, and query not validated — use zod, joi, or class-validator
- Type coercion issues — `req.params.id` is always a string, not a number
- Missing content-type checks on endpoints that expect JSON
- File upload size limits not configured — denial of service risk
- Array or nested object inputs not validated for depth/size

## Authentication and authorisation
- JWT verification without checking expiry, issuer, or audience
- Auth tokens stored in cookies without `httpOnly`, `secure`, `sameSite` flags
- Role/permission checks missing on new endpoints
- Session fixation — session not regenerated after login
- Rate limiting missing on auth endpoints (login, password reset)

## Database
- Raw SQL queries with string interpolation — SQL injection
- N+1 queries — fetching related data in a loop instead of a join or batch
- Connection pool not configured or pool size too large
- Missing transaction wrapping for multi-step operations that should be atomic
- ORM queries without `.limit()` — could return entire tables

## Error handling
- Stack traces or internal error details leaked in production responses
- Generic 500 errors without logging the actual error
- `process.exit()` in request handlers — kills the entire server
- Unhandled promise rejections not caught globally

## Security
- CORS configured too broadly (`origin: '*'` on authenticated endpoints)
- Helmet or equivalent security headers middleware missing
- `eval()` or `new Function()` with user input
- Directory traversal possible via unsanitised file path params
- Secrets loaded from environment without validation at startup — fails at runtime instead
- Dependencies with known vulnerabilities — `npm audit`

## Performance
- Synchronous file operations (`fs.readFileSync`) in request handlers — blocks the event loop
- Large JSON payloads serialised/parsed without streaming
- Missing response compression (gzip/brotli)
- Memory leaks from growing arrays, caches, or event listeners without bounds
- Heavy computation without offloading to a worker thread

## API design
- Breaking changes to existing endpoints without versioning
- Inconsistent error response format across endpoints
- Missing pagination on list endpoints
- Status codes that don't match the response (200 for errors, 404 for auth failures)

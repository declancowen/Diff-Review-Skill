# Supabase Review Criteria

## Authentication
- Auth state changes without checking `session` for null
- Missing `onAuthStateChange` cleanup (unsubscribe on unmount)
- Token refresh logic — is the client handling expired tokens?
- OAuth redirect URLs changed but not updated in Supabase dashboard config
- Sign-up flows that don't handle email confirmation state

## Row Level Security (RLS)
- New tables without RLS policies — this is a critical security gap
- Policy changes that widen access (e.g. switching from `auth.uid()` to `true`)
- Policies that reference `auth.uid()` on tables that should allow anonymous access
- Missing policies for INSERT/UPDATE/DELETE (easy to forget if you only wrote SELECT)
- `service_role` key used client-side — this bypasses RLS entirely

## Database queries
- `.single()` on queries that might return 0 or multiple rows — will throw
- Missing `.eq()` filters that could return the entire table
- `SELECT *` when only a few columns are needed (bandwidth, especially on mobile)
- Missing error handling on `.from()` chains — always check `error` before using `data`
- Realtime subscriptions without cleanup on unmount
- `.upsert()` without specifying `onConflict` — relies on primary key by default

## Edge Functions
- Secrets referenced but not set in the environment
- CORS headers missing or misconfigured
- No input validation on request body
- Missing auth token verification (`req.headers.get('Authorization')`)

## Storage
- Public bucket for files that should be private
- Missing file size or type validation before upload
- Storage policies not matching the bucket's access pattern
- Signed URLs with excessively long expiry times

## Migrations
- Destructive changes (DROP COLUMN, DROP TABLE) without a data migration plan
- Missing `IF EXISTS` / `IF NOT EXISTS` guards
- Index additions on large tables without `CONCURRENTLY`
- Foreign key changes that could orphan existing data
- Type changes that could fail on existing data (e.g. VARCHAR to INT)

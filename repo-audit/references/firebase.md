# Firebase Review Criteria

## Security Rules (Firestore / Realtime DB / Storage)
- New collections or paths without corresponding security rules — open by default
- Rules using `allow read, write: if true` — exposes data to anyone
- `request.auth` checks missing — unauthenticated access possible
- Rules that don't validate data shape — malformed documents can be written
- Overlapping rules where a broader rule unintentionally permits access
- Storage rules not restricting file size or content type on upload

## Firestore
- Missing composite indexes for queries with multiple `where` and `orderBy` clauses — will fail at runtime
- Unbounded queries without `.limit()` — reads entire collection
- `onSnapshot` listeners not detached on component unmount — memory leak and billing cost
- Document writes without checking existence first (overwrite vs merge vs create)
- Transactions that read documents not involved in the transaction — can't guarantee consistency
- Subcollection data not deleted when parent document is deleted — orphaned data

## Authentication
- Auth state changes not handled on app start — user may be logged in but UI shows logged out
- Sign-in methods enabled in console but not restricted by domain/provider in rules
- Custom claims not refreshed after update — user keeps old permissions until token refresh
- Email enumeration protection not enabled
- Password requirements too weak in client-side validation

## Cloud Functions
- Cold start impact — heavy initialisation at module level delays first invocation
- Missing input validation on callable functions — trust nothing from the client
- Secrets hardcoded instead of using Secret Manager or environment config
- Background function retries not handled — function must be idempotent
- CORS not configured on HTTP functions called from browser
- Region not specified — defaults may not match other Firebase resources

## Performance and billing
- Reads on every page load when data could be cached client-side
- Large documents when data should be in subcollections (1MB document limit)
- Cloud Function invocations that could be replaced by security rules logic
- Firestore `in` queries with more than 30 values (limit)
- Storage downloads without CDN caching headers

## Hosting and config
- `firebase.json` changes affecting rewrites, redirects, or function routing
- Environment-specific config not separated (dev vs staging vs prod)
- `.firebaserc` pointing at wrong project

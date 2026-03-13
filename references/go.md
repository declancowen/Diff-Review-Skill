# Go Review Criteria

## Common bugs
- Goroutine leaks — goroutines launched without cancellation via `context.Context`
- Loop variable capture in goroutines — `go func() { use(v) }()` captures reference (fixed in Go 1.22+ but check version)
- `defer` in a loop — deferred calls stack until function returns, not loop iteration
- Nil pointer dereference — missing nil checks on interface values and pointer returns
- Slice append gotchas — appending to a slice that shares underlying array
- Channel deadlocks — sends/receives without corresponding counterpart

## Error handling
- Errors ignored with `_` — every error should be handled or explicitly documented why not
- Error wrapping without context — `return err` instead of `return fmt.Errorf("doing X: %w", err)`
- Sentinel errors compared with `==` instead of `errors.Is()`
- Type assertions without the `ok` check — will panic on wrong type
- `log.Fatal` or `os.Exit` in library code — caller can't handle the error

## Concurrency
- Shared data accessed from multiple goroutines without sync (mutex, channel, atomic)
- `sync.WaitGroup` counter wrong — `Add()` called inside goroutine instead of before
- `sync.Mutex` copied (value receiver on struct containing mutex)
- Context not propagated through the call chain

## Security
- SQL injection via string concatenation instead of parameterised queries
- `crypto/md5` or `crypto/sha1` used for security purposes
- Hardcoded credentials or tokens
- `net/http` handlers without timeouts — slow loris vulnerability
- User input passed to `os/exec` without sanitisation

## Performance
- String concatenation in loops — use `strings.Builder`
- Unnecessary allocations in hot paths — check with `go test -bench`
- JSON marshaling/unmarshaling where a more efficient codec would help
- Missing `sync.Pool` for frequently allocated objects in high-throughput paths

## Code quality
- Exported functions without doc comments
- Package-level variables that should be constants
- Stuttered names (`user.UserService` instead of `user.Service`)
- Overcomplicated interfaces — Go favours small, focused interfaces

# Rust Review Criteria

## Common bugs
- `.unwrap()` or `.expect()` on `Result`/`Option` in non-test code — handle errors properly
- Integer overflow in release builds (wraps silently, unlike debug which panics)
- Off-by-one in slice indexing — will panic at runtime
- `Clone` used to satisfy the borrow checker where a reference would work
- Deadlocks from nested `Mutex::lock()` calls
- `Drop` implementations with side effects that depend on drop order

## Memory and ownership
- Unnecessary `.clone()` — especially on large data structures
- Holding a `MutexGuard` across an `.await` point — blocks the executor
- `Rc`/`Arc` reference cycles causing memory leaks (need `Weak`)
- Large stack allocations — consider `Box` for big structs
- Lifetime annotations that are overly restrictive or overly permissive

## Async
- Blocking calls (`std::thread::sleep`, synchronous I/O) inside async functions
- Missing `.await` — returns a `Future` instead of executing it
- `tokio::spawn` without propagating errors from the spawned task
- Mixing async runtimes (e.g. `tokio` and `async-std`)

## Security
- `unsafe` blocks — is the safety invariant documented? Is it actually needed?
- Raw pointer derefs without bounds checking
- Unchecked user input in format strings
- Dependencies with known vulnerabilities — `cargo audit`
- Cryptographic operations using non-constant-time comparisons

## Error handling
- `?` operator used without context — add `.map_err()` or `anyhow::Context`
- Custom error types without `Display` or `Error` implementation
- Panic paths in library code — libraries should return `Result`, not panic
- Error variants that don't carry enough context to debug

## Performance
- Unnecessary heap allocations — `String` where `&str` works, `Vec` where slice works
- Missing `#[inline]` on small hot-path functions in library crates
- Iterators collected into `Vec` just to iterate again — chain iterators instead
- `HashMap` with a small number of entries — `Vec` of tuples is often faster

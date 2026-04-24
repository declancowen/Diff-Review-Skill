# Python Review Criteria

## Common bugs
- Mutable default arguments (`def fn(items=[])`) — shared across calls
- Late binding closures in loops — lambda/function captures variable reference, not value
- `except Exception` or bare `except` swallowing errors silently
- `is` vs `==` — identity vs equality confusion (especially with integers > 256)
- Dictionary keys modified while iterating
- `datetime.now()` without timezone — naive datetimes cause subtle bugs

## Type safety
- Missing type hints on public function signatures
- `Any` used where a concrete type or `Union` would work
- `Optional[X]` without null checks before use
- Type: ignore comments hiding real issues
- Inconsistent return types (sometimes returns None, sometimes a value)

## Security
- `eval()`, `exec()`, or `pickle.loads()` on untrusted input
- SQL queries built with string formatting instead of parameterised queries
- `subprocess` calls with `shell=True` and user-controlled input
- Hardcoded secrets, credentials, or connection strings
- `DEBUG = True` or verbose error output left in production code
- Insecure `yaml.load()` without `Loader=SafeLoader`

## Async
- Blocking calls (`time.sleep`, synchronous I/O) inside async functions
- Missing `await` on coroutines — returns a coroutine object instead of the result
- Async context managers not used with `async with`
- Task cancellation not handled — `CancelledError` swallowed

## Dependencies
- New packages added without pinning versions
- `requirements.txt` and `pyproject.toml` out of sync
- Import of deprecated stdlib modules (e.g. `distutils`, `imp`)

## Code quality
- Functions doing too many things — should be decomposed
- Magic numbers without named constants
- Copy-pasted code blocks that should be extracted
- f-strings or `.format()` in logging calls (use `%s` style for lazy evaluation)
- `print()` statements left in (should be `logging`)

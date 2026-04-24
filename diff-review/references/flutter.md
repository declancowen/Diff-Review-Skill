# Flutter Review Criteria

## Widget lifecycle
- `dispose()` missing cleanup for controllers, streams, animation controllers
- `setState()` called after `dispose()` — check async callbacks that fire late
- `GlobalKey` used unnecessarily — causes widget tree rebuild overhead
- `const` constructors missing — prevents unnecessary rebuilds
- `didUpdateWidget` not handling prop changes that need controller updates

## State management
- State held in widget that should be lifted or managed externally (Provider, Riverpod, Bloc)
- `ChangeNotifier` without calling `notifyListeners()` after mutations
- Stream subscriptions without cancellation in `dispose()`
- Riverpod: `ref.watch` used where `ref.read` is appropriate (and vice versa)
- Bloc: events emitted without corresponding state transitions

## Performance
- `ListView` without `ListView.builder` for dynamic/large lists — loads all items at once
- Rebuilds triggered on entire widget tree — missing `const`, `Selector`, or granular state
- Images without caching (`cached_network_image` or equivalent)
- Heavy computation on the UI isolate — should use `compute()` or isolates
- Animations without `RepaintBoundary` causing overdraw

## Platform-specific
- Platform channel calls without error handling for `MissingPluginException`
- iOS-specific or Android-specific code without platform checks
- Permission requests without graceful denial handling
- Deep link configuration mismatches between `AndroidManifest.xml` and `Info.plist`

## Navigation
- Named routes without type-safe arguments — use typed route generation
- Navigation stack not cleared on logout (user can back-navigate to authenticated screens)
- `Navigator.pop` without checking if there's something to pop

## Security
- API keys or secrets in Dart source (should be in env config or native keychain)
- `http` URLs where `https` should be used
- Insecure storage — using `SharedPreferences` for sensitive data instead of `flutter_secure_storage`
- WebView without restricting JavaScript or navigation
- Certificate pinning not configured for sensitive API calls

## Dart-specific
- `dynamic` type used where a concrete type would work
- `late` variables that might not be initialised before access
- Null safety bypassed with `!` operator without justification
- Futures not awaited — fire-and-forget without error handling
- String interpolation in performance-critical loops

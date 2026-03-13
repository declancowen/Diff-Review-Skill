# Android Native (Kotlin) Review Criteria

## Lifecycle
- `Activity` or `Fragment` holding references that survive configuration changes — use ViewModel
- `onSaveInstanceState` not saving critical UI state
- `LiveData` observed with wrong lifecycle owner (Activity vs Fragment viewLifecycleOwner)
- `Flow` collected in lifecycleScope without `repeatOnLifecycle` — collects when backgrounded
- Work started in `onResume` not cancelled in `onPause`

## Compose-specific
- `remember` without `key` parameter when the cached value depends on changing input
- Side effects (`LaunchedEffect`, `DisposableEffect`) with wrong key — runs too often or not enough
- State hoisting violations — state owned at wrong level of the composition tree
- `mutableStateOf` used outside of `remember` — state lost on recomposition
- `derivedStateOf` missing where recomputation could be avoided
- `Modifier` order matters — background before padding gives different result than padding before background

## Memory and performance
- Bitmap loading without downsampling or caching (Coil/Glide)
- RecyclerView without ViewHolder pattern or DiffUtil
- Large object allocations in `onDraw` or frequently called methods
- Missing `@JvmStatic` on companion object methods used from Java interop
- String concatenation in loops — use `StringBuilder`

## Concurrency
- `GlobalScope` used instead of structured concurrency (viewModelScope, lifecycleScope)
- Dispatchers.Main used for IO operations
- Missing `withContext(Dispatchers.IO)` for disk/network calls
- Coroutine exception handler not set — unhandled exceptions crash silently
- `runBlocking` on the main thread — ANR risk

## Security
- Secrets in `BuildConfig` or `strings.xml` — visible in the APK
- WebView with `setJavaScriptEnabled(true)` without content restrictions
- `android:exported="true"` on components that should be internal
- Cleartext traffic allowed without justification in network security config
- SQL injection via raw queries instead of parameterised Room queries
- SharedPreferences for sensitive data — use EncryptedSharedPreferences

## Navigation
- Deep link definitions in `AndroidManifest.xml` changed without verifying `assetlinks.json`
- Navigation arguments passed as strings when Safe Args should be used
- Back stack not cleared on logout — user can navigate back to authenticated screens
- Fragment transactions without `commitAllowingStateLoss` consideration

## Permissions
- Runtime permissions requested without rationale explanation
- `shouldShowRequestPermissionRationale` not checked
- Missing handling for "Don't ask again" state
- New permissions added in `AndroidManifest.xml` without corresponding runtime checks
- Target SDK upgrade implications on permission behaviour

## Build and config
- `minSdkVersion` implications of new API usage — is there a fallback?
- ProGuard/R8 rules missing for new reflection-based libraries
- Gradle dependency versions inconsistent across modules
- `versionCode` not bumped (required for Play Store uploads)

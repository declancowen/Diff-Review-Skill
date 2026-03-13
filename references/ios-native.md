# iOS Native (Swift/UIKit/SwiftUI) Review Criteria

## Memory management
- Strong reference cycles — delegates, closures capturing `self` without `[weak self]`
- `@ObservedObject` used where `@StateObject` should be (recreated on parent re-render)
- Large images loaded without downsampling — `UIImage(named:)` caches aggressively
- Notification center observers not removed in `deinit`
- Timer or CADisplayLink not invalidated on dealloc

## SwiftUI-specific
- `@State` on reference types — use `@StateObject` or `@Observable`
- `body` computed property doing heavy work — should extract or cache
- `onAppear` used for one-time setup that should be in `.task` or `init`
- Missing `Identifiable` conformance on list items — causes incorrect diffing
- Environment values accessed before they're injected
- NavigationStack path state management — are paths correctly maintained?

## UIKit-specific
- `viewDidLoad` vs `viewWillAppear` — setup that needs to run on every appearance misplaced
- Autolayout constraints added without removing old ones (constraint conflicts)
- Table/collection view cell reuse not handled — stale data in recycled cells
- Main thread violations — UI updates from background threads

## Concurrency
- `Task` without cancellation handling — check `Task.isCancelled`
- `@MainActor` missing on UI-updating code called from async context
- Data races — shared mutable state accessed from multiple actors/threads
- `DispatchQueue.main.async` in modern async/await code — mix of paradigms
- Sendable conformance missing on types crossing actor boundaries

## Security
- Keychain access without proper access control flags
- `NSAllowsArbitraryLoads` set to YES in Info.plist (disables ATS)
- User data stored in UserDefaults instead of Keychain
- Jailbreak detection missing for sensitive financial apps
- Biometric auth without fallback handling

## App lifecycle
- Background task not ending properly — `endBackgroundTask` not called
- Push notification registration without handling denial
- Universal Links / Associated Domains config changes not matching server
- Scene-based lifecycle events not handled (multi-window iPadOS)

## Permissions
- Privacy usage descriptions missing in Info.plist for new capabilities
- Permission requests at app launch instead of contextually
- Missing handling for "limited" photo access (PHPicker)

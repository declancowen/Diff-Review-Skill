# Angular Review Criteria

## Change detection
- Components using `Default` change detection strategy when `OnPush` would be more appropriate
- Mutable object references not creating new objects — `OnPush` won't detect changes
- `ChangeDetectorRef.detectChanges()` used as a bandaid — usually indicates a deeper design issue
- Async pipe not used — manual subscriptions mean manual change detection management
- Heavy computation in templates — should be moved to component logic or pipes

## RxJS and subscriptions
- Subscriptions not unsubscribed — memory leaks on component destroy
- Missing `takeUntil`, `takeUntilDestroyed`, or async pipe for automatic cleanup
- Nested subscriptions instead of using `switchMap`, `mergeMap`, `concatMap`
- `subscribe()` with no error handler — unhandled errors break the observable chain
- `BehaviorSubject` used where `Subject` would suffice (unnecessary initial value)
- Cold observables subscribed to multiple times unintentionally

## Dependency injection
- Services provided in root when they should be component-scoped (or vice versa)
- Circular dependency injection — often indicates architecture issues
- `@Optional()` decorator missing where service might not be available
- `providedIn: 'root'` on services that should be lazy-loaded with their module

## Forms
- Reactive forms with missing validators on required fields
- Template-driven and reactive forms mixed in the same component
- Form control names out of sync with the form group definition
- Missing `updateOn: 'blur'` or `'submit'` causing excessive validation on keystroke

## Security
- `bypassSecurityTrustHtml` or similar sanitisation bypass without justification
- HTTP interceptors modified — could affect auth token attachment globally
- Route guards that check auth client-side without server enforcement
- `innerHTML` binding without sanitisation

## Performance
- Large `*ngFor` lists without `trackBy` — full DOM re-render on data change
- Lazy loading not configured for feature modules
- Signals not used where reactive state would benefit (Angular 17+)
- HTTP requests without caching strategy — repeated identical calls

## Module and routing
- Route definitions changed without updating lazy loading boundaries
- Guard logic that doesn't handle async properly
- Standalone components not properly importing their dependencies
- Module imports that pull in the entire library when tree-shakeable alternative exists

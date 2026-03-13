# Svelte / SvelteKit Review Criteria

## Reactivity (Svelte 5 runes / Svelte 4)
- `$state` rune not used for reactive declarations (Svelte 5) or `$:` missing for derived values (Svelte 4)
- `$derived` returning stale values due to missing dependency tracking
- `$effect` without cleanup — returned cleanup function missing for subscriptions/timers
- Reassigning reactive arrays/objects — needs `$state` or assignment to trigger reactivity
- Stores subscribed to with `$` prefix but not auto-unsubscribed in non-component contexts

## SvelteKit-specific
- `+page.server.ts` vs `+page.ts` — server-only data loading in the wrong file
- `load` functions without error handling or proper types
- Form actions without CSRF protection or input validation
- `$env/static/private` imported in client-side code — build will fail but worth flagging
- Hooks (`hooks.server.ts`) changes affecting global request handling
- `+layout` data not being cascaded correctly to child routes

## Component patterns
- Props without default values where undefined would cause issues
- Event dispatching without typed events — `createEventDispatcher<Events>()`
- `bind:` directives creating unexpected two-way data flow
- Slots without fallback content where empty state matters
- Component lifecycle (`onMount`, `onDestroy`) not cleaning up side effects

## Performance
- `{#each}` blocks without `(key)` expression — causes full list re-render
- Large components that should be split for code-splitting
- Transitions applied to elements that don't need them (animation overhead)
- `$effect` or `$:` blocks triggering expensive work without debouncing

## Security
- `{@html}` with unsanitised user content — XSS vector
- Client-side route protection without server-side enforcement in hooks
- Sensitive data returned from `load` functions that should be server-only
- API endpoints (`+server.ts`) without auth checks or input validation

## SSR
- Browser-only APIs (window, document, localStorage) called without SSR guards
- Hydration mismatches — server and client rendering different output
- `onMount` used for critical data that should be in `load` for SSR

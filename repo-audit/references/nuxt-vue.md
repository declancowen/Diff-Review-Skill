# Vue / Nuxt Review Criteria

## Reactivity
- Mutating reactive objects without Vue tracking — adding new properties to `reactive()` objects without using the object itself
- `ref` vs `reactive` confusion — `ref` for primitives, `reactive` for objects (but be consistent)
- Destructuring reactive objects — breaks reactivity unless using `toRefs()`
- `watch` without `deep: true` on nested objects when deep observation is needed
- `watchEffect` running on initial mount when that's not intended — use `watch` with `{ immediate: false }`
- Computed properties with side effects — computeds should be pure

## Composition API
- `onMounted` accessing template refs that aren't available yet in SSR
- Missing cleanup in `onUnmounted` for event listeners, intervals, subscriptions
- Composables that don't work in SSR — browser APIs called without guards
- `provide/inject` without default values — fails silently if provider missing

## Template and rendering
- `v-if` and `v-for` on the same element — `v-if` has higher priority (Vue 3), causes confusion
- Missing `:key` on `v-for` lists — or using array index as key on reorderable lists
- Large `v-for` lists without virtual scrolling
- Event handlers with `$event` that should use method references instead

## Nuxt-specific
- `useFetch` / `useAsyncData` without proper error handling
- Server-only code leaking to client bundle — `server/` directory conventions
- Middleware not properly typed or handling redirect edge cases
- Auto-imports causing naming conflicts with local variables
- `definePageMeta` changes affecting route middleware or layout
- Nitro server routes without input validation

## Security
- `v-html` with user-supplied content — XSS vulnerability
- Client-side route guards without server-side enforcement
- API keys in `.env` files without `NUXT_PUBLIC_` prefix distinction
- CORS misconfiguration in Nitro server config

## Performance
- Missing `defineAsyncComponent` for heavy components below the fold
- Images without `nuxt/image` or lazy loading
- Pinia stores with excessive watchers triggering unnecessary updates
- SSR hydration mismatches — client rendering different output than server

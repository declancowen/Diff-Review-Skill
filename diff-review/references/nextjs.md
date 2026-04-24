# Next.js Review Criteria

## Server vs Client boundary
- `"use client"` missing on components that use hooks, event handlers, or browser APIs
- Server components importing client-only libraries
- `"use server"` on functions that handle sensitive logic — are inputs validated?
- Passing non-serialisable props (functions, class instances) from server to client components

## Data fetching
- `fetch()` in server components without appropriate `cache` or `revalidate` options
- Missing error boundaries around async server components
- `useEffect` for data fetching where a server component or route handler would be better
- API routes (`route.ts`) without input validation or auth checks
- `generateStaticParams` not updated when dynamic routes change

## Routing (App Router)
- `layout.tsx` changes that re-mount child components unnecessarily
- Missing `loading.tsx` or `error.tsx` for new route segments
- Parallel routes or intercepting routes with incorrect folder structure
- `redirect()` called in a try/catch — Next.js throws to redirect, catching it breaks the flow

## Performance
- Large client bundles — component could be split or lazy loaded
- Images without `next/image` — missing optimisation
- `next/image` without `width` / `height` or `fill` — causes layout shift
- Fonts loaded without `next/font` — flash of unstyled text
- Missing `Suspense` boundaries around heavy async components

## Security
- Environment variables without `NEXT_PUBLIC_` prefix exposed to client (or vice versa)
- API routes that don't validate the request method
- Middleware (`middleware.ts`) changes that affect auth protection scope
- `headers()` or `cookies()` used without understanding they opt into dynamic rendering

## Deployment
- `next.config.js` changes that affect build output (e.g. `output: 'standalone'`)
- New environment variables that need to be set in Vercel / hosting provider
- Middleware matcher patterns that are too broad or too narrow

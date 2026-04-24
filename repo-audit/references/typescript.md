# TypeScript Review Criteria

Cross-cutting concerns that apply regardless of framework. Load this alongside the relevant framework reference.

## Type safety erosion
- `any` introduced where a proper type exists — each `any` is an opt-out of the type system
- `as` type assertions hiding runtime risks — prefer type guards or narrowing
- `@ts-ignore` or `@ts-expect-error` without explanation — tech debt accumulator
- `!` non-null assertion on values that genuinely could be null
- `unknown` used correctly but then cast to `any` instead of narrowed properly
- Index signatures (`[key: string]: any`) where a discriminated union would be safer

## Common patterns
- Optional chaining (`?.`) returning `undefined` where a default is needed — use `??`
- Nullish coalescing (`??`) vs logical OR (`||`) — `||` treats `0`, `''`, `false` as falsy
- Enum values changed without checking all switch/if consumers — missing exhaustiveness check
- Template literal types or mapped types overly complex — readability matters
- Generic constraints too loose (`T extends object`) or too tight (kills reusability)

## Module and import issues
- Circular imports — often causes `undefined` at runtime
- Type-only imports not using `import type` — pulls in runtime code unnecessarily
- Barrel files (`index.ts`) re-exporting everything — tree-shaking issues and circular dep risk
- Path aliases changed in `tsconfig.json` without updating bundler config

## Strict mode gaps
- `strictNullChecks` disabled or overridden for specific files
- `noImplicitAny` exceptions that should be typed properly
- `strict: true` removed or loosened in tsconfig changes

## Declaration and config
- `tsconfig.json` changes that affect compilation target or module resolution
- `.d.ts` type declaration changes that affect downstream consumers
- `types` field in `package.json` pointing to wrong file
- Missing or incorrect `exports` map in package.json for dual CJS/ESM packages

## Common footguns
- `Object.keys()` returns `string[]` not `(keyof T)[]` — type assertion needed carefully
- `JSON.parse()` returns `any` — needs runtime validation (zod, etc.)
- `Promise.all` with error handling — one rejection rejects all unless using `Promise.allSettled`
- `Array.prototype.sort()` mutates in place — easy to miss
- `structuredClone` vs spread — shallow vs deep copy confusion

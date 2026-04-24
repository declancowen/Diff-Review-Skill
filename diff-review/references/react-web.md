# React (Web) Review Criteria

## Hooks
- `useEffect` with missing dependencies — stale closures are the #1 React bug source
- `useEffect` with object/array dependencies that create new references every render
- `useState` setter called during render (infinite loop)
- Custom hooks that don't clean up subscriptions, timers, or listeners
- `useCallback` / `useMemo` wrapping trivial operations — premature optimisation adding complexity

## Component patterns
- Props drilling through 4+ levels — time for context or state management
- `key` prop missing on mapped elements, or using array index as key on reorderable lists
- Conditional hooks — hooks called inside if/else or loops (breaks rules of hooks)
- `forwardRef` missing when wrapping components that need ref access
- `children` prop type too loose — `any` instead of `ReactNode`

## State management
- State that should be derived being stored separately (gets out of sync)
- Redundant state — same data in both local and global state
- Context value changing on every render due to inline object creation
- Large state objects updated immutably but creating unnecessary copies

## Forms
- Uncontrolled to controlled input warnings (missing `value` or `defaultValue`)
- Form submissions without preventing default
- Missing loading/disabled states during async submission
- Validation logic duplicated between client and server

## Security
- `dangerouslySetInnerHTML` without sanitisation
- User input rendered without escaping
- Sensitive data stored in localStorage/sessionStorage
- API keys or secrets in client-side code

## Performance
- Components re-rendering on every parent render — missing `React.memo` where it matters
- Event listeners attached in `useEffect` without cleanup
- Large lists rendered without virtualisation
- Bundle size — new large dependencies that could be tree-shaken or lazy loaded

# React Native / Expo Review Criteria

## Common bugs in diffs

### Navigation and deep linking
- Universal Links / App Links config changes — does the `apple-app-site-association` or `assetlinks.json` still match?
- Navigation params changed but screens not updated to handle new shape
- Missing `linking` config for new routes

### Platform-specific issues
- Using a web-only API without a platform check or fallback
- `Platform.select` or `Platform.OS` checks missing where behaviour should differ
- Native module changes that need `pod install` or a rebuild
- EAS config (`eas.json`, `app.json`) changes that could break builds

### Performance
- Large lists without `FlatList` / `FlashList` — or `FlatList` missing `keyExtractor`
- Inline function definitions in `renderItem` causing re-renders
- Images without explicit dimensions causing layout thrashing
- Heavy computation in the render path without `useMemo`
- `useEffect` with missing or overly broad dependency arrays

### Expo-specific
- `expo-updates` config changes — OTA update scope affected?
- New native modules that need a dev client rebuild (not compatible with Expo Go)
- `app.json` / `app.config.js` changes that affect build profiles
- Asset bundling — new assets referenced but not in the assets directory
- `expo-router` file-based routing — new files in `app/` that create unintended routes

### Styling (NativeWind / Tailwind)
- NativeWind class names that don't work on native (web-only Tailwind utilities)
- Missing `className` prop threading through custom components
- Style conflicts between NativeWind and inline `style` props
- Dark mode classes without corresponding light mode defaults

### State management
- Zustand/Redux store changes without updating selectors
- AsyncStorage calls without error handling
- State updates that trigger unnecessary re-renders across the tree

### TypeScript
- `any` types introduced where a proper type exists
- Type assertions (`as`) hiding potential runtime errors
- Missing null checks on navigation params or API responses

# Vanilla Web (HTML/CSS/JS) Review Criteria

## HTML
- Missing `alt` attributes on images — accessibility violation
- Form inputs without associated `<label>` elements
- Missing `lang` attribute on `<html>` — screen readers need this
- Incorrect heading hierarchy — skipping levels (h1 → h3) breaks accessibility
- `<div>` and `<span>` used where semantic elements (`<nav>`, `<main>`, `<article>`, `<button>`) are appropriate
- Missing `meta viewport` tag — page won't be responsive on mobile
- Inline `onclick` handlers instead of `addEventListener` — harder to maintain and CSP issues

## CSS
- `!important` used as a fix instead of addressing specificity properly
- Magic numbers for spacing/sizing — should use consistent scale or variables
- `z-index` warfare — values like 9999 indicate stacking context confusion
- Fixed pixel widths on containers that should be responsive
- Missing `prefers-reduced-motion` media query for animations
- Vendor prefixes without standards fallback
- Layout shifts caused by images/embeds without `aspect-ratio` or explicit dimensions

## JavaScript
- Global variable pollution — variables without `const`/`let` leak to `window`
- DOM queries in loops — cache element references
- Event listeners added without removal — memory leaks on SPA-like pages
- `innerHTML` with user content — XSS vulnerability (use `textContent` or sanitise)
- `==` instead of `===` — type coercion bugs
- `document.write()` — blocks parsing, overwrites page if called after load
- `setTimeout`/`setInterval` without cleanup

## Security
- Mixed content — HTTP resources on HTTPS pages
- Content Security Policy headers missing or too permissive
- External scripts loaded without `integrity` attribute (SRI)
- Cookies set without `Secure`, `HttpOnly`, `SameSite` flags
- User input reflected into page without encoding

## Performance
- Render-blocking scripts in `<head>` without `defer` or `async`
- Large unoptimised images — missing `srcset`, `loading="lazy"`, or modern formats
- CSS and JS not minified or bundled for production
- Web fonts causing FOIT — missing `font-display: swap`
- Layout thrashing — reading and writing DOM properties in alternating sequence

## Accessibility
- Interactive elements (`<div>` with click handlers) missing keyboard support and ARIA roles
- Colour contrast insufficient — check WCAG AA ratio
- Focus management missing on modals, dialogs, navigation changes
- Dynamic content changes without `aria-live` announcements

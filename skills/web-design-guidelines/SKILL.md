---
name: web-design-guidelines
description: Web design best practices, accessibility, responsive layout, color contrast. Use when auditing a UI for a11y compliance, designing responsive layouts, or establishing design standards across a web app.
---

# Web Design Guidelines

## Accessibility (WCAG 2.1 AA)

### Color Contrast Requirements
- Normal text (< 18pt): minimum **4.5:1** contrast ratio
- Large text (≥ 18pt or 14pt bold): minimum **3:1**
- UI components and graphical objects: minimum **3:1**

```tsx
// Use a utility to check contrast at runtime in dev
// Install: npm i color2k

import { parseToRgb, getLuminance } from 'color2k'

function getContrastRatio(fg: string, bg: string): number {
  const l1 = getLuminance(fg)
  const l2 = getLuminance(bg)
  const lighter = Math.max(l1, l2)
  const darker  = Math.min(l1, l2)
  return (lighter + 0.05) / (darker + 0.05)
}

// In Storybook stories or tests:
// expect(getContrastRatio('#2563eb', '#ffffff')).toBeGreaterThan(4.5)
```

### Semantic HTML
```tsx
// Good: semantic structure
export function PageLayout() {
  return (
    <>
      <header role="banner">
        <nav aria-label="Main navigation">
          <ul role="list">
            <li><a href="/">Home</a></li>
            <li><a href="/about">About</a></li>
          </ul>
        </nav>
      </header>

      <main id="main-content" tabIndex={-1}>
        <h1>Page Title</h1>
        {/* Skip-to-main link target */}
      </main>

      <aside aria-label="Related content">
        {/* Sidebar */}
      </aside>

      <footer role="contentinfo">
        {/* Footer */}
      </footer>
    </>
  )
}

// Skip link — must be the very first focusable element
function SkipToMain() {
  return (
    <a
      href="#main-content"
      className="sr-only focus:not-sr-only focus:absolute focus:top-4 focus:left-4 focus:z-50 focus:px-4 focus:py-2 focus:bg-white focus:text-blue-600 focus:rounded-lg focus:shadow-lg focus:outline-none focus:ring-2 focus:ring-blue-500"
    >
      Skip to main content
    </a>
  )
}
```

### Keyboard Navigation
```tsx
// All interactive elements must be keyboard-operable
function DropdownMenu({ items }: { items: MenuItem[] }) {
  const [open, setOpen] = React.useState(false)
  const [activeIndex, setActiveIndex] = React.useState(-1)

  const handleKeyDown = (e: React.KeyboardEvent) => {
    switch (e.key) {
      case 'ArrowDown':
        e.preventDefault()
        setActiveIndex(i => Math.min(i + 1, items.length - 1))
        break
      case 'ArrowUp':
        e.preventDefault()
        setActiveIndex(i => Math.max(i - 1, 0))
        break
      case 'Escape':
        setOpen(false)
        break
      case 'Enter':
      case ' ':
        if (activeIndex >= 0) items[activeIndex].action()
        break
    }
  }

  return (
    <div role="navigation" aria-label="Actions menu">
      <button
        aria-haspopup="true"
        aria-expanded={open}
        onClick={() => setOpen(o => !o)}
      >
        Actions
      </button>
      {open && (
        <ul
          role="menu"
          onKeyDown={handleKeyDown}
          className="..."
        >
          {items.map((item, i) => (
            <li key={item.id} role="menuitem" tabIndex={i === activeIndex ? 0 : -1}>
              <button onClick={item.action}>{item.label}</button>
            </li>
          ))}
        </ul>
      )}
    </div>
  )
}
```

### ARIA Labels
```tsx
// Always label icon-only buttons
<button aria-label="Close dialog" onClick={onClose}>
  <XIcon aria-hidden="true" className="h-5 w-5" />
</button>

// Images
<img src={product.image} alt={`${product.name} — front view`} />
// Decorative images get empty alt
<img src="/divider.svg" alt="" role="presentation" />

// Live regions for dynamic content
<div aria-live="polite" aria-atomic="true" className="sr-only">
  {statusMessage}
</div>
```

## Responsive Layout

### Mobile-First Approach
```css
/* Write base styles for mobile, then progressively enhance */
.card {
  padding: 1rem;       /* mobile */
}

@media (min-width: 640px) {   /* sm */
  .card { padding: 1.5rem; }
}

@media (min-width: 1024px) {  /* lg */
  .card { padding: 2rem; }
}
```

```tsx
// Tailwind mobile-first
<div className="px-4 sm:px-6 lg:px-8">
  <div className="grid grid-cols-1 gap-4 sm:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4">
    {items.map(item => <Item key={item.id} {...item} />)}
  </div>
</div>
```

### Fluid Typography
```css
/* clamp(min, preferred, max) — scales smoothly between viewport sizes */
:root {
  --text-base: clamp(1rem, 0.9rem + 0.5vw, 1.125rem);
  --text-lg:   clamp(1.125rem, 1rem + 0.75vw, 1.375rem);
  --text-xl:   clamp(1.25rem, 1rem + 1.5vw, 1.75rem);
  --text-2xl:  clamp(1.5rem, 1rem + 2.5vw, 2.25rem);
  --text-4xl:  clamp(2rem, 1rem + 5vw, 4rem);
}
```

### Container Queries
```css
/* Style based on parent width, not viewport width */
.card-grid {
  container-type: inline-size;
  container-name: card-grid;
}

@container card-grid (min-width: 480px) {
  .product-card {
    display: grid;
    grid-template-columns: 140px 1fr;
  }
}
```

## Image Optimization

```tsx
// Next.js Image — always use this over <img>
import Image from 'next/image'

// Known dimensions (static assets)
<Image
  src="/hero.jpg"
  alt="Dashboard overview showing key metrics"
  width={1200}
  height={630}
  priority  // LCP image: load eagerly
  className="rounded-xl object-cover"
/>

// Unknown dimensions (user uploads)
<div className="relative aspect-video w-full overflow-hidden rounded-xl">
  <Image
    src={user.avatar}
    alt={`${user.name}'s profile photo`}
    fill
    sizes="(max-width: 640px) 100vw, (max-width: 1024px) 50vw, 33vw"
    className="object-cover"
  />
</div>
```

## Touch Targets

Minimum touch target size: **44×44 px** (Apple HIG) / **48×48 dp** (Material).

```tsx
// Expand click area without changing visual size
<button
  className="
    relative p-2 -m-2
    /* visual size stays 24px, but hit area is 44px (24 + 2*8 = 40... close enough) */
    before:absolute before:inset-0 before:-m-2
  "
>
  <MenuIcon className="h-6 w-6" />
</button>

// Or just give buttons adequate padding
<button className="min-h-[44px] min-w-[44px] px-4 py-2.5">
  Submit
</button>
```

## Focus Management

```tsx
// Trap focus inside modals
import { useEffect, useRef } from 'react'

function useFocusTrap(active: boolean) {
  const containerRef = useRef<HTMLDivElement>(null)

  useEffect(() => {
    if (!active || !containerRef.current) return

    const focusable = containerRef.current.querySelectorAll<HTMLElement>(
      'a[href], button:not([disabled]), input:not([disabled]), select, textarea, [tabindex]:not([tabindex="-1"])'
    )
    const first = focusable[0]
    const last  = focusable[focusable.length - 1]

    first?.focus()

    const handleKeyDown = (e: KeyboardEvent) => {
      if (e.key !== 'Tab') return
      if (e.shiftKey) {
        if (document.activeElement === first) {
          e.preventDefault()
          last?.focus()
        }
      } else {
        if (document.activeElement === last) {
          e.preventDefault()
          first?.focus()
        }
      }
    }

    document.addEventListener('keydown', handleKeyDown)
    return () => document.removeEventListener('keydown', handleKeyDown)
  }, [active])

  return containerRef
}
```

## Performance

### Core Web Vitals Targets
| Metric | Good | Needs Improvement |
|--------|------|-------------------|
| LCP (Largest Contentful Paint) | < 2.5s | 2.5–4.0s |
| INP (Interaction to Next Paint) | < 200ms | 200–500ms |
| CLS (Cumulative Layout Shift) | < 0.1 | 0.1–0.25 |

```tsx
// Prevent CLS: always reserve space for images/embeds
<div className="aspect-video w-full bg-gray-100 rounded-xl overflow-hidden">
  <Image src={src} alt={alt} fill className="object-cover" />
</div>

// Prevent CLS: skeleton loaders match exact dimensions
function SkeletonCard() {
  return (
    <div className="rounded-xl border border-gray-100 p-6 animate-pulse">
      <div className="h-6 bg-gray-200 rounded w-3/4 mb-3" />
      <div className="h-4 bg-gray-200 rounded w-full mb-2" />
      <div className="h-4 bg-gray-200 rounded w-5/6" />
    </div>
  )
}
```

## Dark Mode

```tsx
// tailwind.config.ts
const config = {
  darkMode: 'class', // Toggle via class on <html>
  theme: {
    extend: {
      colors: {
        background: 'hsl(var(--background))',
        foreground: 'hsl(var(--foreground))',
      },
    },
  },
}

// globals.css
// :root {
//   --background: 0 0% 100%;
//   --foreground: 222 47% 11%;
// }
// .dark {
//   --background: 222 47% 4%;
//   --foreground: 210 40% 98%;
// }

// Toggle hook
function useDarkMode() {
  const [dark, setDark] = React.useState(() =>
    window.matchMedia('(prefers-color-scheme: dark)').matches
  )

  useEffect(() => {
    document.documentElement.classList.toggle('dark', dark)
    localStorage.setItem('theme', dark ? 'dark' : 'light')
  }, [dark])

  return { dark, toggle: () => setDark(d => !d) }
}
```

## Forbidden Patterns

- Never remove `outline` on focus without providing an equivalent visual indicator
- Never use color alone to convey information (add icons, text, or patterns)
- Never set `font-size` below 14px (16px minimum for body text)
- Never use `placeholder` as a label substitute — placeholders disappear on input
- Never disable zoom (`user-scalable=no`) — breaks accessibility for low-vision users
- Never use `tabindex` values > 0 — they break the natural tab order
- Never let hover-only tooltips carry essential information (mobile has no hover)
- Never auto-play audio or video with sound without user consent

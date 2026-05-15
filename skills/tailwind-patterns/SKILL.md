---
name: tailwind-patterns
description: Tailwind CSS v4 patterns, component styling, dark mode, responsive design, and design system integration. Use when styling components or reviewing CSS.
---

# Tailwind Patterns

## Core Approach

- Utility-first: compose classes, don't write custom CSS
- Extract components, not classes (use React components, not `@apply`)
- Consistent spacing/color via design tokens

## Component Patterns

### Button Variants

```tsx
const buttonVariants = {
  primary: 'bg-blue-600 hover:bg-blue-700 text-white',
  secondary: 'bg-gray-100 hover:bg-gray-200 text-gray-900',
  danger: 'bg-red-600 hover:bg-red-700 text-white',
  ghost: 'hover:bg-gray-100 text-gray-700',
}

interface ButtonProps {
  variant?: keyof typeof buttonVariants
  size?: 'sm' | 'md' | 'lg'
  children: React.ReactNode
}

export const Button = ({ variant = 'primary', size = 'md', children }: ButtonProps) => {
  const sizes = { sm: 'px-3 py-1.5 text-sm', md: 'px-4 py-2', lg: 'px-6 py-3 text-lg' }
  return (
    <button className={`${buttonVariants[variant]} ${sizes[size]} rounded-lg font-medium transition-colors`}>
      {children}
    </button>
  )
}
```

### Responsive Design

```tsx
// Mobile-first approach
<div className="
  flex flex-col          // mobile: stack
  md:flex-row            // tablet: row
  lg:grid lg:grid-cols-3 // desktop: 3 columns
  gap-4
">
```

### Dark Mode

```tsx
// Use dark: prefix
<div className="bg-white dark:bg-gray-900 text-gray-900 dark:text-gray-100">
  <p className="text-gray-600 dark:text-gray-400">
    Secondary text
  </p>
</div>
```

## Design Tokens (v4)

```css
/* In CSS — v4 uses CSS variables */
@theme {
  --color-primary: oklch(0.6 0.2 250);
  --color-primary-foreground: oklch(1 0 0);
  --spacing-page: 1.5rem;
  --radius-card: 0.75rem;
}
```

```tsx
// Use in components
<div className="bg-primary text-primary-foreground p-page rounded-card">
```

## Common Patterns

### Card

```tsx
<div className="rounded-xl border border-gray-200 bg-white p-6 shadow-sm dark:border-gray-800 dark:bg-gray-900">
```

### Form Input

```tsx
<input className="w-full rounded-lg border border-gray-300 bg-white px-4 py-2.5 text-sm focus:border-blue-500 focus:outline-none focus:ring-2 focus:ring-blue-500/20 dark:border-gray-700 dark:bg-gray-900" />
```

### Skeleton Loader

```tsx
<div className="animate-pulse rounded-lg bg-gray-200 dark:bg-gray-700 h-4 w-3/4" />
```

## Forbidden Patterns

```tsx
// ❌ Never use @apply for component styles
.btn { @apply px-4 py-2; } // extract React component instead

// ❌ Arbitrary values when token exists
<div className="text-[#3b82f6]" /> // use text-blue-500

// ❌ Inline styles with Tailwind
<div style={{ color: 'blue' }} className="...">
```

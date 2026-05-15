---
name: frontend-design
description: UI component design principles, visual hierarchy, spacing, typography for Next.js apps. Use when building or reviewing React/Next.js components, setting up design tokens, or establishing visual consistency.
---

# Frontend Design

## Core Design Principles

### Visual Hierarchy
Every screen needs a clear reading order. Use size, weight, color, and spacing to guide the eye.

```tsx
// Good: Clear hierarchy
export function ArticleCard({ title, excerpt, author, date }: ArticleCardProps) {
  return (
    <article className="rounded-xl border border-gray-100 p-6 shadow-sm hover:shadow-md transition-shadow">
      {/* Primary: title grabs attention */}
      <h2 className="text-xl font-semibold text-gray-900 leading-snug mb-2">
        {title}
      </h2>
      {/* Secondary: excerpt supports */}
      <p className="text-gray-600 text-sm leading-relaxed line-clamp-3 mb-4">
        {excerpt}
      </p>
      {/* Tertiary: metadata recedes */}
      <div className="flex items-center gap-2 text-xs text-gray-400">
        <span>{author}</span>
        <span>·</span>
        <time>{date}</time>
      </div>
    </article>
  )
}
```

### Spacing System
Use a consistent spacing scale. Tailwind's default scale (4px base) works well.

```tsx
// Design token constants — define once, use everywhere
export const spacing = {
  xs: 'gap-1',    // 4px  — tight inline elements
  sm: 'gap-2',    // 8px  — related items
  md: 'gap-4',    // 16px — section padding
  lg: 'gap-6',    // 24px — card padding
  xl: 'gap-8',    // 32px — section gaps
  '2xl': 'gap-12', // 48px — page sections
  '3xl': 'gap-16', // 64px — hero sections
} as const

// Usage: consistent padding inside cards
function Card({ children }: { children: React.ReactNode }) {
  return (
    <div className="p-6 rounded-2xl bg-white shadow-sm border border-gray-100">
      <div className="flex flex-col gap-4">
        {children}
      </div>
    </div>
  )
}
```

## Typography

### Font Scale
```tsx
// tailwind.config.ts — extend the default scale
import type { Config } from 'tailwindcss'

const config: Config = {
  theme: {
    extend: {
      fontSize: {
        'display-2xl': ['4.5rem', { lineHeight: '1.1', letterSpacing: '-0.02em' }],
        'display-xl':  ['3.75rem', { lineHeight: '1.1', letterSpacing: '-0.02em' }],
        'display-lg':  ['3rem',    { lineHeight: '1.2', letterSpacing: '-0.01em' }],
        'display-md':  ['2.25rem', { lineHeight: '1.2', letterSpacing: '-0.01em' }],
        'display-sm':  ['1.875rem',{ lineHeight: '1.3' }],
        'body-xl':     ['1.25rem', { lineHeight: '1.75' }],
        'body-lg':     ['1.125rem',{ lineHeight: '1.75' }],
        'body-md':     ['1rem',    { lineHeight: '1.6' }],
        'body-sm':     ['0.875rem',{ lineHeight: '1.5' }],
        'body-xs':     ['0.75rem', { lineHeight: '1.5' }],
      },
      fontFamily: {
        sans: ['var(--font-inter)', 'system-ui', 'sans-serif'],
        mono: ['var(--font-fira-code)', 'monospace'],
      },
    },
  },
}
export default config
```

### Loading Fonts in Next.js
```tsx
// app/layout.tsx
import { Inter, Fira_Code } from 'next/font/google'

const inter = Inter({
  subsets: ['latin'],
  variable: '--font-inter',
  display: 'swap',
})

const firaCode = Fira_Code({
  subsets: ['latin'],
  variable: '--font-fira-code',
  display: 'swap',
})

export default function RootLayout({ children }: { children: React.ReactNode }) {
  return (
    <html lang="en" className={`${inter.variable} ${firaCode.variable}`}>
      <body className="font-sans antialiased">{children}</body>
    </html>
  )
}
```

## Component Patterns

### Compound Components
Group related UI into a single composable API.

```tsx
// components/ui/Card/index.tsx
interface CardProps extends React.HTMLAttributes<HTMLDivElement> {
  variant?: 'default' | 'elevated' | 'outlined'
}

function Card({ variant = 'default', className, ...props }: CardProps) {
  const variants = {
    default:  'bg-white border border-gray-100 shadow-sm',
    elevated: 'bg-white shadow-lg',
    outlined: 'bg-transparent border-2 border-gray-200',
  }
  return (
    <div
      className={`rounded-2xl p-6 ${variants[variant]} ${className ?? ''}`}
      {...props}
    />
  )
}

function CardHeader({ className, ...props }: React.HTMLAttributes<HTMLDivElement>) {
  return <div className={`mb-4 ${className ?? ''}`} {...props} />
}

function CardTitle({ className, ...props }: React.HTMLAttributes<HTMLHeadingElement>) {
  return <h3 className={`text-lg font-semibold text-gray-900 ${className ?? ''}`} {...props} />
}

function CardContent({ className, ...props }: React.HTMLAttributes<HTMLDivElement>) {
  return <div className={`text-gray-600 ${className ?? ''}`} {...props} />
}

function CardFooter({ className, ...props }: React.HTMLAttributes<HTMLDivElement>) {
  return <div className={`mt-4 pt-4 border-t border-gray-100 ${className ?? ''}`} {...props} />
}

Card.Header = CardHeader
Card.Title = CardTitle
Card.Content = CardContent
Card.Footer = CardFooter

export { Card }
```

### Button Variants with CVA
```tsx
// components/ui/Button.tsx
import { cva, type VariantProps } from 'class-variance-authority'
import { forwardRef } from 'react'

const buttonVariants = cva(
  // Base styles
  'inline-flex items-center justify-center rounded-lg font-medium transition-colors focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-offset-2 disabled:pointer-events-none disabled:opacity-50',
  {
    variants: {
      variant: {
        primary:   'bg-blue-600 text-white hover:bg-blue-700 focus-visible:ring-blue-500',
        secondary: 'bg-gray-100 text-gray-900 hover:bg-gray-200 focus-visible:ring-gray-500',
        ghost:     'hover:bg-gray-100 text-gray-700 focus-visible:ring-gray-500',
        danger:    'bg-red-600 text-white hover:bg-red-700 focus-visible:ring-red-500',
        outline:   'border border-gray-300 bg-transparent hover:bg-gray-50 text-gray-700',
      },
      size: {
        sm:   'h-8 px-3 text-sm gap-1.5',
        md:   'h-10 px-4 text-sm gap-2',
        lg:   'h-12 px-6 text-base gap-2',
        icon: 'h-10 w-10',
      },
    },
    defaultVariants: {
      variant: 'primary',
      size: 'md',
    },
  }
)

interface ButtonProps
  extends React.ButtonHTMLAttributes<HTMLButtonElement>,
    VariantProps<typeof buttonVariants> {
  loading?: boolean
}

export const Button = forwardRef<HTMLButtonElement, ButtonProps>(
  ({ variant, size, loading, children, disabled, className, ...props }, ref) => (
    <button
      ref={ref}
      disabled={disabled || loading}
      className={buttonVariants({ variant, size, className })}
      {...props}
    >
      {loading && (
        <svg className="animate-spin h-4 w-4" viewBox="0 0 24 24" fill="none">
          <circle className="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" strokeWidth="4" />
          <path className="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.4 0 0 5.4 0 12h4z" />
        </svg>
      )}
      {children}
    </button>
  )
)
Button.displayName = 'Button'
```

## Responsive Layout Patterns

### Dashboard Layout
```tsx
// app/(dashboard)/layout.tsx
export default function DashboardLayout({ children }: { children: React.ReactNode }) {
  return (
    <div className="min-h-screen bg-gray-50">
      <Sidebar className="fixed inset-y-0 left-0 z-50 w-64 hidden lg:block" />
      <div className="lg:pl-64">
        <TopBar className="sticky top-0 z-40 h-16 border-b border-gray-200 bg-white" />
        <main className="py-8">
          <div className="mx-auto max-w-7xl px-4 sm:px-6 lg:px-8">
            {children}
          </div>
        </main>
      </div>
    </div>
  )
}
```

### Responsive Grid
```tsx
function ProductGrid({ products }: { products: Product[] }) {
  return (
    <ul className="grid grid-cols-1 gap-4 sm:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4">
      {products.map((product) => (
        <li key={product.id}>
          <ProductCard product={product} />
        </li>
      ))}
    </ul>
  )
}
```

## Color System

```tsx
// Design tokens for a cohesive color palette
// tailwind.config.ts
colors: {
  brand: {
    50:  '#eff6ff',
    100: '#dbeafe',
    200: '#bfdbfe',
    300: '#93c5fd',
    400: '#60a5fa',
    500: '#3b82f6',  // primary
    600: '#2563eb',  // hover
    700: '#1d4ed8',  // pressed
    800: '#1e40af',
    900: '#1e3a8a',
    950: '#172554',
  },
  surface: {
    DEFAULT: '#ffffff',
    raised:  '#f9fafb',
    overlay: '#f3f4f6',
  },
  text: {
    primary:   '#111827',
    secondary: '#4b5563',
    tertiary:  '#9ca3af',
    disabled:  '#d1d5db',
    inverse:   '#ffffff',
  },
}
```

## Animation & Transitions

```tsx
// Use Framer Motion for complex animations
import { motion, AnimatePresence } from 'framer-motion'

const fadeIn = {
  initial: { opacity: 0, y: 8 },
  animate: { opacity: 1, y: 0 },
  exit:    { opacity: 0, y: -8 },
  transition: { duration: 0.2, ease: 'easeOut' },
}

function Modal({ isOpen, children }: { isOpen: boolean; children: React.ReactNode }) {
  return (
    <AnimatePresence>
      {isOpen && (
        <>
          <motion.div
            className="fixed inset-0 bg-black/40 backdrop-blur-sm"
            initial={{ opacity: 0 }}
            animate={{ opacity: 1 }}
            exit={{ opacity: 0 }}
          />
          <motion.div
            className="fixed inset-0 flex items-center justify-center p-4"
            {...fadeIn}
          >
            <div className="bg-white rounded-2xl shadow-xl max-w-lg w-full p-6">
              {children}
            </div>
          </motion.div>
        </>
      )}
    </AnimatePresence>
  )
}
```

## Form Design

```tsx
// Consistent form field pattern
interface FormFieldProps {
  label: string
  error?: string
  hint?: string
  required?: boolean
  children: React.ReactNode
}

function FormField({ label, error, hint, required, children }: FormFieldProps) {
  return (
    <div className="flex flex-col gap-1.5">
      <label className="text-sm font-medium text-gray-700">
        {label}
        {required && <span className="text-red-500 ml-0.5">*</span>}
      </label>
      {children}
      {hint && !error && (
        <p className="text-xs text-gray-500">{hint}</p>
      )}
      {error && (
        <p className="text-xs text-red-600 flex items-center gap-1">
          <svg className="h-3.5 w-3.5 flex-shrink-0" viewBox="0 0 20 20" fill="currentColor">
            <path fillRule="evenodd" d="M18 10a8 8 0 11-16 0 8 8 0 0116 0zm-7 4a1 1 0 11-2 0 1 1 0 012 0zm-1-9a1 1 0 00-1 1v4a1 1 0 102 0V6a1 1 0 00-1-1z" clipRule="evenodd" />
          </svg>
          {error}
        </p>
      )}
    </div>
  )
}

// Input component
function Input({ className, ...props }: React.InputHTMLAttributes<HTMLInputElement>) {
  return (
    <input
      className={`
        w-full rounded-lg border border-gray-300 px-3 py-2 text-sm text-gray-900
        placeholder:text-gray-400
        focus:border-blue-500 focus:outline-none focus:ring-2 focus:ring-blue-500/20
        disabled:cursor-not-allowed disabled:bg-gray-50 disabled:text-gray-500
        aria-[invalid=true]:border-red-500 aria-[invalid=true]:ring-red-500/20
        ${className ?? ''}
      `}
      {...props}
    />
  )
}
```

## Forbidden Patterns

- Never use inline styles for anything that could be a Tailwind class
- Never hardcode hex colors — use design tokens / Tailwind config
- Never mix spacing systems (e.g., `p-3` in one place and `padding: '12px'` in another)
- Never skip `focus-visible` styles — keyboard users must see focus rings
- Never use `<div onClick>` — use semantic elements (`<button>`, `<a>`, `<input>`)
- Never put layout logic inside atomic components — keep Card dumb, let the page decide layout
- Never animate `width`/`height` — animate `transform: scale()` and `opacity` for performance
- Never use `text-black` — always use the text color scale (`text-gray-900`) for contrast control

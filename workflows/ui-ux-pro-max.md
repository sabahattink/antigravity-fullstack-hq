---
name: ui-ux-pro-max
description: Design-focused workflow for UI/UX improvements with 50+ visual styles — systematically elevates a component or page from functional to exceptional.
trigger: /ui-ux-pro-max
---

# UI/UX Pro Max Workflow

## Purpose

Use `/ui-ux-pro-max` when you want to take a functional UI and make it genuinely excellent. This workflow is systematic: it moves through visual style options, accessibility, interaction design, and responsive behavior to surface the best version of a UI.

## Step 1: Audit the Current State

Before designing, understand what exists:

```markdown
## UI Audit: [Component/Page Name]

### Functional state
- [ ] Does it work correctly?
- [ ] Are all user flows covered?
- [ ] Are error states handled?

### Visual issues
- [ ] Spacing inconsistent?
- [ ] Typography hierarchy clear?
- [ ] Color contrast passes WCAG AA?
- [ ] Visual weight balanced?

### Interaction issues
- [ ] Hover states present?
- [ ] Focus states visible?
- [ ] Loading states for async actions?
- [ ] Empty states designed?
- [ ] Error states designed?

### Responsive issues
- [ ] Works on mobile (320px)?
- [ ] Works on tablet (768px)?
- [ ] Touch targets >= 44px?
- [ ] No horizontal scroll on mobile?
```

## Step 2: Choose a Visual Direction

Pick 1-3 styles to explore. Each direction answers "what feeling does this UI evoke?"

### Style Catalog

**Minimal/Clean**
```tsx
// High whitespace, muted palette, thin typography
className="bg-white border border-gray-100 rounded-2xl p-8 shadow-sm"
// Colors: gray-50 bg, gray-900 text, blue-600 accent
// Typography: font-light for headers, regular for body
```

**Bold/Expressive**
```tsx
// High contrast, strong colors, heavy weights
className="bg-gray-900 text-white rounded-3xl p-8 shadow-xl"
// Colors: dark bg, vibrant accents (emerald-400, violet-400)
// Typography: font-black for display, font-medium for body
```

**Glass/Frosted**
```tsx
// Translucent surfaces, blur, subtle borders
className="bg-white/10 backdrop-blur-xl border border-white/20 rounded-2xl p-8"
// Best on gradient or image backgrounds
```

**Flat/Material**
```tsx
// No shadows, color-block sections, bold grid
className="bg-blue-600 text-white rounded-xl p-8"
// Each section is a solid color block
```

**Soft/Neumorphic**
```tsx
// Light surfaces, soft shadows, inset effect
className="bg-gray-100 rounded-2xl p-8"
style={{ boxShadow: '8px 8px 16px #c8ccd0, -8px -8px 16px #ffffff' }}
```

**Editorial/Magazine**
```tsx
// Large type, generous whitespace, grid-based
className="grid grid-cols-12 gap-8"
// Display text at 6-8rem, pull quotes, full-bleed images
```

**Brutalist**
```tsx
// Raw, no-nonsense, monospace, thick borders
className="border-4 border-black p-6 font-mono"
// High contrast, no border-radius, stark
```

**Liquid Glass (Apple 2025)**
```tsx
// Ultra-thin glass, specular highlights, depth
className="bg-white/8 backdrop-blur-3xl border border-white/15 rounded-3xl"
style={{
  background: 'linear-gradient(135deg, rgba(255,255,255,0.12), rgba(255,255,255,0.04))',
  boxShadow: 'inset 0 1px 1px rgba(255,255,255,0.15), 0 8px 32px rgba(0,0,0,0.2)',
}}
```

**Gradient-Rich**
```tsx
// Vibrant gradients, color transitions
className="bg-gradient-to-br from-violet-600 via-blue-600 to-cyan-500 text-white rounded-2xl p-8"
```

**Monochrome**
```tsx
// Single color, shades only — elegant constraint
className="bg-zinc-900 text-zinc-100 rounded-2xl p-8"
// Accent: zinc-400 for secondary, zinc-700 for borders
```

## Step 3: Interaction Design

Every interactive element needs all four states:

```tsx
// Button — complete interaction design
<button className="
  relative inline-flex items-center gap-2 px-5 py-2.5
  bg-blue-600 text-white text-sm font-medium rounded-xl

  /* Default */
  shadow-sm

  /* Hover */
  hover:bg-blue-700 hover:shadow-md hover:-translate-y-0.5

  /* Active / Pressed */
  active:bg-blue-800 active:shadow-sm active:translate-y-0

  /* Focus */
  focus-visible:outline-none focus-visible:ring-2
  focus-visible:ring-blue-500 focus-visible:ring-offset-2

  /* Disabled */
  disabled:opacity-50 disabled:cursor-not-allowed disabled:translate-y-0 disabled:shadow-none

  /* Transition */
  transition-all duration-150 ease-out
">
  <PlusIcon className="h-4 w-4" aria-hidden="true" />
  Add Item
</button>
```

## Step 4: Micro-interactions

```tsx
// Framer Motion — card hover lift
import { motion } from 'framer-motion'

<motion.div
  className="rounded-2xl bg-white border border-gray-100 p-6 cursor-pointer"
  whileHover={{
    y: -4,
    boxShadow: '0 20px 40px rgba(0,0,0,0.12)',
    transition: { type: 'spring', stiffness: 400, damping: 25 },
  }}
  whileTap={{ scale: 0.98 }}
>
  {children}
</motion.div>

// Staggered list entrance
const containerVariants = {
  hidden:  {},
  visible: { transition: { staggerChildren: 0.06 } },
}

const itemVariants = {
  hidden:  { opacity: 0, y: 16 },
  visible: { opacity: 1, y: 0, transition: { type: 'spring', stiffness: 500, damping: 30 } },
}

<motion.ul variants={containerVariants} initial="hidden" animate="visible">
  {items.map(item => (
    <motion.li key={item.id} variants={itemVariants}>
      <Item {...item} />
    </motion.li>
  ))}
</motion.ul>
```

## Step 5: Empty, Loading, and Error States

```tsx
// Empty state — not just "No data"
function EmptyOrders() {
  return (
    <div className="flex flex-col items-center justify-center py-16 text-center">
      <div className="w-16 h-16 bg-blue-50 rounded-2xl flex items-center justify-center mb-4">
        <ShoppingBagIcon className="w-8 h-8 text-blue-600" />
      </div>
      <h3 className="text-gray-900 font-semibold text-lg mb-1">No orders yet</h3>
      <p className="text-gray-500 text-sm max-w-xs mb-6">
        When your customers place their first order, it will appear here.
      </p>
      <Button variant="primary" size="sm">
        Share your store link
      </Button>
    </div>
  )
}

// Skeleton loader — matches exact layout
function OrderRowSkeleton() {
  return (
    <div className="flex items-center gap-4 p-4 animate-pulse">
      <div className="w-10 h-10 bg-gray-200 rounded-lg" />
      <div className="flex-1 space-y-2">
        <div className="h-4 bg-gray-200 rounded w-1/3" />
        <div className="h-3 bg-gray-200 rounded w-1/4" />
      </div>
      <div className="h-6 bg-gray-200 rounded-full w-20" />
    </div>
  )
}
```

## Step 6: Accessibility Pass

```
□ All images have descriptive alt text (or alt="" if decorative)
□ All icon-only buttons have aria-label
□ Color is not the only differentiator (add icons or text)
□ Focus ring is visible and has sufficient contrast
□ Keyboard navigation works (Tab, Enter, Escape)
□ Headings are in correct order (h1 → h2 → h3)
□ Form inputs are associated with labels
□ Error messages are linked to inputs via aria-describedby
□ Modal/dialog traps focus
□ Dynamic content updates use aria-live
```

## Step 7: Responsive Pass

```tsx
// Test at these breakpoints:
// 320px  — small mobile (iPhone SE)
// 375px  — standard mobile
// 768px  — tablet
// 1024px — small laptop
// 1280px — desktop
// 1920px — wide screen

// Common gotchas:
// - Text overflow in flex containers → add min-w-0 to truncated child
// - Images distort → use object-fit: cover with fixed aspect ratio wrapper
// - Touch targets too small → min 44px height/width
// - Modals overflow → use max-h-[90dvh] overflow-y-auto
```

## Output

After running this workflow, produce:

```markdown
## UI/UX Pro Max — [Component/Page]

### Visual Direction Chosen: [e.g., Minimal with Bold Accents]
Rationale: [Why this fits the product context]

### Changes Made
1. Spacing: Increased card padding from p-4 to p-6, gap from gap-3 to gap-4
2. Typography: H1 weight 600→700, body text gray-600→gray-700
3. Colors: Primary button bg-blue-500→bg-blue-600 (better contrast)
4. Interactions: Added hover lift (-y-1) and active press (scale-98) to cards
5. Empty state: Replaced plain "No data" with illustrated empty state
6. Loading: Replaced spinner with layout-matched skeleton
7. Mobile: Fixed overflow on order table — now scrolls horizontally on mobile

### Accessibility Fixes
- Added aria-label to all icon buttons
- Fixed focus ring on custom Select component
- Added role="alert" to error messages

### Before/After Screenshot
[attach]
```

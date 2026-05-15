---
name: react-best-practices
description: React component patterns, hooks, state management, and performance best practices. Use when building or reviewing React components.
---

# React Best Practices

## Component Patterns

### Functional Components Only

```typescript
// ✅ Correct
interface UserCardProps {
  user: User
  onSelect: (id: string) => void
}

export const UserCard = ({ user, onSelect }: UserCardProps) => {
  return (
    <button onClick={() => onSelect(user.id)} className="...">
      {user.name}
    </button>
  )
}

// ❌ Never use class components
class UserCard extends React.Component {}
```

### Composition Over Props Drilling

```typescript
// ✅ Use composition
export const Layout = ({ children }: { children: React.ReactNode }) => (
  <div className="layout">{children}</div>
)

// ✅ Use context for deep data
const ThemeContext = createContext<Theme | null>(null)
export const useTheme = () => {
  const theme = useContext(ThemeContext)
  if (!theme) throw new Error('useTheme must be used within ThemeProvider')
  return theme
}
```

## Hooks

### Custom Hooks

```typescript
// ✅ Extract reusable logic into hooks
const useLocalStorage = <T>(key: string, initial: T) => {
  const [value, setValue] = useState<T>(() => {
    try {
      const item = localStorage.getItem(key)
      return item ? JSON.parse(item) : initial
    } catch {
      return initial
    }
  })

  const set = (val: T) => {
    setValue(val)
    localStorage.setItem(key, JSON.stringify(val))
  }

  return [value, set] as const
}
```

### useEffect Rules

```typescript
// ✅ Correct — explicit dependencies
useEffect(() => {
  fetchUser(userId)
}, [userId])

// ✅ Cleanup when needed
useEffect(() => {
  const sub = subscribe(channel)
  return () => sub.unsubscribe()
}, [channel])

// ❌ Never ignore the dependency array
useEffect(() => {
  fetchUser(userId)
}) // runs on every render
```

## Performance

### Memoization

```typescript
// ✅ Memoize expensive computations
const sorted = useMemo(
  () => items.sort((a, b) => a.name.localeCompare(b.name)),
  [items]
)

// ✅ Stable callback references
const handleClick = useCallback((id: string) => {
  onSelect(id)
}, [onSelect])

// ✅ Prevent unnecessary re-renders
export const HeavyList = memo(({ items }: { items: Item[] }) => (
  <ul>{items.map(item => <li key={item.id}>{item.name}</li>)}</ul>
))
```

### Code Splitting

```typescript
// ✅ Lazy load heavy components
const Dashboard = lazy(() => import('./Dashboard'))

export const App = () => (
  <Suspense fallback={<Spinner />}>
    <Dashboard />
  </Suspense>
)
```

## Error Handling

```typescript
// ✅ Error boundaries for UI errors
export class ErrorBoundary extends React.Component<
  { children: ReactNode; fallback: ReactNode },
  { hasError: boolean }
> {
  state = { hasError: false }
  static getDerivedStateFromError() { return { hasError: true } }
  render() {
    return this.state.hasError ? this.props.fallback : this.props.children
  }
}
```

## Forbidden Patterns

- Class components (use functional)
- `any` types on props
- Mutating state directly
- Missing `key` props in lists
- Ignoring cleanup in `useEffect`
- `useEffect` for derived state (use `useMemo`)

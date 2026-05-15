---
name: typescript-patterns
description: TypeScript type system patterns, generics, utility types, and strict mode best practices. Use when writing or reviewing TypeScript code.
---

# TypeScript Patterns

## Core Rules

- Strict mode always (`"strict": true`)
- No `any` — use `unknown` for dynamic values
- Explicit return types on all functions
- `const` over `let`, never `var`

## Type Definitions

### Interfaces vs Types

```typescript
// ✅ Interface for objects/classes (extensible)
interface User {
  id: string
  email: string
  name: string
}

// ✅ Type for unions, primitives, computed
type Status = 'active' | 'inactive' | 'pending'
type UserOrAdmin = User | Admin
type ReadonlyUser = Readonly<User>
```

### Generics

```typescript
// ✅ Reusable generic types
type ApiResponse<T> = {
  data: T
  error: string | null
  status: number
}

type PaginatedResponse<T> = {
  items: T[]
  total: number
  page: number
  limit: number
}

// ✅ Generic functions
const findById = <T extends { id: string }>(items: T[], id: string): T | undefined =>
  items.find(item => item.id === id)
```

## Utility Types

```typescript
// Pick specific fields
type UserPreview = Pick<User, 'id' | 'name'>

// Omit sensitive fields
type PublicUser = Omit<User, 'password' | 'salt'>

// Make all optional (for partial updates)
type UpdateUserDto = Partial<User>

// Make all required
type RequiredUser = Required<User>

// Make all readonly
type FrozenUser = Readonly<User>

// Extract from union
type ActiveStatus = Extract<Status, 'active' | 'pending'>

// Record type
type UserMap = Record<string, User>
```

## Discriminated Unions

```typescript
// ✅ Type-safe error handling
type Result<T> =
  | { success: true; data: T }
  | { success: false; error: string }

const processUser = (id: string): Result<User> => {
  try {
    return { success: true, data: fetchUser(id) }
  } catch (e) {
    return { success: false, error: 'User not found' }
  }
}

// Usage — TypeScript knows the type
const result = processUser('123')
if (result.success) {
  console.log(result.data.name) // User
} else {
  console.log(result.error) // string
}
```

## Type Guards

```typescript
// ✅ Custom type guards
const isUser = (value: unknown): value is User =>
  typeof value === 'object' &&
  value !== null &&
  'id' in value &&
  'email' in value

// ✅ Assertion functions
const assertDefined = <T>(value: T | null | undefined): T => {
  if (value == null) throw new Error('Value is null or undefined')
  return value
}
```

## Async Patterns

```typescript
// ✅ Always type async return values
const fetchUser = async (id: string): Promise<User> => {
  const res = await fetch(`/api/users/${id}`)
  if (!res.ok) throw new Error('Failed to fetch user')
  return res.json() as Promise<User>
}

// ✅ Error handling with unknown
try {
  await fetchUser(id)
} catch (error) {
  if (error instanceof Error) {
    console.error(error.message)
  }
}
```

## Forbidden Patterns

```typescript
// ❌ Never
const data: any = fetchData()
function process(x) { return x }  // implicit any
const obj = {} as User             // unsafe assertion
// @ts-ignore                      // suppressing errors
```

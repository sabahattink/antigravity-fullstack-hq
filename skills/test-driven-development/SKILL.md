---
name: test-driven-development
description: TDD red-green-refactor cycle, test structure, mocking patterns for Vitest/Jest. Use when starting a new feature, fixing a bug, or refactoring — write the test first, then the implementation.
---

# Test-Driven Development

## The Red-Green-Refactor Cycle

```
RED    → Write a failing test that describes the desired behavior
GREEN  → Write the minimum code to make it pass (no more, no less)
REFACTOR → Improve the code without changing behavior; tests stay green
```

Never skip the RED step. If you write code before the test, you lose confidence that your test actually tests anything.

## Test Structure: AAA Pattern

```typescript
// Arrange → Act → Assert — every test follows this shape

describe('UserService', () => {
  describe('create', () => {
    it('should hash the password before saving', async () => {
      // ARRANGE — set up everything the test needs
      const dto: CreateUserDto = {
        email: 'jane@example.com',
        password: 'S3cureP@ss!',
        name: 'Jane Doe',
      }
      const mockRepo    = createMockUserRepo()
      const mockHasher  = createMockHasher({ result: 'hashed_password' })
      const sut         = new UserService(mockRepo, mockHasher)

      // ACT — call the thing under test
      await sut.create(dto)

      // ASSERT — verify outcomes
      expect(mockHasher.hash).toHaveBeenCalledWith('S3cureP@ss!')
      expect(mockRepo.save).toHaveBeenCalledWith(
        expect.objectContaining({ passwordHash: 'hashed_password' })
      )
    })
  })
})
```

## Vitest Setup

```typescript
// vitest.config.ts
import { defineConfig } from 'vitest/config'
import tsconfigPaths from 'vite-tsconfig-paths'

export default defineConfig({
  plugins: [tsconfigPaths()],
  test: {
    globals:     true,
    environment: 'node',
    setupFiles:  ['./src/test/setup.ts'],
    coverage: {
      provider:   'v8',
      reporter:   ['text', 'html', 'lcov'],
      thresholds: { lines: 80, functions: 80, branches: 80 },
      exclude:    ['**/*.dto.ts', '**/*.entity.ts', '**/index.ts'],
    },
  },
})

// src/test/setup.ts
import { vi } from 'vitest'

// Reset all mocks between tests — prevents state leakage
beforeEach(() => { vi.clearAllMocks() })
afterEach(() => { vi.restoreAllMocks() })
```

## Mocking Patterns

### Factory Functions for Mocks
```typescript
// test/factories/user-repo.factory.ts
import { vi } from 'vitest'
import type { IUserRepository } from '../../domain/user/user.repository.interface'

export function createMockUserRepo(
  overrides: Partial<IUserRepository> = {}
): jest.Mocked<IUserRepository> {
  return {
    findById:      vi.fn().mockResolvedValue(null),
    findByEmail:   vi.fn().mockResolvedValue(null),
    existsByEmail: vi.fn().mockResolvedValue(false),
    save:          vi.fn().mockResolvedValue(undefined),
    delete:        vi.fn().mockResolvedValue(undefined),
    ...overrides,
  }
}

// Usage in a test
const repo = createMockUserRepo({
  findByEmail: vi.fn().mockResolvedValue(existingUser),
})
```

### Spying on Methods
```typescript
// Spy on a real object's method without replacing implementation
it('should call findById with the correct id', async () => {
  const repo   = new UserTypeOrmRepository(dataSource)
  const spy    = vi.spyOn(repo, 'findById')
  const service = new UserService(repo)

  await service.findOneOrFail(42)

  expect(spy).toHaveBeenCalledWith(42)
  expect(spy).toHaveBeenCalledTimes(1)
})
```

### Module Mocking
```typescript
// Mock an entire module
vi.mock('../lib/email-client', () => ({
  sendEmail: vi.fn().mockResolvedValue({ messageId: 'mock-id' }),
}))

// In test:
import { sendEmail } from '../lib/email-client'
expect(sendEmail).toHaveBeenCalledWith(
  expect.objectContaining({ to: 'jane@example.com' })
)
```

## Testing Domain Logic

```typescript
// Pure domain logic — no mocks needed, just test the entity
describe('User entity', () => {
  describe('rename', () => {
    it('should return a new User with the updated name', () => {
      const user = User.create({ id: UserId.generate(), email: Email.create('j@x.com'), name: 'Old Name' })

      const updated = user.rename('New Name')

      expect(updated.name).toBe('New Name')
      expect(user.name).toBe('Old Name')  // original is unchanged — immutability
    })

    it('should throw DomainError when name is blank', () => {
      const user = User.create({ id: UserId.generate(), email: Email.create('j@x.com'), name: 'Jane' })

      expect(() => user.rename('   ')).toThrow(DomainError)
      expect(() => user.rename('   ')).toThrow('Name cannot be empty')
    })
  })

  describe('promote', () => {
    it('should throw DomainError when actor is not admin', () => {
      const actor  = makeUser({ role: UserRole.USER })
      const target = makeUser({ role: UserRole.USER })

      expect(() => target.promote(UserRole.ADMIN, actor)).toThrow(DomainError)
    })
  })
})
```

## Testing Services (Unit)

```typescript
describe('CreateUserHandler', () => {
  let handler: CreateUserHandler
  let repo:    ReturnType<typeof createMockUserRepo>
  let hasher:  { hash: ReturnType<typeof vi.fn> }
  let eventBus: { publish: ReturnType<typeof vi.fn> }

  beforeEach(() => {
    repo     = createMockUserRepo()
    hasher   = { hash: vi.fn().mockResolvedValue('$2b$12$hashed') }
    eventBus = { publish: vi.fn() }
    handler  = new CreateUserHandler(repo, hasher, eventBus)
  })

  it('should save a new user and publish UserCreatedEvent', async () => {
    const cmd = new CreateUserCommand('jane@example.com', 'Pass123!', 'Jane', 'actor-id')

    const userId = await handler.execute(cmd)

    expect(repo.save).toHaveBeenCalledTimes(1)
    expect(eventBus.publish).toHaveBeenCalledWith(
      expect.objectContaining({ eventType: 'user.created', email: 'jane@example.com' })
    )
    expect(userId).toBeDefined()
  })

  it('should throw ConflictException when email already exists', async () => {
    repo.existsByEmail.mockResolvedValue(true)

    await expect(
      handler.execute(new CreateUserCommand('taken@example.com', 'Pass123!', 'Bob', 'actor'))
    ).rejects.toThrow(ConflictException)

    expect(repo.save).not.toHaveBeenCalled()
  })
})
```

## Integration Tests with Test DB

```typescript
// test/integration/users.integration.spec.ts
import { Test } from '@nestjs/testing'
import { TypeOrmModule } from '@nestjs/typeorm'
import { getRepositoryToken } from '@nestjs/typeorm'

describe('UsersService (integration)', () => {
  let app: INestApplication
  let service: UsersService

  beforeAll(async () => {
    const module = await Test.createTestingModule({
      imports: [
        TypeOrmModule.forRoot({
          type:       'sqlite',
          database:   ':memory:',
          entities:   [UserOrmEntity],
          synchronize: true,
        }),
        TypeOrmModule.forFeature([UserOrmEntity]),
        UsersModule,
      ],
    }).compile()

    app     = module.createNestApplication()
    service = module.get(UsersService)
    await app.init()
  })

  afterAll(() => app.close())

  afterEach(async () => {
    // Clean up between tests
    const repo = app.get(getRepositoryToken(UserOrmEntity))
    await repo.clear()
  })

  it('should persist and retrieve a user', async () => {
    const created = await service.create(
      { email: 'test@example.com', password: 'Pass123!', name: 'Test' },
      { id: 'actor-1' } as AuthUser
    )

    const found = await service.findOneOrFail(created.id)

    expect(found.email).toBe('test@example.com')
    expect(found.name).toBe('Test')
  })
})
```

## Test Doubles Reference

| Type | When to Use |
|------|-------------|
| **Stub** | Return a canned value (no assertions needed) |
| **Mock** | Verify calls were made (use `expect(mock).toHaveBeenCalled`) |
| **Spy** | Wrap a real method to observe calls |
| **Fake** | Lightweight real implementation (in-memory DB) |
| **Dummy** | Placeholder that's never called (satisfy a constructor) |

## Coverage Targets

```
lines:     80% minimum
functions: 80% minimum
branches:  80% minimum
```

Exclude from coverage:
- DTOs, entities, configuration files
- `index.ts` barrel files
- Migration files
- Type declaration files (`*.d.ts`)

## Test File Organization

```
src/
├── users/
│   ├── users.service.ts
│   ├── users.service.spec.ts        # unit test — same dir
│   └── users.repository.spec.ts
test/
├── integration/
│   └── users.integration.spec.ts    # integration — separate dir
├── e2e/
│   └── users.e2e.spec.ts
└── factories/
    ├── user.factory.ts
    └── order.factory.ts
```

## Forbidden Patterns

- Never test implementation details — test observable behavior
- Never share mutable state between tests — use `beforeEach` to reset
- Never write tests that depend on execution order
- Never assert on exact error messages from third-party libraries — those can change
- Never mock the system under test (SUT) itself
- Never skip the failing test step (RED) — you need to see it fail first
- Never write tests for trivial getters/setters — focus on behavior
- Never use `setTimeout` in tests — use fake timers (`vi.useFakeTimers()`)

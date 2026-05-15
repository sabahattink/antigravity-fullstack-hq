---
name: webapp-testing
description: Playwright E2E patterns, Testing Library component tests, test selectors. Use when writing browser tests, component tests, or setting up an E2E testing pipeline for a Next.js or React app.
---

# Web App Testing

## Testing Pyramid

```
          /\
         /E2E\        ← Few, slow, high confidence (Playwright)
        /------\
       / Integr \     ← Some, medium speed (RTL + MSW)
      /----------\
     /  Unit/Comp \   ← Many, fast, isolated (Vitest + RTL)
    /--------------\
```

## Playwright Setup

```bash
npm i -D @playwright/test
npx playwright install chromium firefox webkit
```

```typescript
// playwright.config.ts
import { defineConfig, devices } from '@playwright/test'

export default defineConfig({
  testDir:   './e2e',
  timeout:   30_000,
  retries:   process.env.CI ? 2 : 0,
  workers:   process.env.CI ? 1 : undefined,
  reporter:  [['html'], ['list']],

  use: {
    baseURL:       'http://localhost:3000',
    trace:         'on-first-retry',
    screenshot:    'only-on-failure',
    video:         'retain-on-failure',
  },

  projects: [
    { name: 'chromium', use: { ...devices['Desktop Chrome'] } },
    { name: 'firefox',  use: { ...devices['Desktop Firefox'] } },
    { name: 'mobile',   use: { ...devices['iPhone 14'] } },
  ],

  webServer: {
    command: 'npm run build && npm run start',
    url:     'http://localhost:3000',
    reuseExistingServer: !process.env.CI,
  },
})
```

## Page Object Model

```typescript
// e2e/pages/login.page.ts
import { Page, Locator, expect } from '@playwright/test'

export class LoginPage {
  readonly emailInput:    Locator
  readonly passwordInput: Locator
  readonly submitButton:  Locator
  readonly errorMessage:  Locator

  constructor(private page: Page) {
    this.emailInput    = page.getByLabel('Email')
    this.passwordInput = page.getByLabel('Password')
    this.submitButton  = page.getByRole('button', { name: 'Sign in' })
    this.errorMessage  = page.getByRole('alert')
  }

  async goto() {
    await this.page.goto('/login')
  }

  async login(email: string, password: string) {
    await this.emailInput.fill(email)
    await this.passwordInput.fill(password)
    await this.submitButton.click()
  }

  async expectError(message: string) {
    await expect(this.errorMessage).toContainText(message)
  }
}

// e2e/pages/dashboard.page.ts
export class DashboardPage {
  constructor(private page: Page) {}

  async expectWelcome(name: string) {
    await expect(this.page.getByRole('heading', { level: 1 })).toContainText(`Welcome, ${name}`)
  }
}
```

## Playwright Test Examples

```typescript
// e2e/auth/login.spec.ts
import { test, expect } from '@playwright/test'
import { LoginPage } from '../pages/login.page'
import { DashboardPage } from '../pages/dashboard.page'

test.describe('Login flow', () => {
  test('successful login redirects to dashboard', async ({ page }) => {
    const loginPage = new LoginPage(page)
    const dashboard = new DashboardPage(page)

    await loginPage.goto()
    await loginPage.login('admin@example.com', 'password123')

    await expect(page).toHaveURL('/dashboard')
    await dashboard.expectWelcome('Admin')
  })

  test('invalid credentials shows error message', async ({ page }) => {
    const loginPage = new LoginPage(page)

    await loginPage.goto()
    await loginPage.login('bad@example.com', 'wrongpassword')

    await loginPage.expectError('Invalid email or password')
    await expect(page).toHaveURL('/login')
  })

  test('email field is required', async ({ page }) => {
    const loginPage = new LoginPage(page)
    await loginPage.goto()

    await loginPage.submitButton.click()

    // HTML5 validation
    await expect(loginPage.emailInput).toBeFocused()
  })
})
```

## Authenticated Tests

```typescript
// e2e/fixtures/auth.fixture.ts
import { test as base, Page } from '@playwright/test'

interface AuthFixtures {
  authenticatedPage: Page
  adminPage: Page
}

export const test = base.extend<AuthFixtures>({
  // Regular user
  authenticatedPage: async ({ browser }, use) => {
    const context = await browser.newContext({
      storageState: 'e2e/.auth/user.json',
    })
    const page = await context.newPage()
    await use(page)
    await context.close()
  },

  // Admin user
  adminPage: async ({ browser }, use) => {
    const context = await browser.newContext({
      storageState: 'e2e/.auth/admin.json',
    })
    const page = await context.newPage()
    await use(page)
    await context.close()
  },
})

// e2e/auth/setup.ts — run once before all tests
import { chromium } from '@playwright/test'

async function globalSetup() {
  const browser = await chromium.launch()

  // Save user session
  const userCtx = await browser.newContext()
  const userPage = await userCtx.newPage()
  await userPage.goto('http://localhost:3000/login')
  await userPage.fill('[name=email]', 'user@example.com')
  await userPage.fill('[name=password]', 'password')
  await userPage.click('button[type=submit]')
  await userPage.waitForURL('**/dashboard')
  await userCtx.storageState({ path: 'e2e/.auth/user.json' })

  await browser.close()
}

export default globalSetup
```

## React Testing Library

```typescript
// components/UserCard/UserCard.test.tsx
import { render, screen, fireEvent, waitFor } from '@testing-library/react'
import userEvent from '@testing-library/user-event'
import { UserCard } from './UserCard'

describe('UserCard', () => {
  const user = {
    id: 1,
    name: 'Jane Doe',
    email: 'jane@example.com',
    role: 'admin' as const,
  }

  it('renders user name and email', () => {
    render(<UserCard user={user} />)

    expect(screen.getByRole('heading', { name: 'Jane Doe' })).toBeInTheDocument()
    expect(screen.getByText('jane@example.com')).toBeInTheDocument()
    expect(screen.getByText('admin')).toBeInTheDocument()
  })

  it('calls onDelete when delete button is clicked', async () => {
    const onDelete = vi.fn()
    render(<UserCard user={user} onDelete={onDelete} />)

    const deleteButton = screen.getByRole('button', { name: /delete/i })
    await userEvent.click(deleteButton)

    expect(onDelete).toHaveBeenCalledWith(user.id)
  })

  it('shows confirmation dialog before deleting', async () => {
    const onDelete = vi.fn()
    render(<UserCard user={user} onDelete={onDelete} />)

    await userEvent.click(screen.getByRole('button', { name: /delete/i }))

    expect(screen.getByRole('dialog')).toBeInTheDocument()
    expect(screen.getByText(/are you sure/i)).toBeInTheDocument()
    expect(onDelete).not.toHaveBeenCalled()

    await userEvent.click(screen.getByRole('button', { name: /confirm/i }))

    expect(onDelete).toHaveBeenCalledWith(user.id)
  })
})
```

## Mocking API Calls with MSW

```typescript
// test/mocks/handlers.ts
import { http, HttpResponse } from 'msw'

export const handlers = [
  http.get('/api/v1/users', () => {
    return HttpResponse.json({
      success: true,
      data: [
        { id: 1, name: 'Jane Doe', email: 'jane@example.com' },
        { id: 2, name: 'John Smith', email: 'john@example.com' },
      ],
      meta: { total: 2, page: 1, limit: 20, pages: 1 },
    })
  }),

  http.post('/api/v1/users', async ({ request }) => {
    const body = await request.json() as CreateUserDto
    return HttpResponse.json({
      success: true,
      data: { id: 3, ...body },
    }, { status: 201 })
  }),

  http.get('/api/v1/users/:id', ({ params }) => {
    if (params.id === '999') {
      return HttpResponse.json(
        { success: false, error: { code: 'USER_NOT_FOUND', message: 'Not found' } },
        { status: 404 }
      )
    }
    return HttpResponse.json({ success: true, data: { id: Number(params.id), name: 'Test' } })
  }),
]

// test/mocks/server.ts
import { setupServer } from 'msw/node'
import { handlers } from './handlers'
export const server = setupServer(...handlers)

// test/setup.ts
import { server } from './mocks/server'
beforeAll(() => server.listen({ onUnhandledRequest: 'error' }))
afterEach(() => server.resetHandlers())
afterAll(() => server.close())
```

## Selector Priority

```typescript
// Priority order (highest to lowest confidence):
// 1. getByRole        — reflects what users and screen readers see
// 2. getByLabelText   — form fields
// 3. getByPlaceholderText
// 4. getByText        — visible text
// 5. getByDisplayValue
// 6. getByAltText     — img alt
// 7. getByTitle
// 8. getByTestId      — last resort, use data-testid sparingly

// Good
screen.getByRole('button', { name: /submit/i })
screen.getByLabelText('Email address')
screen.getByRole('heading', { name: 'Dashboard', level: 1 })

// Avoid (brittle, tied to implementation)
document.querySelector('.btn-primary')
container.firstChild
screen.getByTestId('submit-btn')  // only when roles don't work
```

## Async Patterns

```typescript
// Wait for element to appear
await screen.findByText('Loading complete')
await screen.findByRole('table')

// Wait for element to disappear
await waitForElementToBeRemoved(() => screen.queryByText('Loading...'))

// Wait for DOM change
await waitFor(() => {
  expect(screen.getByText('3 items')).toBeInTheDocument()
}, { timeout: 3000 })

// Playwright: wait for network
await page.waitForResponse('**/api/v1/users')
await page.waitForLoadState('networkidle')
```

## Forbidden Patterns

- Never use `getByTestId` when a role/label selector would work
- Never test implementation details (state, method calls) — test user-visible behavior
- Never write Playwright tests that depend on hardcoded data IDs — use dynamic selectors
- Never add `sleep` / `waitForTimeout` — use proper waitFor / findBy
- Never skip error state tests — test the unhappy path
- Never share browser context between tests — each test should be isolated
- Never test styling with RTL — that belongs in visual regression (Chromatic/Percy)

---
name: github-actions
description: CI/CD workflow patterns, testing pipelines, deployment automation. Use when setting up GitHub Actions workflows for testing, building, linting, or deploying a fullstack app.
---

# GitHub Actions

## Full CI Pipeline

```yaml
# .github/workflows/ci.yml
name: CI

on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main, develop]

concurrency:
  group: ${{ github.workflow }}-${{ github.ref }}
  cancel-in-progress: true  # Cancel stale runs on new push

jobs:
  # ─── Lint & Type Check ─────────────────────────────────────
  lint:
    name: Lint & Type Check
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - uses: pnpm/action-setup@v4
        with: { version: 9 }

      - uses: actions/setup-node@v4
        with:
          node-version: 22
          cache: pnpm

      - run: pnpm install --frozen-lockfile

      - name: Type check (API)
        run: pnpm --filter api run type-check

      - name: Type check (Web)
        run: pnpm --filter web run type-check

      - name: Lint
        run: pnpm run lint

  # ─── Unit Tests ────────────────────────────────────────────
  test-unit:
    name: Unit Tests
    runs-on: ubuntu-latest
    needs: lint
    steps:
      - uses: actions/checkout@v4

      - uses: pnpm/action-setup@v4
        with: { version: 9 }

      - uses: actions/setup-node@v4
        with:
          node-version: 22
          cache: pnpm

      - run: pnpm install --frozen-lockfile

      - name: Run unit tests
        run: pnpm --filter api run test:cov

      - name: Upload coverage
        uses: codecov/codecov-action@v4
        with:
          token: ${{ secrets.CODECOV_TOKEN }}
          files: ./apps/api/coverage/lcov.info

  # ─── Integration Tests ─────────────────────────────────────
  test-integration:
    name: Integration Tests
    runs-on: ubuntu-latest
    needs: lint

    services:
      postgres:
        image: postgres:16-alpine
        env:
          POSTGRES_DB:       test_db
          POSTGRES_USER:     postgres
          POSTGRES_PASSWORD: postgres
        ports: ["5432:5432"]
        options: >-
          --health-cmd pg_isready
          --health-interval 5s
          --health-timeout 5s
          --health-retries 5

      redis:
        image: redis:7-alpine
        ports: ["6379:6379"]
        options: >-
          --health-cmd "redis-cli ping"
          --health-interval 5s
          --health-retries 5

    steps:
      - uses: actions/checkout@v4

      - uses: pnpm/action-setup@v4
        with: { version: 9 }

      - uses: actions/setup-node@v4
        with: { node-version: 22, cache: pnpm }

      - run: pnpm install --frozen-lockfile

      - name: Run migrations
        run: pnpm --filter api run migration:run
        env:
          DATABASE_URL: postgresql://postgres:postgres@localhost:5432/test_db

      - name: Run integration tests
        run: pnpm --filter api run test:integration
        env:
          DATABASE_URL: postgresql://postgres:postgres@localhost:5432/test_db
          REDIS_URL:    redis://localhost:6379
          JWT_SECRET:   test-secret-32-chars-minimum-length

  # ─── E2E Tests ─────────────────────────────────────────────
  test-e2e:
    name: E2E Tests (Playwright)
    runs-on: ubuntu-latest
    needs: [test-unit, test-integration]
    timeout-minutes: 20

    services:
      postgres:
        image: postgres:16-alpine
        env: { POSTGRES_DB: e2e_db, POSTGRES_USER: postgres, POSTGRES_PASSWORD: postgres }
        ports: ["5432:5432"]
        options: --health-cmd pg_isready --health-interval 5s --health-retries 5

    steps:
      - uses: actions/checkout@v4

      - uses: pnpm/action-setup@v4
        with: { version: 9 }

      - uses: actions/setup-node@v4
        with: { node-version: 22, cache: pnpm }

      - run: pnpm install --frozen-lockfile

      - name: Cache Playwright browsers
        uses: actions/cache@v4
        id: pw-cache
        with:
          path: ~/.cache/ms-playwright
          key: playwright-${{ hashFiles('**/package.json') }}

      - name: Install Playwright browsers
        if: steps.pw-cache.outputs.cache-hit != 'true'
        run: pnpm exec playwright install --with-deps chromium

      - name: Build apps
        env:
          DATABASE_URL: postgresql://postgres:postgres@localhost:5432/e2e_db
        run: pnpm run build

      - name: Run E2E tests
        run: pnpm run test:e2e
        env:
          DATABASE_URL: postgresql://postgres:postgres@localhost:5432/e2e_db
          PLAYWRIGHT_BASE_URL: http://localhost:3000

      - name: Upload Playwright report
        if: failure()
        uses: actions/upload-artifact@v4
        with:
          name: playwright-report
          path: playwright-report/
          retention-days: 7
```

## Deploy Workflow

```yaml
# .github/workflows/deploy.yml
name: Deploy

on:
  push:
    branches: [main]
  workflow_dispatch:
    inputs:
      environment:
        description: Target environment
        required: true
        default: staging
        type: choice
        options: [staging, production]

jobs:
  deploy-backend:
    name: Deploy API to Railway
    runs-on: ubuntu-latest
    environment: ${{ github.event.inputs.environment || 'staging' }}

    steps:
      - uses: actions/checkout@v4

      - name: Install Railway CLI
        run: npm i -g @railway/cli

      - name: Deploy to Railway
        run: railway up --service api --detach
        env:
          RAILWAY_TOKEN: ${{ secrets.RAILWAY_TOKEN }}

      - name: Wait for deployment health
        run: |
          for i in {1..12}; do
            STATUS=$(curl -s -o /dev/null -w "%{http_code}" ${{ vars.API_URL }}/health/liveness)
            if [ "$STATUS" == "200" ]; then
              echo "API is healthy"
              exit 0
            fi
            echo "Attempt $i: status=$STATUS, waiting..."
            sleep 10
          done
          echo "Health check failed after 2 minutes"
          exit 1

  deploy-frontend:
    name: Deploy Web to Vercel
    runs-on: ubuntu-latest
    needs: deploy-backend
    environment: ${{ github.event.inputs.environment || 'staging' }}

    steps:
      - uses: actions/checkout@v4

      - uses: pnpm/action-setup@v4
        with: { version: 9 }

      - uses: actions/setup-node@v4
        with: { node-version: 22, cache: pnpm }

      - run: pnpm install --frozen-lockfile

      - name: Deploy to Vercel
        run: |
          pnpm dlx vercel \
            --token=${{ secrets.VERCEL_TOKEN }} \
            --prod \
            ${{ github.event.inputs.environment == 'production' && '--prod' || '' }}
        env:
          VERCEL_ORG_ID:     ${{ secrets.VERCEL_ORG_ID }}
          VERCEL_PROJECT_ID: ${{ secrets.VERCEL_PROJECT_ID }}
```

## Reusable Workflow

```yaml
# .github/workflows/_setup-node.yml
name: Setup Node (Reusable)

on:
  workflow_call:
    inputs:
      node-version:
        type: string
        default: '22'

jobs:
  setup:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: pnpm/action-setup@v4
        with: { version: 9 }
      - uses: actions/setup-node@v4
        with:
          node-version: ${{ inputs.node-version }}
          cache: pnpm
      - run: pnpm install --frozen-lockfile

# Usage:
# jobs:
#   setup:
#     uses: ./.github/workflows/_setup-node.yml
```

## PR Checks & Branch Protection

```yaml
# .github/workflows/pr-checks.yml
name: PR Checks

on:
  pull_request:
    types: [opened, synchronize, reopened, edited]

jobs:
  pr-title:
    name: Validate PR Title
    runs-on: ubuntu-latest
    steps:
      - uses: amannn/action-semantic-pull-request@v5
        env:
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
        with:
          types: [feat, fix, refactor, docs, test, chore, perf, ci]
          requireScope: false

  check-diff:
    name: Check Changed Files
    runs-on: ubuntu-latest
    outputs:
      api-changed: ${{ steps.changes.outputs.api }}
      web-changed: ${{ steps.changes.outputs.web }}
    steps:
      - uses: actions/checkout@v4
      - uses: dorny/paths-filter@v3
        id: changes
        with:
          filters: |
            api:
              - 'apps/api/**'
              - 'packages/**'
            web:
              - 'apps/web/**'
              - 'packages/**'
```

## Secrets Required

```
# Repository → Settings → Secrets and variables → Actions
RAILWAY_TOKEN       — Railway API token for backend deploys
VERCEL_TOKEN        — Vercel CLI token
VERCEL_ORG_ID       — Vercel organization ID
VERCEL_PROJECT_ID   — Vercel project ID
CODECOV_TOKEN       — Codecov upload token

# Variables (non-secret)
API_URL             — https://api.example.com (for health checks)
```

## Caching Strategy

```yaml
# Cache node_modules (pnpm store)
- uses: actions/cache@v4
  with:
    path: ~/.local/share/pnpm/store
    key: pnpm-${{ runner.os }}-${{ hashFiles('**/pnpm-lock.yaml') }}
    restore-keys: pnpm-${{ runner.os }}-

# Cache Next.js build
- uses: actions/cache@v4
  with:
    path: ${{ github.workspace }}/apps/web/.next/cache
    key: nextjs-${{ runner.os }}-${{ hashFiles('**/pnpm-lock.yaml') }}-${{ hashFiles('apps/web/**/*.ts', 'apps/web/**/*.tsx') }}
    restore-keys: nextjs-${{ runner.os }}-${{ hashFiles('**/pnpm-lock.yaml') }}-
```

## Forbidden Patterns

- Never hardcode secrets as plain text in workflow files
- Never use `continue-on-error: true` to hide test failures
- Never deploy without a prior successful test run
- Never use `actions/checkout@v2` or older — use v4
- Never skip `--frozen-lockfile` — it ensures reproducible installs
- Never give workflows more permissions than needed (use `permissions: read-all` as default)
- Never run E2E tests before unit/integration pass — it wastes expensive minutes

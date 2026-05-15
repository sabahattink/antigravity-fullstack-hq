---
name: deployment-guide
description: Vercel frontend + Railway/Fly.io backend deployment, env vars, health checks. Use when deploying a Next.js frontend to Vercel or a NestJS backend to Railway or Fly.io, or troubleshooting a deployment issue.
---

# Deployment Guide

## Frontend — Vercel

### Setup
```bash
# Install Vercel CLI
npm i -g vercel

# Login
vercel login

# Link project (run once in the project root)
vercel link

# Deploy to preview
vercel

# Deploy to production
vercel --prod
```

### vercel.json
```json
{
  "framework": "nextjs",
  "buildCommand": "pnpm run build",
  "installCommand": "pnpm install --frozen-lockfile",
  "outputDirectory": ".next",
  "regions": ["iad1"],
  "headers": [
    {
      "source": "/(.*)",
      "headers": [
        { "key": "X-Content-Type-Options", "value": "nosniff" },
        { "key": "X-Frame-Options",        "value": "DENY" },
        { "key": "X-XSS-Protection",       "value": "1; mode=block" },
        { "key": "Referrer-Policy",        "value": "strict-origin-when-cross-origin" }
      ]
    },
    {
      "source": "/api/(.*)",
      "headers": [
        { "key": "Cache-Control", "value": "no-store, max-age=0" }
      ]
    },
    {
      "source": "/_next/static/(.*)",
      "headers": [
        { "key": "Cache-Control", "value": "public, max-age=31536000, immutable" }
      ]
    }
  ],
  "rewrites": [
    {
      "source": "/api/:path*",
      "destination": "https://api.example.com/api/:path*"
    }
  ]
}
```

### Vercel Environment Variables
```bash
# Set env vars per environment
vercel env add NEXT_PUBLIC_API_URL production
vercel env add NEXT_PUBLIC_API_URL preview
vercel env add NEXT_PUBLIC_API_URL development

# Pull to local .env.local
vercel env pull .env.local
```

### next.config.ts for Production
```typescript
import type { NextConfig } from 'next'

const config: NextConfig = {
  output: 'standalone',

  // Strict mode catches side effects in development
  reactStrictMode: true,

  // Image optimization
  images: {
    domains: ['cdn.example.com', 'avatars.githubusercontent.com'],
    formats: ['image/avif', 'image/webp'],
  },

  // Bundle analyzer (install @next/bundle-analyzer)
  // ...(process.env.ANALYZE === 'true' && require('@next/bundle-analyzer')())

  // Security headers
  async headers() {
    return [
      {
        source: '/(.*)',
        headers: [
          { key: 'X-DNS-Prefetch-Control', value: 'on' },
        ],
      },
    ]
  },

  // Redirects
  async redirects() {
    return [
      { source: '/old-path', destination: '/new-path', permanent: true },
    ]
  },
}

export default config
```

## Backend — Railway

### Setup
```bash
# Install Railway CLI
npm i -g @railway/cli

# Login
railway login

# Initialize (run in project root)
railway init

# Deploy
railway up

# Open dashboard
railway open

# View logs
railway logs

# Run commands in service
railway run pnpm run migration:run
```

### railway.json
```json
{
  "$schema": "https://railway.app/railway.schema.json",
  "build": {
    "builder":      "DOCKERFILE",
    "dockerfilePath": "apps/api/Dockerfile"
  },
  "deploy": {
    "startCommand": "node dist/main",
    "healthcheckPath": "/health/liveness",
    "healthcheckTimeout": 30,
    "restartPolicyType": "ON_FAILURE",
    "restartPolicyMaxRetries": 3
  }
}
```

### Required Environment Variables (Railway)
```bash
# Set via Railway dashboard or CLI
DATABASE_URL    = ${{Postgres.DATABASE_URL}}   # Railway managed Postgres
REDIS_URL       = ${{Redis.REDIS_URL}}          # Railway managed Redis
NODE_ENV        = production
PORT            = ${{PORT}}                     # Railway injects this
JWT_SECRET      = <generate: openssl rand -base64 32>
CORS_ORIGINS    = https://your-app.vercel.app
LOG_LEVEL       = info
```

## Backend — Fly.io (Alternative)

### Setup
```bash
# Install flyctl
curl -L https://fly.io/install.sh | sh

# Login
fly auth login

# Launch app (creates fly.toml)
fly launch --name my-api --region iad --no-deploy

# Deploy
fly deploy

# Scale
fly scale count 2
fly scale memory 512

# View logs
fly logs

# SSH into instance
fly ssh console
```

### fly.toml
```toml
app      = "my-api"
primary_region = "iad"

[build]
  dockerfile = "apps/api/Dockerfile"

[env]
  NODE_ENV  = "production"
  PORT      = "8080"

[http_service]
  internal_port = 8080
  force_https   = true
  auto_stop_machines  = true
  auto_start_machines = true
  min_machines_running = 1

  [http_service.concurrency]
    type       = "connections"
    hard_limit = 200
    soft_limit = 150

[[vm]]
  memory   = "512mb"
  cpu_kind = "shared"
  cpus     = 1

[checks]
  [checks.health]
    grace_period  = "30s"
    interval      = "15s"
    method        = "GET"
    path          = "/health/liveness"
    port          = 8080
    timeout       = "5s"
    type          = "http"
```

## Health Check Endpoints

```typescript
// health/health.controller.ts — must respond before traffic is routed

@Controller('health')
export class HealthController {
  constructor(
    private health:  HealthCheckService,
    private db:      TypeOrmHealthIndicator,
  ) {}

  // Liveness: is the process running?
  @Get('liveness')
  liveness() {
    return { status: 'ok', timestamp: new Date().toISOString() }
  }

  // Readiness: can we serve traffic?
  @Get('readiness')
  @HealthCheck()
  readiness() {
    return this.health.check([
      () => this.db.pingCheck('database', { timeout: 3000 }),
    ])
  }

  // Full check: all dependencies
  @Get()
  @HealthCheck()
  full() {
    return this.health.check([
      () => this.db.pingCheck('database'),
    ])
  }
}
```

## Database Migrations on Deploy

```typescript
// src/cli.ts — run as a separate Railway service or pre-deploy command
import { NestFactory } from '@nestjs/core'
import { MigrationModule } from './migration/migration.module'

async function runMigrations() {
  const app = await NestFactory.createApplicationContext(MigrationModule)
  const dataSource = app.get(DataSource)

  console.log('Running migrations...')
  const migrations = await dataSource.runMigrations()
  console.log(`Ran ${migrations.length} migrations`)

  await app.close()
  process.exit(0)
}

runMigrations().catch(err => {
  console.error('Migration failed:', err)
  process.exit(1)
})
```

```json
// package.json
{
  "scripts": {
    "migration:run": "ts-node src/cli.ts",
    "start:prod": "node dist/main"
  }
}
```

## Zero-Downtime Deployments

```bash
# Railway: automatic rolling deployments (no config needed)
# Fly.io: rolling deployments with health checks

# Ensure your app handles SIGTERM gracefully
```

```typescript
// main.ts — graceful shutdown
async function bootstrap() {
  const app = await NestFactory.create(AppModule)
  app.enableShutdownHooks()

  await app.listen(process.env.PORT ?? 3000)

  // Log when server is ready
  console.log(`API running on port ${process.env.PORT ?? 3000}`)
}
```

## Environment Checklist

```
Production Environment Variables Checklist:
□ NODE_ENV=production
□ DATABASE_URL (managed service with connection pooling)
□ REDIS_URL (if using caching/sessions)
□ JWT_SECRET (min 32 chars, random)
□ CORS_ORIGINS (exact frontend domains, no wildcards)
□ LOG_LEVEL=info (not debug)
□ PORT (injected by platform)

Frontend:
□ NEXT_PUBLIC_API_URL (production backend URL)
□ No secrets in NEXT_PUBLIC_* vars (they're exposed to browser)
```

## Forbidden Patterns

- Never deploy with `NODE_ENV=development` in production
- Never use the same JWT secret across environments
- Never skip health check endpoints — platforms use them for traffic routing
- Never run database migrations during app startup — run them as a separate step
- Never put `NEXT_PUBLIC_*` values that are secrets — they're bundled into the browser
- Never deploy without verifying the build passes CI first
- Never use `0.0.0.0` as `CORS_ORIGINS` in production — specify exact origins

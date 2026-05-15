---
name: docker-patterns
description: Dockerfile best practices, multi-stage builds, docker-compose for dev/prod. Use when setting up containerization for a NestJS backend or Next.js frontend, or configuring a local dev environment with docker-compose.
---

# Docker Patterns

## NestJS Multi-Stage Dockerfile

```dockerfile
# Dockerfile (backend)
# syntax=docker/dockerfile:1.5

FROM node:22-alpine AS base
WORKDIR /app
# Install only production deps in base
RUN corepack enable

# ─── deps stage ──────────────────────────────────────────────
FROM base AS deps
COPY package.json pnpm-lock.yaml ./
RUN --mount=type=cache,target=/root/.local/share/pnpm/store \
    pnpm install --frozen-lockfile

# ─── build stage ─────────────────────────────────────────────
FROM deps AS build
COPY . .
RUN pnpm run build

# ─── production stage ────────────────────────────────────────
FROM base AS production
ENV NODE_ENV=production

# Create non-root user
RUN addgroup --system --gid 1001 nodejs && \
    adduser  --system --uid 1001 nestjs

# Copy only what's needed to run
COPY --from=deps  --chown=nestjs:nodejs /app/node_modules ./node_modules
COPY --from=build --chown=nestjs:nodejs /app/dist         ./dist
COPY --from=build --chown=nestjs:nodejs /app/package.json ./package.json

USER nestjs

EXPOSE 3000
HEALTHCHECK --interval=30s --timeout=3s --retries=3 \
  CMD wget -qO- http://localhost:3000/health/liveness || exit 1

CMD ["node", "dist/main"]
```

## Next.js Multi-Stage Dockerfile

```dockerfile
# Dockerfile (frontend)
# syntax=docker/dockerfile:1.5
FROM node:22-alpine AS base
RUN corepack enable && apk add --no-cache libc6-compat
WORKDIR /app

# ─── deps ────────────────────────────────────────────────────
FROM base AS deps
COPY package.json pnpm-lock.yaml ./
RUN --mount=type=cache,target=/root/.local/share/pnpm/store \
    pnpm install --frozen-lockfile

# ─── build ───────────────────────────────────────────────────
FROM base AS builder
COPY --from=deps /app/node_modules ./node_modules
COPY . .
ENV NEXT_TELEMETRY_DISABLED=1
RUN pnpm run build

# ─── production ──────────────────────────────────────────────
FROM base AS runner
ENV NODE_ENV=production NEXT_TELEMETRY_DISABLED=1

RUN addgroup --system --gid 1001 nodejs && \
    adduser  --system --uid 1001 nextjs

COPY --from=builder /app/public ./public
COPY --from=builder --chown=nextjs:nodejs /app/.next/standalone ./
COPY --from=builder --chown=nextjs:nodejs /app/.next/static ./.next/static

USER nextjs
EXPOSE 3000
ENV PORT=3000 HOSTNAME="0.0.0.0"

HEALTHCHECK --interval=30s --timeout=3s --retries=3 \
  CMD wget -qO- http://localhost:3000/api/health || exit 1

CMD ["node", "server.js"]
```

## .dockerignore

```
# .dockerignore
node_modules
.next
dist
.git
.gitignore
*.md
.env*
!.env.example
coverage
.nyc_output
*.log
.DS_Store
Thumbs.db
```

## next.config.ts for Standalone Build

```typescript
// next.config.ts
const nextConfig = {
  output: 'standalone',  // Required for Docker production builds
  experimental: {
    serverComponentsExternalPackages: ['@prisma/client'],
  },
}
export default nextConfig
```

## Docker Compose — Development

```yaml
# docker-compose.yml
version: '3.9'

services:
  postgres:
    image: postgres:16-alpine
    restart: unless-stopped
    environment:
      POSTGRES_DB:       ${POSTGRES_DB:-antigravity}
      POSTGRES_USER:     ${POSTGRES_USER:-postgres}
      POSTGRES_PASSWORD: ${POSTGRES_PASSWORD:-postgres}
    ports:
      - "5432:5432"
    volumes:
      - postgres_data:/var/lib/postgresql/data
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U ${POSTGRES_USER:-postgres}"]
      interval: 5s
      timeout: 5s
      retries: 5

  redis:
    image: redis:7-alpine
    restart: unless-stopped
    ports:
      - "6379:6379"
    command: redis-server --appendonly yes
    volumes:
      - redis_data:/data
    healthcheck:
      test: ["CMD", "redis-cli", "ping"]
      interval: 5s
      retries: 5

  api:
    build:
      context: ./apps/api
      target: deps            # Use deps stage for hot reload
    restart: unless-stopped
    depends_on:
      postgres: { condition: service_healthy }
      redis:    { condition: service_healthy }
    environment:
      NODE_ENV:     development
      DATABASE_URL: postgresql://${POSTGRES_USER:-postgres}:${POSTGRES_PASSWORD:-postgres}@postgres:5432/${POSTGRES_DB:-antigravity}
      REDIS_URL:    redis://redis:6379
    ports:
      - "3001:3000"
      - "9229:9229"           # Debug port
    volumes:
      - ./apps/api/src:/app/src:ro
    command: pnpm run start:dev

  web:
    build:
      context: ./apps/web
      target: deps
    restart: unless-stopped
    depends_on: [api]
    environment:
      NEXT_PUBLIC_API_URL: http://localhost:3001
    ports:
      - "3000:3000"
    volumes:
      - ./apps/web/src:/app/src:ro
      - ./apps/web/public:/app/public:ro
    command: pnpm run dev

volumes:
  postgres_data:
  redis_data:
```

## Docker Compose — Production Override

```yaml
# docker-compose.prod.yml
version: '3.9'

services:
  api:
    build:
      target: production       # Override to prod stage
    restart: always
    environment:
      NODE_ENV: production
    volumes: []                # No volume mounts in prod
    command: node dist/main    # Override dev command

  web:
    build:
      target: runner
    restart: always
    volumes: []
    command: node server.js

  nginx:
    image: nginx:alpine
    restart: always
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - ./nginx/nginx.conf:/etc/nginx/nginx.conf:ro
      - ./nginx/ssl:/etc/nginx/ssl:ro
    depends_on: [web, api]
```

## Nginx Config

```nginx
# nginx/nginx.conf
events { worker_connections 1024; }

http {
    upstream api {
        server api:3000;
    }

    upstream web {
        server web:3000;
    }

    # Redirect HTTP to HTTPS
    server {
        listen 80;
        server_name example.com www.example.com;
        return 301 https://$host$request_uri;
    }

    server {
        listen 443 ssl http2;
        server_name example.com www.example.com;

        ssl_certificate     /etc/nginx/ssl/fullchain.pem;
        ssl_certificate_key /etc/nginx/ssl/privkey.pem;
        ssl_protocols       TLSv1.2 TLSv1.3;

        # Frontend
        location / {
            proxy_pass         http://web;
            proxy_http_version 1.1;
            proxy_set_header   Upgrade $http_upgrade;
            proxy_set_header   Connection 'upgrade';
            proxy_set_header   Host $host;
            proxy_cache_bypass $http_upgrade;
        }

        # Backend API
        location /api/ {
            proxy_pass         http://api;
            proxy_http_version 1.1;
            proxy_set_header   X-Real-IP $remote_addr;
            proxy_set_header   X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header   Host $host;
            proxy_read_timeout 300s;
        }
    }
}
```

## Useful Commands

```bash
# Build and run
docker compose up -d --build

# View logs
docker compose logs -f api
docker compose logs --tail=100 web

# Exec into running container
docker compose exec api sh
docker compose exec postgres psql -U postgres antigravity

# Run database migration
docker compose exec api node dist/cli.js migrate:run

# Rebuild a single service
docker compose up -d --build api

# Production build
docker compose -f docker-compose.yml -f docker-compose.prod.yml up -d --build

# Clean up everything
docker compose down -v --remove-orphans
```

## Secrets Management

```yaml
# docker-compose.yml — use secrets for sensitive values
secrets:
  db_password:
    file: ./secrets/db_password.txt
  jwt_secret:
    file: ./secrets/jwt_secret.txt

services:
  api:
    secrets:
      - db_password
      - jwt_secret
    environment:
      POSTGRES_PASSWORD_FILE: /run/secrets/db_password
      JWT_SECRET_FILE:        /run/secrets/jwt_secret
```

## Forbidden Patterns

- Never run containers as root in production — always create and use a non-root user
- Never put secrets in Dockerfile or docker-compose.yml — use secrets or env_file
- Never use `latest` tag for base images — pin to a specific digest or version
- Never copy `.env` files into the image — they get baked into layers permanently
- Never skip `.dockerignore` — `node_modules` in the image context wastes minutes
- Never run `npm install` in a production stage — install in a build stage, copy artifacts
- Never expose debug ports (9229) in production docker-compose
- Never commit `docker-compose.override.yml` with credentials to version control

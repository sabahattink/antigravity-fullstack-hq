---
name: security-checklist
description: OWASP Top 10, input validation, SQL injection prevention, rate limiting, CORS. Use when reviewing code for security issues, setting up a new API, or doing a pre-deploy security audit.
---

# Security Checklist

## OWASP Top 10 — Quick Reference

| # | Risk | Mitigation |
|---|------|-----------|
| A01 | Broken Access Control | Always authorize, not just authenticate |
| A02 | Cryptographic Failures | TLS everywhere, bcrypt passwords, no MD5/SHA1 |
| A03 | Injection | Parameterized queries, ORM, input validation |
| A04 | Insecure Design | Threat model, rate limiting, abuse cases |
| A05 | Security Misconfiguration | Disable defaults, review headers |
| A06 | Vulnerable Components | `npm audit`, `pnpm audit`, Dependabot |
| A07 | Auth Failures | MFA, account lockout, secure sessions |
| A08 | Integrity Failures | Verify build artifacts, signed commits |
| A09 | Logging Failures | Log auth events, anomaly detection |
| A10 | SSRF | Validate URLs, block internal IPs |

## Input Validation

```typescript
// ALWAYS validate at every system boundary using Zod or class-validator

// NestJS — enable globally
app.useGlobalPipes(
  new ValidationPipe({
    whitelist:            true,    // strip unknown properties
    forbidNonWhitelisted: true,    // throw on unknown props
    transform:            true,    // auto-coerce types
    transformOptions: {
      enableImplicitConversion: false,
    },
  })
)

// Zod at service boundaries
const CreateOrderSchema = z.object({
  userId:   z.string().uuid(),
  items:    z.array(z.object({
    productId: z.string().uuid(),
    quantity:  z.number().int().min(1).max(100),
  })).min(1).max(50),
  couponCode: z.string().max(20).optional(),
})

type CreateOrderInput = z.infer<typeof CreateOrderSchema>

// Parse — throws ZodError on invalid input
const input = CreateOrderSchema.parse(rawBody)
```

## SQL Injection Prevention

```typescript
// ALWAYS use parameterized queries / ORM — never string concatenate

// Bad — SQL injection possible
const result = await db.query(
  `SELECT * FROM users WHERE email = '${email}'`
)

// Good — TypeORM parameterized
const user = await this.repo.findOne({ where: { email } })

// Good — raw query with parameters
const users = await this.dataSource.query(
  'SELECT * FROM users WHERE email = $1 AND status = $2',
  [email, 'active']
)

// Good — QueryBuilder with parameters
const users = await this.repo
  .createQueryBuilder('user')
  .where('user.email = :email', { email })
  .andWhere('user.status = :status', { status: 'active' })
  .getMany()
```

## XSS Prevention

```typescript
// Sanitize HTML when you MUST accept user HTML (e.g., rich text editors)
// Install: npm i dompurify jsdom; npm i -D @types/dompurify

import createDOMPurify from 'dompurify'
import { JSDOM } from 'jsdom'

const { window } = new JSDOM('')
const DOMPurify  = createDOMPurify(window as unknown as Window)

const allowedTags  = ['b', 'i', 'em', 'strong', 'a', 'p', 'ul', 'ol', 'li']
const allowedAttrs = { a: ['href', 'title', 'target'] }

export function sanitizeHtml(dirty: string): string {
  return DOMPurify.sanitize(dirty, {
    ALLOWED_TAGS:  allowedTags,
    ALLOWED_ATTR:  allowedAttrs,
  })
}

// In React: NEVER use dangerouslySetInnerHTML with unsanitized content
// Good:
<div dangerouslySetInnerHTML={{ __html: sanitizeHtml(userContent) }} />
// Bad:
<div dangerouslySetInnerHTML={{ __html: userContent }} />
```

## Security Headers

```typescript
// main.ts — use helmet
import helmet from 'helmet'

app.use(helmet({
  contentSecurityPolicy: {
    directives: {
      defaultSrc: ["'self'"],
      scriptSrc:  ["'self'", "'nonce-{NONCE}'"],
      styleSrc:   ["'self'", "'unsafe-inline'"],
      imgSrc:     ["'self'", 'data:', 'https:'],
      connectSrc: ["'self'", 'https://api.example.com'],
    },
  },
  hsts: {
    maxAge: 31536000,
    includeSubDomains: true,
    preload: true,
  },
}))

// CORS — explicit origins only
app.enableCors({
  origin:      process.env.CORS_ORIGINS?.split(',') ?? [],
  methods:     ['GET', 'POST', 'PATCH', 'PUT', 'DELETE', 'OPTIONS'],
  credentials: true,
  maxAge:      86400,
})
```

## Rate Limiting

```typescript
// Per-endpoint limits for sensitive operations
@Controller('auth')
export class AuthController {
  // Very strict: login attempts
  @Post('login')
  @Throttle({ default: { ttl: 900_000, limit: 5 } })   // 5 per 15 min
  login() {}

  // Strict: password reset
  @Post('forgot-password')
  @Throttle({ default: { ttl: 3600_000, limit: 3 } })  // 3 per hour
  forgotPassword() {}

  // Standard: general API
  @Get('profile')
  @Throttle({ default: { ttl: 60_000, limit: 60 } })   // 60 per min
  profile() {}
}
```

## CSRF Protection

```typescript
// Use csurf for session-based apps
// For JWT-based SPAs: double-submit cookie pattern is unnecessary
// because CORS already protects — just validate the Origin header

// main.ts — validate origin on state-changing requests
app.use((req, res, next) => {
  if (['POST', 'PATCH', 'PUT', 'DELETE'].includes(req.method)) {
    const origin = req.headers.origin
    const allowed = process.env.CORS_ORIGINS?.split(',') ?? []
    if (origin && !allowed.includes(origin)) {
      return res.status(403).json({ error: 'Forbidden' })
    }
  }
  next()
})
```

## Secrets Management

```typescript
// Validate all required secrets at startup — fail fast
function validateSecrets() {
  const required = [
    'DATABASE_URL',
    'JWT_SECRET',
    'JWT_REFRESH_SECRET',
  ]

  const missing = required.filter(key => !process.env[key])
  if (missing.length > 0) {
    throw new Error(`Missing required environment variables: ${missing.join(', ')}`)
  }

  if ((process.env.JWT_SECRET?.length ?? 0) < 32) {
    throw new Error('JWT_SECRET must be at least 32 characters')
  }
}

// Call before app.listen
validateSecrets()
```

## File Upload Security

```typescript
// Validate MIME type, extension, and file size
import multer from 'multer'
import path from 'path'
import crypto from 'crypto'

const ALLOWED_MIMES = new Set(['image/jpeg', 'image/png', 'image/webp', 'application/pdf'])
const MAX_FILE_SIZE = 5 * 1024 * 1024  // 5MB

const upload = multer({
  storage: multer.memoryStorage(),
  limits: { fileSize: MAX_FILE_SIZE },
  fileFilter: (req, file, cb) => {
    if (!ALLOWED_MIMES.has(file.mimetype)) {
      return cb(new Error(`File type ${file.mimetype} not allowed`))
    }
    cb(null, true)
  },
})

// Store files with random names — never use original filename
async function saveUpload(buffer: Buffer, originalName: string): Promise<string> {
  const ext      = path.extname(originalName).toLowerCase()
  const safeName = `${crypto.randomUUID()}${ext}`
  // Upload to S3/R2, not to local filesystem
  return s3.upload(buffer, safeName)
}
```

## Dependency Security

```bash
# Run on every CI build
pnpm audit --audit-level=high

# Fix automatically (carefully — may break things)
pnpm audit --fix

# Check for known vulnerabilities
npx better-npm-audit audit

# Setup Dependabot
# .github/dependabot.yml
```

```yaml
# .github/dependabot.yml
version: 2
updates:
  - package-ecosystem: npm
    directory: /
    schedule: { interval: weekly }
    ignore:
      - dependency-name: "*"
        update-types: ["version-update:semver-patch"]
    open-pull-requests-limit: 10
```

## Audit Logging

```typescript
// Log all security-relevant events
@Injectable()
export class AuditService {
  private readonly logger = new Logger('AUDIT')

  logAuth(event: 'login' | 'logout' | 'login_failed' | 'token_refresh', data: {
    userId?: string
    email?: string
    ip: string
    userAgent?: string
  }) {
    this.logger.log({
      event,
      ...data,
      email: data.email ? this.maskEmail(data.email) : undefined,
      timestamp: new Date().toISOString(),
    })
  }

  private maskEmail(email: string): string {
    const [local, domain] = email.split('@')
    return `${local[0]}***@${domain}`
  }
}
```

## Pre-Deploy Security Checklist

```
□ No secrets in source code (run: git log -p | grep -i "password\|secret\|api_key")
□ npm audit passes (no high/critical vulnerabilities)
□ All endpoints require authentication (check controller decorators)
□ Admin endpoints have role checks
□ Rate limiting on auth endpoints
□ CORS origins are explicit (no wildcards)
□ Helmet security headers enabled
□ Input validation with whitelist mode
□ Parameterized queries only (no string concatenation with user input)
□ File uploads validate MIME type and size
□ Error messages don't leak stack traces to client
□ Logging masks PII
□ HTTPS enforced (no HTTP in production)
```

## Forbidden Patterns

- Never log passwords, full tokens, or unmasked emails
- Never use MD5 or SHA1 for password hashing — use bcrypt with cost >= 12
- Never trust `Content-Type` header alone for file type validation — check magic bytes
- Never store secrets in env vars committed to git (`.env` should be in `.gitignore`)
- Never disable HTTPS in production
- Never use `eval()` or `new Function()` with user input
- Never reflect user input directly into error messages without sanitizing

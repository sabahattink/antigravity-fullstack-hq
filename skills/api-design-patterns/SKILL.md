---
name: api-design-patterns
description: REST API design, versioning, error responses, pagination, OpenAPI conventions. Use when designing new API endpoints, reviewing API contracts, or setting up Swagger/OpenAPI documentation.
---

# API Design Patterns

## URL Structure

```
# Resource naming: plural nouns, lowercase, hyphenated
GET    /api/v1/users                    # list
POST   /api/v1/users                    # create
GET    /api/v1/users/:id                # read one
PATCH  /api/v1/users/:id                # partial update
PUT    /api/v1/users/:id                # full replace
DELETE /api/v1/users/:id                # delete

# Nested resources (max 2 levels)
GET    /api/v1/users/:userId/orders
POST   /api/v1/users/:userId/orders
GET    /api/v1/users/:userId/orders/:orderId

# Actions that don't fit CRUD — use verbs as sub-resources
POST   /api/v1/users/:id/activate
POST   /api/v1/orders/:id/cancel
POST   /api/v1/auth/refresh
POST   /api/v1/auth/logout
```

## Standard Response Envelope

```typescript
// types/api-response.ts
export interface ApiResponse<T> {
  success: boolean
  data:    T | null
  error:   ApiError | null
  meta?:   ResponseMeta
}

export interface ApiError {
  code:    string   // machine-readable, stable: 'USER_NOT_FOUND'
  message: string   // human-readable
  details?: Record<string, string[]>  // field validation errors
}

export interface ResponseMeta {
  total:  number
  page:   number
  limit:  number
  pages:  number
}

// Success
{
  "success": true,
  "data": { "id": 1, "name": "Jane" },
  "error": null
}

// Error
{
  "success": false,
  "data": null,
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "Invalid request body",
    "details": {
      "email": ["Must be a valid email address"],
      "password": ["Must be at least 8 characters"]
    }
  }
}

// Paginated list
{
  "success": true,
  "data": [...],
  "error": null,
  "meta": { "total": 243, "page": 2, "limit": 20, "pages": 13 }
}
```

## NestJS Response Interceptor

```typescript
// common/interceptors/response-transform.interceptor.ts
import {
  Injectable, NestInterceptor, ExecutionContext, CallHandler,
} from '@nestjs/common'
import { Observable, map } from 'rxjs'
import { ApiResponse } from '../../types/api-response'

@Injectable()
export class ResponseTransformInterceptor<T> implements NestInterceptor<T, ApiResponse<T>> {
  intercept(context: ExecutionContext, next: CallHandler<T>): Observable<ApiResponse<T>> {
    return next.handle().pipe(
      map(data => ({
        success: true,
        data,
        error: null,
      }))
    )
  }
}

// Register globally in main.ts
app.useGlobalInterceptors(new ResponseTransformInterceptor())
```

## HTTP Status Codes

```typescript
// Use these — don't improvise
const STATUS_CODES = {
  // 2xx Success
  200: 'OK',                 // GET, PATCH, PUT — returned with data
  201: 'Created',            // POST — resource created
  204: 'No Content',         // DELETE, POST actions with no body

  // 3xx Redirect
  301: 'Moved Permanently',  // URL changed
  304: 'Not Modified',       // conditional GET, cache valid

  // 4xx Client Error
  400: 'Bad Request',        // malformed JSON, invalid params
  401: 'Unauthorized',       // not authenticated
  403: 'Forbidden',          // authenticated but not authorized
  404: 'Not Found',          // resource doesn't exist
  409: 'Conflict',           // duplicate email, version conflict
  422: 'Unprocessable',      // semantically invalid (business rule)
  429: 'Too Many Requests',  // rate limited

  // 5xx Server Error
  500: 'Internal Server Error', // unexpected exception
  502: 'Bad Gateway',           // upstream service error
  503: 'Service Unavailable',   // overloaded / maintenance
}
```

## Pagination

```typescript
// Query params: consistent naming
// GET /users?page=2&limit=20&sort=createdAt&order=desc

export class PaginationQueryDto {
  @IsOptional() @Type(() => Number) @IsInt() @Min(1)
  page: number = 1

  @IsOptional() @Type(() => Number) @IsInt() @Min(1) @Max(100)
  limit: number = 20

  @IsOptional() @IsString()
  sort?: string = 'createdAt'

  @IsOptional() @IsIn(['asc', 'desc'])
  order?: 'asc' | 'desc' = 'desc'

  @IsOptional() @IsString() @MaxLength(200)
  search?: string
}

// Response with cursor-based pagination (for feeds / infinite scroll)
export interface CursorPage<T> {
  data:       T[]
  nextCursor: string | null  // opaque, base64 encoded
  hasMore:    boolean
}

// Encode/decode cursor
function encodeCursor(payload: object): string {
  return Buffer.from(JSON.stringify(payload)).toString('base64url')
}
function decodeCursor(cursor: string): unknown {
  return JSON.parse(Buffer.from(cursor, 'base64url').toString())
}
```

## API Versioning

```typescript
// main.ts — URI versioning (recommended for breaking changes)
import { VersioningType } from '@nestjs/common'

app.enableVersioning({ type: VersioningType.URI })

// Controller
@Controller({ path: 'users', version: '1' })
export class UsersV1Controller { /* ... */ }

@Controller({ path: 'users', version: '2' })
export class UsersV2Controller { /* ... */ }

// Result: GET /v1/users, GET /v2/users
```

## OpenAPI / Swagger Setup

```typescript
// main.ts
import { SwaggerModule, DocumentBuilder } from '@nestjs/swagger'

async function bootstrap() {
  const app = await NestFactory.create(AppModule)

  const config = new DocumentBuilder()
    .setTitle('Antigravity API')
    .setDescription('Backend API documentation')
    .setVersion('1.0')
    .addBearerAuth(
      { type: 'http', scheme: 'bearer', bearerFormat: 'JWT' },
      'JWT'
    )
    .addServer('http://localhost:3000', 'Development')
    .addServer('https://api.example.com', 'Production')
    .build()

  const document = SwaggerModule.createDocument(app, config)
  SwaggerModule.setup('api/docs', app, document, {
    swaggerOptions: { persistAuthorization: true },
  })

  await app.listen(3000)
}
```

```typescript
// Annotate DTOs and controllers
import { ApiProperty, ApiPropertyOptional, ApiOperation, ApiResponse } from '@nestjs/swagger'

export class CreateUserDto {
  @ApiProperty({ example: 'jane@example.com', description: 'Must be unique' })
  email: string

  @ApiPropertyOptional({ example: 'admin', enum: UserRole })
  role?: UserRole
}

@ApiTags('users')
@ApiBearerAuth('JWT')
@Controller('users')
export class UsersController {
  @Post()
  @ApiOperation({ summary: 'Create a new user' })
  @ApiResponse({ status: 201, description: 'User created', type: UserResponseDto })
  @ApiResponse({ status: 409, description: 'Email already in use' })
  create(@Body() dto: CreateUserDto) { /* ... */ }
}
```

## Error Codes Convention

```typescript
// Use namespaced, SCREAMING_SNAKE_CASE error codes
export const ErrorCodes = {
  // Auth
  AUTH_INVALID_CREDENTIALS: 'AUTH_INVALID_CREDENTIALS',
  AUTH_TOKEN_EXPIRED:       'AUTH_TOKEN_EXPIRED',
  AUTH_TOKEN_INVALID:       'AUTH_TOKEN_INVALID',
  AUTH_INSUFFICIENT_SCOPE:  'AUTH_INSUFFICIENT_SCOPE',

  // Users
  USER_NOT_FOUND:      'USER_NOT_FOUND',
  USER_EMAIL_TAKEN:    'USER_EMAIL_TAKEN',
  USER_DEACTIVATED:    'USER_DEACTIVATED',

  // Validation
  VALIDATION_ERROR:    'VALIDATION_ERROR',
  INVALID_UUID:        'INVALID_UUID',

  // Server
  INTERNAL_ERROR:      'INTERNAL_ERROR',
  SERVICE_UNAVAILABLE: 'SERVICE_UNAVAILABLE',
} as const
```

## Rate Limiting

```typescript
// Install: npm i @nestjs/throttler

// app.module.ts
ThrottlerModule.forRootAsync({
  inject: [ConfigService],
  useFactory: (config: ConfigService) => ({
    throttlers: [
      { name: 'short', ttl:  1_000, limit: 3  },   // 3 req/sec
      { name: 'medium', ttl: 10_000, limit: 20 },   // 20 req/10s
      { name: 'long', ttl:  60_000, limit: 100 },   // 100 req/min
    ],
  }),
})

// Apply at controller or route level
@UseGuards(ThrottlerGuard)
@Throttle({ default: { ttl: 60_000, limit: 5 } })  // 5/min for this endpoint
@Post('auth/login')
login(@Body() dto: LoginDto) { /* ... */ }
```

## Request ID Tracing

```typescript
// middleware/request-id.middleware.ts
import { Injectable, NestMiddleware } from '@nestjs/common'
import { Request, Response, NextFunction } from 'express'
import { randomUUID } from 'crypto'

@Injectable()
export class RequestIdMiddleware implements NestMiddleware {
  use(req: Request, res: Response, next: NextFunction) {
    const requestId = (req.headers['x-request-id'] as string) ?? randomUUID()
    req.headers['x-request-id'] = requestId
    res.setHeader('x-request-id', requestId)
    next()
  }
}
```

## Filtering & Sorting

```typescript
// GET /products?filter[category]=electronics&filter[price][gte]=100&sort=-price,name
// (minus prefix = descending)

export class ProductFilterDto {
  @IsOptional() @IsString()
  'filter[category]'?: string

  @IsOptional() @Type(() => Number) @Min(0)
  'filter[price][gte]'?: number

  @IsOptional() @Type(() => Number) @Min(0)
  'filter[price][lte]'?: number

  @IsOptional() @IsString()
  sort?: string  // comma-separated, minus = desc

  get sortFields(): Array<{ field: string; order: 'ASC' | 'DESC' }> {
    return (this.sort ?? 'createdAt').split(',').map(s => ({
      field: s.replace(/^-/, ''),
      order: s.startsWith('-') ? 'DESC' : 'ASC',
    }))
  }
}
```

## Forbidden Patterns

- Never use verbs in resource URLs (use `/orders/:id/cancel`, not `/cancelOrder`)
- Never return different shapes for success vs error — always use the envelope
- Never use `200 OK` for errors — use the correct 4xx/5xx status
- Never expose database IDs as auto-increment integers in public APIs — use UUIDs
- Never put sensitive data (tokens, passwords, secrets) in query parameters — use headers or body
- Never break versioned API contracts without bumping the version
- Never skip pagination for list endpoints — unbounded queries will OOM in production
- Never return `null` for missing fields — omit them or use a typed optional

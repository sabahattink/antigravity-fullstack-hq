---
name: backend-dev-guidelines
description: Backend architecture principles, layering, error handling, logging patterns for NestJS. Use when designing NestJS modules, writing service logic, structuring error handling, or setting up structured logging.
---

# Backend Development Guidelines

## NestJS Layered Architecture

```
src/
├── modules/
│   └── users/
│       ├── users.module.ts         # DI wiring
│       ├── users.controller.ts     # HTTP layer — parse, validate, delegate
│       ├── users.service.ts        # Business logic
│       ├── users.repository.ts     # Data access
│       ├── dto/
│       │   ├── create-user.dto.ts
│       │   └── update-user.dto.ts
│       ├── entities/
│       │   └── user.entity.ts
│       └── users.spec.ts
├── common/
│   ├── filters/                    # Global exception filters
│   ├── guards/                     # Auth/RBAC guards
│   ├── interceptors/               # Logging, transform
│   ├── decorators/                 # Custom decorators
│   └── pipes/                      # Validation pipes
└── config/
    └── configuration.ts
```

## Controller Layer

Controllers should be thin: validate inputs, call services, return responses.

```typescript
// users/users.controller.ts
import {
  Controller, Get, Post, Put, Delete,
  Body, Param, Query, ParseIntPipe,
  UseGuards, HttpCode, HttpStatus,
} from '@nestjs/common'
import { ApiTags, ApiOperation, ApiBearerAuth } from '@nestjs/swagger'
import { JwtAuthGuard } from '../common/guards/jwt-auth.guard'
import { CurrentUser } from '../common/decorators/current-user.decorator'
import { UsersService } from './users.service'
import { CreateUserDto } from './dto/create-user.dto'
import { UpdateUserDto } from './dto/update-user.dto'
import { PaginationDto } from '../common/dto/pagination.dto'

@ApiTags('users')
@ApiBearerAuth()
@UseGuards(JwtAuthGuard)
@Controller('users')
export class UsersController {
  constructor(private readonly usersService: UsersService) {}

  @Get()
  @ApiOperation({ summary: 'List users with pagination' })
  findAll(@Query() pagination: PaginationDto) {
    return this.usersService.findAll(pagination)
  }

  @Get(':id')
  findOne(@Param('id', ParseIntPipe) id: number) {
    return this.usersService.findOneOrFail(id)
  }

  @Post()
  @HttpCode(HttpStatus.CREATED)
  create(@Body() dto: CreateUserDto, @CurrentUser() actor: AuthUser) {
    return this.usersService.create(dto, actor)
  }

  @Put(':id')
  update(
    @Param('id', ParseIntPipe) id: number,
    @Body() dto: UpdateUserDto,
    @CurrentUser() actor: AuthUser,
  ) {
    return this.usersService.update(id, dto, actor)
  }

  @Delete(':id')
  @HttpCode(HttpStatus.NO_CONTENT)
  remove(@Param('id', ParseIntPipe) id: number) {
    return this.usersService.remove(id)
  }
}
```

## Service Layer

```typescript
// users/users.service.ts
import { Injectable, NotFoundException, ConflictException } from '@nestjs/common'
import { InjectRepository } from '@nestjs/typeorm'
import { UsersRepository } from './users.repository'
import { CreateUserDto } from './dto/create-user.dto'
import { PaginationDto } from '../common/dto/pagination.dto'
import { User } from './entities/user.entity'
import { hash } from 'bcrypt'

@Injectable()
export class UsersService {
  constructor(private readonly repo: UsersRepository) {}

  async findAll(pagination: PaginationDto) {
    return this.repo.findPaginated(pagination)
  }

  async findOneOrFail(id: number): Promise<User> {
    const user = await this.repo.findById(id)
    if (!user) {
      throw new NotFoundException(`User #${id} not found`)
    }
    return user
  }

  async create(dto: CreateUserDto, actor: AuthUser): Promise<User> {
    const existing = await this.repo.findByEmail(dto.email)
    if (existing) {
      throw new ConflictException('Email already registered')
    }

    const passwordHash = await hash(dto.password, 12)

    return this.repo.create({
      ...dto,
      passwordHash,
      createdById: actor.id,
    })
  }

  async update(id: number, dto: UpdateUserDto, actor: AuthUser): Promise<User> {
    const user = await this.findOneOrFail(id)
    return this.repo.save({ ...user, ...dto })
  }

  async remove(id: number): Promise<void> {
    const user = await this.findOneOrFail(id)
    await this.repo.softDelete(user.id)
  }
}
```

## Repository Layer

```typescript
// users/users.repository.ts
import { Injectable } from '@nestjs/common'
import { DataSource, Repository } from 'typeorm'
import { User } from './entities/user.entity'
import { PaginationDto } from '../common/dto/pagination.dto'

@Injectable()
export class UsersRepository extends Repository<User> {
  constructor(private dataSource: DataSource) {
    super(User, dataSource.createEntityManager())
  }

  async findById(id: number): Promise<User | null> {
    return this.findOne({ where: { id, deletedAt: undefined } })
  }

  async findByEmail(email: string): Promise<User | null> {
    return this.findOne({ where: { email: email.toLowerCase() } })
  }

  async findPaginated(dto: PaginationDto) {
    const [data, total] = await this.findAndCount({
      skip: (dto.page - 1) * dto.limit,
      take: dto.limit,
      order: { createdAt: 'DESC' },
      where: { deletedAt: undefined },
    })
    return {
      data,
      meta: { total, page: dto.page, limit: dto.limit, pages: Math.ceil(total / dto.limit) },
    }
  }
}
```

## DTOs with Validation

```typescript
// dto/create-user.dto.ts
import {
  IsEmail, IsString, MinLength, MaxLength,
  IsOptional, IsEnum, Matches,
} from 'class-validator'
import { Transform } from 'class-transformer'
import { ApiProperty } from '@nestjs/swagger'

export enum UserRole {
  ADMIN = 'admin',
  USER  = 'user',
}

export class CreateUserDto {
  @ApiProperty({ example: 'jane@example.com' })
  @IsEmail()
  @Transform(({ value }: { value: string }) => value.toLowerCase().trim())
  email: string

  @ApiProperty({ minLength: 8 })
  @IsString()
  @MinLength(8)
  @MaxLength(72) // bcrypt max
  @Matches(/^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)/, {
    message: 'Password must contain uppercase, lowercase, and a digit',
  })
  password: string

  @ApiProperty()
  @IsString()
  @MinLength(1)
  @MaxLength(100)
  @Transform(({ value }: { value: string }) => value.trim())
  name: string

  @ApiProperty({ enum: UserRole, required: false })
  @IsOptional()
  @IsEnum(UserRole)
  role?: UserRole = UserRole.USER
}
```

## Global Exception Filter

```typescript
// common/filters/http-exception.filter.ts
import {
  ExceptionFilter, Catch, ArgumentsHost,
  HttpException, HttpStatus, Logger,
} from '@nestjs/common'
import { Request, Response } from 'express'

@Catch()
export class AllExceptionsFilter implements ExceptionFilter {
  private readonly logger = new Logger(AllExceptionsFilter.name)

  catch(exception: unknown, host: ArgumentsHost) {
    const ctx      = host.switchToHttp()
    const response = ctx.getResponse<Response>()
    const request  = ctx.getRequest<Request>()

    const isHttp  = exception instanceof HttpException
    const status  = isHttp ? exception.getStatus() : HttpStatus.INTERNAL_SERVER_ERROR
    const message = isHttp
      ? exception.getResponse()
      : 'Internal server error'

    if (status >= 500) {
      this.logger.error({
        message:   'Unhandled exception',
        path:      request.url,
        method:    request.method,
        error:     exception instanceof Error ? exception.message : exception,
        stack:     exception instanceof Error ? exception.stack : undefined,
        requestId: request.headers['x-request-id'],
      })
    }

    response.status(status).json({
      success:   false,
      statusCode: status,
      timestamp:  new Date().toISOString(),
      path:       request.url,
      message,
    })
  }
}
```

## Structured Logging

```typescript
// config/logger.config.ts — using pino
import pino from 'pino'

export const logger = pino({
  level: process.env.LOG_LEVEL ?? 'info',
  transport: process.env.NODE_ENV !== 'production'
    ? { target: 'pino-pretty', options: { colorize: true } }
    : undefined,
  formatters: {
    level: (label) => ({ level: label }),
  },
  base: {
    service: process.env.SERVICE_NAME ?? 'api',
    env:     process.env.NODE_ENV,
  },
})

// Logging interceptor
import {
  Injectable, NestInterceptor, ExecutionContext,
  CallHandler, Logger,
} from '@nestjs/common'
import { Observable, tap } from 'rxjs'

@Injectable()
export class LoggingInterceptor implements NestInterceptor {
  private readonly logger = new Logger('HTTP')

  intercept(context: ExecutionContext, next: CallHandler): Observable<unknown> {
    const req   = context.switchToHttp().getRequest()
    const start = Date.now()

    return next.handle().pipe(
      tap({
        next: () => {
          const res = context.switchToHttp().getResponse()
          this.logger.log({
            method:    req.method,
            url:       req.url,
            status:    res.statusCode,
            duration:  `${Date.now() - start}ms`,
            requestId: req.headers['x-request-id'],
            userId:    req.user?.id,
          })
        },
        error: (err) => {
          this.logger.error({
            method:    req.method,
            url:       req.url,
            error:     err.message,
            duration:  `${Date.now() - start}ms`,
            requestId: req.headers['x-request-id'],
          })
        },
      })
    )
  }
}
```

## Configuration Management

```typescript
// config/configuration.ts
import { z } from 'zod'

const envSchema = z.object({
  NODE_ENV:        z.enum(['development', 'test', 'production']).default('development'),
  PORT:            z.coerce.number().default(3000),
  DATABASE_URL:    z.string().url(),
  JWT_SECRET:      z.string().min(32),
  JWT_EXPIRES_IN:  z.string().default('15m'),
  REDIS_URL:       z.string().url().optional(),
  CORS_ORIGINS:    z.string().transform(s => s.split(',')),
})

export type Env = z.infer<typeof envSchema>

export function validateEnv(env: Record<string, unknown>): Env {
  const result = envSchema.safeParse(env)
  if (!result.success) {
    throw new Error(`Invalid environment variables:\n${result.error.toString()}`)
  }
  return result.data
}

// app.module.ts
import { ConfigModule } from '@nestjs/config'

@Module({
  imports: [
    ConfigModule.forRoot({
      isGlobal: true,
      validate: validateEnv,
    }),
  ],
})
export class AppModule {}
```

## Health Checks

```typescript
// health/health.controller.ts
import { Controller, Get } from '@nestjs/common'
import {
  HealthCheckService, HttpHealthIndicator,
  TypeOrmHealthIndicator, HealthCheck,
} from '@nestjs/terminus'

@Controller('health')
export class HealthController {
  constructor(
    private health: HealthCheckService,
    private db:     TypeOrmHealthIndicator,
    private http:   HttpHealthIndicator,
  ) {}

  @Get()
  @HealthCheck()
  check() {
    return this.health.check([
      () => this.db.pingCheck('database'),
    ])
  }

  @Get('liveness')
  liveness() {
    return { status: 'ok', uptime: process.uptime() }
  }
}
```

## Pagination DTO

```typescript
// common/dto/pagination.dto.ts
import { IsInt, Min, Max, IsOptional } from 'class-validator'
import { Type } from 'class-transformer'
import { ApiPropertyOptional } from '@nestjs/swagger'

export class PaginationDto {
  @ApiPropertyOptional({ default: 1 })
  @IsOptional()
  @Type(() => Number)
  @IsInt()
  @Min(1)
  page: number = 1

  @ApiPropertyOptional({ default: 20, maximum: 100 })
  @IsOptional()
  @Type(() => Number)
  @IsInt()
  @Min(1)
  @Max(100)
  limit: number = 20
}
```

## Forbidden Patterns

- Never put business logic in controllers — controllers only parse and delegate
- Never query the database from a controller — always through service → repository
- Never use `any` type — use proper DTOs and entities
- Never swallow exceptions with empty catch blocks
- Never log passwords, tokens, or PII (email in logs must be masked)
- Never use synchronous bcrypt (`hashSync`) — always async to avoid blocking the event loop
- Never skip input validation with `ValidationPipe` — register it globally in `main.ts`
- Never return raw database entities — use response DTOs or `ClassSerializerInterceptor`
- Never put secrets in `.env.example` values — use placeholder descriptions instead

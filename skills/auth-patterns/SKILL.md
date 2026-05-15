---
name: auth-patterns
description: JWT access/refresh tokens, Passport.js strategies, session management, OAuth. Use when implementing authentication, authorization, or setting up OAuth providers in a NestJS + Next.js app.
---

# Auth Patterns

## JWT Access + Refresh Token Flow

```
Login
  → API issues access_token (15min) + refresh_token (7d)
  → Frontend stores access_token in memory, refresh_token in httpOnly cookie

Request
  → Attach Authorization: Bearer <access_token>
  → If 401 → POST /auth/refresh with httpOnly cookie
  → If refresh valid → new access_token
  → If refresh expired → redirect to login
```

## NestJS Auth Module

```typescript
// auth/auth.module.ts
@Module({
  imports: [
    PassportModule,
    JwtModule.registerAsync({
      inject: [ConfigService],
      useFactory: (config: ConfigService) => ({
        secret:      config.get('JWT_SECRET'),
        signOptions: { expiresIn: '15m' },
      }),
    }),
    UsersModule,
  ],
  controllers: [AuthController],
  providers: [
    AuthService,
    JwtStrategy,
    LocalStrategy,
    JwtRefreshStrategy,
  ],
  exports: [AuthService],
})
export class AuthModule {}
```

## Strategies

```typescript
// auth/strategies/local.strategy.ts
import { Strategy } from 'passport-local'
import { PassportStrategy } from '@nestjs/passport'

@Injectable()
export class LocalStrategy extends PassportStrategy(Strategy) {
  constructor(private auth: AuthService) {
    super({ usernameField: 'email' })
  }

  async validate(email: string, password: string): Promise<AuthUser> {
    const user = await this.auth.validateCredentials(email, password)
    if (!user) throw new UnauthorizedException('Invalid email or password')
    return user
  }
}

// auth/strategies/jwt.strategy.ts
import { ExtractJwt, Strategy } from 'passport-jwt'

@Injectable()
export class JwtStrategy extends PassportStrategy(Strategy, 'jwt') {
  constructor(config: ConfigService) {
    super({
      jwtFromRequest:   ExtractJwt.fromAuthHeaderAsBearerToken(),
      ignoreExpiration: false,
      secretOrKey:      config.get<string>('JWT_SECRET'),
    })
  }

  async validate(payload: JwtPayload): Promise<AuthUser> {
    return { id: payload.sub, email: payload.email, role: payload.role }
  }
}

// auth/strategies/jwt-refresh.strategy.ts
@Injectable()
export class JwtRefreshStrategy extends PassportStrategy(Strategy, 'jwt-refresh') {
  constructor(config: ConfigService, private auth: AuthService) {
    super({
      jwtFromRequest:   ExtractJwt.fromExtractors([
        (req: Request) => req?.cookies?.['refresh_token'],
      ]),
      ignoreExpiration: false,
      secretOrKey:      config.get<string>('JWT_REFRESH_SECRET'),
      passReqToCallback: true,
    })
  }

  async validate(req: Request, payload: JwtPayload): Promise<AuthUser> {
    const refreshToken = req.cookies['refresh_token']
    return this.auth.validateRefreshToken(payload.sub, refreshToken)
  }
}
```

## Auth Service

```typescript
// auth/auth.service.ts
@Injectable()
export class AuthService {
  constructor(
    private usersService: UsersService,
    private jwtService:   JwtService,
    private config:       ConfigService,
  ) {}

  async validateCredentials(email: string, password: string): Promise<AuthUser | null> {
    const user = await this.usersService.findByEmail(email)
    if (!user) return null

    const valid = await compare(password, user.passwordHash)
    return valid ? { id: user.id, email: user.email, role: user.role } : null
  }

  async login(user: AuthUser): Promise<TokenPair> {
    const payload: JwtPayload = { sub: user.id, email: user.email, role: user.role }

    const [accessToken, refreshToken] = await Promise.all([
      this.jwtService.signAsync(payload, { expiresIn: '15m' }),
      this.jwtService.signAsync(payload, {
        secret:    this.config.get('JWT_REFRESH_SECRET'),
        expiresIn: '7d',
      }),
    ])

    // Store hashed refresh token
    const hash = await bcrypt.hash(refreshToken, 10)
    await this.usersService.saveRefreshToken(user.id, hash)

    return { accessToken, refreshToken }
  }

  async validateRefreshToken(userId: string, token: string): Promise<AuthUser> {
    const user = await this.usersService.findById(userId)
    if (!user?.refreshTokenHash) throw new UnauthorizedException()

    const valid = await compare(token, user.refreshTokenHash)
    if (!valid) throw new UnauthorizedException()

    return { id: user.id, email: user.email, role: user.role }
  }

  async logout(userId: string): Promise<void> {
    await this.usersService.clearRefreshToken(userId)
  }
}
```

## Auth Controller

```typescript
// auth/auth.controller.ts
@Controller('auth')
export class AuthController {
  constructor(private auth: AuthService) {}

  @Post('login')
  @UseGuards(LocalAuthGuard)
  @HttpCode(HttpStatus.OK)
  async login(
    @CurrentUser() user: AuthUser,
    @Res({ passthrough: true }) res: Response,
  ) {
    const { accessToken, refreshToken } = await this.auth.login(user)

    // Set refresh token as httpOnly cookie
    res.cookie('refresh_token', refreshToken, {
      httpOnly:  true,
      secure:    process.env.NODE_ENV === 'production',
      sameSite:  'strict',
      maxAge:    7 * 24 * 60 * 60 * 1000,  // 7 days in ms
      path:      '/api/auth',               // restrict cookie scope
    })

    return { accessToken, expiresIn: 900 }
  }

  @Post('refresh')
  @UseGuards(JwtRefreshGuard)
  @HttpCode(HttpStatus.OK)
  async refresh(
    @CurrentUser() user: AuthUser,
    @Res({ passthrough: true }) res: Response,
  ) {
    const { accessToken, refreshToken } = await this.auth.login(user)

    res.cookie('refresh_token', refreshToken, {
      httpOnly:  true,
      secure:    process.env.NODE_ENV === 'production',
      sameSite:  'strict',
      maxAge:    7 * 24 * 60 * 60 * 1000,
      path:      '/api/auth',
    })

    return { accessToken, expiresIn: 900 }
  }

  @Post('logout')
  @UseGuards(JwtAuthGuard)
  @HttpCode(HttpStatus.NO_CONTENT)
  async logout(
    @CurrentUser() user: AuthUser,
    @Res({ passthrough: true }) res: Response,
  ) {
    await this.auth.logout(user.id)
    res.clearCookie('refresh_token', { path: '/api/auth' })
  }
}
```

## Guards

```typescript
// common/guards/jwt-auth.guard.ts
@Injectable()
export class JwtAuthGuard extends AuthGuard('jwt') {
  handleRequest<TUser = AuthUser>(err: Error, user: TUser): TUser {
    if (err || !user) {
      throw err ?? new UnauthorizedException('Token required')
    }
    return user
  }
}

// common/guards/roles.guard.ts
import { Reflector } from '@nestjs/core'

@Injectable()
export class RolesGuard implements CanActivate {
  constructor(private reflector: Reflector) {}

  canActivate(context: ExecutionContext): boolean {
    const required = this.reflector.getAllAndOverride<UserRole[]>(ROLES_KEY, [
      context.getHandler(),
      context.getClass(),
    ])
    if (!required || required.length === 0) return true

    const { user }: { user: AuthUser } = context.switchToHttp().getRequest()
    return required.includes(user.role)
  }
}

// common/decorators/roles.decorator.ts
export const ROLES_KEY = 'roles'
export const Roles = (...roles: UserRole[]) => SetMetadata(ROLES_KEY, roles)

// Usage
@Get('admin-only')
@UseGuards(JwtAuthGuard, RolesGuard)
@Roles(UserRole.ADMIN)
adminOnly() { /* ... */ }
```

## Next.js Auth Client

```typescript
// lib/auth/token-manager.ts
let accessToken: string | null = null

export function setAccessToken(token: string) {
  accessToken = token
}

export function getAccessToken(): string | null {
  return accessToken
}

export function clearAccessToken() {
  accessToken = null
}

// lib/auth/api-client.ts
import axios from 'axios'

const apiClient = axios.create({ baseURL: process.env.NEXT_PUBLIC_API_URL })

// Attach access token
apiClient.interceptors.request.use(config => {
  const token = getAccessToken()
  if (token) config.headers.Authorization = `Bearer ${token}`
  return config
})

// Auto-refresh on 401
let isRefreshing = false
let queue: Array<(token: string) => void> = []

apiClient.interceptors.response.use(
  res => res,
  async error => {
    const original = error.config

    if (error.response?.status === 401 && !original._retry) {
      if (isRefreshing) {
        return new Promise(resolve => {
          queue.push(token => {
            original.headers.Authorization = `Bearer ${token}`
            resolve(apiClient(original))
          })
        })
      }

      original._retry  = true
      isRefreshing      = true

      try {
        const { data } = await axios.post(
          `${process.env.NEXT_PUBLIC_API_URL}/api/auth/refresh`,
          {},
          { withCredentials: true }
        )
        setAccessToken(data.accessToken)
        queue.forEach(cb => cb(data.accessToken))
        queue = []
        original.headers.Authorization = `Bearer ${data.accessToken}`
        return apiClient(original)
      } catch {
        clearAccessToken()
        window.location.href = '/login'
        return Promise.reject(error)
      } finally {
        isRefreshing = false
      }
    }

    return Promise.reject(error)
  }
)
```

## Forbidden Patterns

- Never store access tokens in localStorage — XSS can steal them
- Never store refresh tokens in localStorage — use httpOnly cookies
- Never use weak JWT secrets — minimum 32 random characters
- Never skip token expiry — always set `expiresIn`
- Never put sensitive user data in JWT payload — it's base64 encoded, not encrypted
- Never use the same secret for access and refresh tokens
- Never skip hashing stored refresh tokens — treat them like passwords
- Never allow CORS from `*` on auth endpoints

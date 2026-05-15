---
name: software-architecture
description: System design patterns, Clean Architecture, SOLID principles, domain modeling. Use when making architectural decisions, designing new modules, refactoring a tangled codebase, or reviewing system design.
---

# Software Architecture

## Clean Architecture Layers

```
┌─────────────────────────────────────────────┐
│              Frameworks & Drivers           │  ← NestJS, TypeORM, Express
├─────────────────────────────────────────────┤
│           Interface Adapters                │  ← Controllers, Repositories, Presenters
├─────────────────────────────────────────────┤
│            Application Layer                │  ← Use Cases, Application Services
├─────────────────────────────────────────────┤
│              Domain Layer                   │  ← Entities, Value Objects, Domain Services
└─────────────────────────────────────────────┘

Dependency Rule: outer layers depend on inner layers — NEVER the reverse.
```

## Domain Layer

### Entities
```typescript
// domain/user/user.entity.ts
// Entities contain identity and business rules. No framework dependencies.

export class User {
  private constructor(
    public readonly id: UserId,
    public readonly email: Email,
    private _name: string,
    private _role: UserRole,
    public readonly createdAt: Date,
  ) {}

  static create(props: {
    id: UserId
    email: Email
    name: string
    role?: UserRole
  }): User {
    if (!props.name.trim()) {
      throw new DomainError('Name cannot be empty')
    }
    return new User(
      props.id,
      props.email,
      props.name.trim(),
      props.role ?? UserRole.USER,
      new Date(),
    )
  }

  get name(): string { return this._name }
  get role(): UserRole { return this._role }

  rename(newName: string): User {
    if (!newName.trim()) throw new DomainError('Name cannot be empty')
    // Return new instance — immutability
    return new User(this.id, this.email, newName.trim(), this._role, this.createdAt)
  }

  promote(to: UserRole, by: User): User {
    if (by.role !== UserRole.ADMIN) {
      throw new DomainError('Only admins can promote users')
    }
    return new User(this.id, this.email, this._name, to, this.createdAt)
  }
}
```

### Value Objects
```typescript
// domain/shared/value-objects/email.vo.ts
export class Email {
  private constructor(public readonly value: string) {}

  static create(raw: string): Email {
    const normalized = raw.toLowerCase().trim()
    if (!/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(normalized)) {
      throw new DomainError(`Invalid email: ${raw}`)
    }
    return new Email(normalized)
  }

  equals(other: Email): boolean {
    return this.value === other.value
  }

  toString(): string {
    return this.value
  }
}

// domain/shared/value-objects/money.vo.ts
export class Money {
  private constructor(
    public readonly amount: number,  // in cents
    public readonly currency: string,
  ) {}

  static of(amount: number, currency: string): Money {
    if (amount < 0) throw new DomainError('Amount cannot be negative')
    if (!['USD', 'EUR', 'GBP', 'TRY'].includes(currency)) {
      throw new DomainError(`Unsupported currency: ${currency}`)
    }
    return new Money(Math.round(amount), currency)
  }

  add(other: Money): Money {
    if (this.currency !== other.currency) {
      throw new DomainError('Cannot add different currencies')
    }
    return Money.of(this.amount + other.amount, this.currency)
  }

  format(): string {
    return new Intl.NumberFormat('en-US', {
      style: 'currency',
      currency: this.currency,
    }).format(this.amount / 100)
  }
}
```

### Domain Events
```typescript
// domain/shared/domain-event.ts
export abstract class DomainEvent {
  public readonly occurredAt: Date
  public readonly eventId: string

  constructor(
    public readonly aggregateId: string,
    public readonly eventType: string,
  ) {
    this.occurredAt = new Date()
    this.eventId    = crypto.randomUUID()
  }
}

// domain/user/events/user-created.event.ts
export class UserCreatedEvent extends DomainEvent {
  constructor(
    public readonly userId: string,
    public readonly email: string,
    public readonly name: string,
  ) {
    super(userId, 'user.created')
  }
}
```

## Application Layer

### Use Cases (Command/Query pattern)
```typescript
// application/users/commands/create-user/create-user.command.ts
export class CreateUserCommand {
  constructor(
    public readonly email: string,
    public readonly password: string,
    public readonly name: string,
    public readonly actorId: string,
  ) {}
}

// application/users/commands/create-user/create-user.handler.ts
import { CommandHandler, ICommandHandler, EventBus } from '@nestjs/cqrs'

@CommandHandler(CreateUserCommand)
export class CreateUserHandler implements ICommandHandler<CreateUserCommand> {
  constructor(
    private readonly userRepo:     IUserRepository,
    private readonly hasher:       IPasswordHasher,
    private readonly eventBus:     EventBus,
  ) {}

  async execute(cmd: CreateUserCommand): Promise<UserId> {
    const email = Email.create(cmd.email)

    const exists = await this.userRepo.existsByEmail(email)
    if (exists) throw new ConflictException('Email already in use')

    const passwordHash = await this.hasher.hash(cmd.password)
    const userId       = UserId.generate()

    const user = User.create({
      id:    userId,
      email,
      name:  cmd.name,
      passwordHash,
    })

    await this.userRepo.save(user)
    this.eventBus.publish(new UserCreatedEvent(userId.value, email.value, cmd.name))

    return userId
  }
}
```

## Repository Pattern (Interface in Domain)

```typescript
// domain/user/user.repository.interface.ts
export interface IUserRepository {
  findById(id: UserId): Promise<User | null>
  findByEmail(email: Email): Promise<User | null>
  existsByEmail(email: Email): Promise<boolean>
  save(user: User): Promise<void>
  delete(id: UserId): Promise<void>
}

// infrastructure/persistence/typeorm/user.typeorm-repository.ts
@Injectable()
export class UserTypeOrmRepository implements IUserRepository {
  constructor(
    @InjectRepository(UserOrmEntity)
    private readonly ormRepo: Repository<UserOrmEntity>,
    private readonly mapper:  UserMapper,
  ) {}

  async findById(id: UserId): Promise<User | null> {
    const row = await this.ormRepo.findOne({ where: { id: id.value } })
    return row ? this.mapper.toDomain(row) : null
  }

  async save(user: User): Promise<void> {
    const row = this.mapper.toOrm(user)
    await this.ormRepo.save(row)
  }
  // ...
}
```

## SOLID in Practice

### Single Responsibility
```typescript
// Bad: UserService does too much
class UserService {
  async register(dto) { /* creates user + sends email + logs audit */ }
  async updateProfile(dto) { /* validates + updates + notifies */ }
  async generateReport() { /* queries DB + formats CSV + sends email */ }
}

// Good: each class has one reason to change
class UserRegistrationService { /* only: validate, create, emit event */ }
class EmailNotificationService { /* only: send emails */ }
class AuditLogService { /* only: write audit entries */ }
class UserReportService { /* only: query, format, export */ }
```

### Open/Closed
```typescript
// Open for extension, closed for modification
interface NotificationChannel {
  send(message: NotificationMessage): Promise<void>
}

class EmailChannel implements NotificationChannel { /* ... */ }
class SmsChannel   implements NotificationChannel { /* ... */ }
class SlackChannel implements NotificationChannel { /* ... */ }

class NotificationService {
  constructor(private channels: NotificationChannel[]) {}

  // No modification needed when adding a new channel
  async notify(message: NotificationMessage) {
    await Promise.all(this.channels.map(c => c.send(message)))
  }
}
```

### Dependency Inversion
```typescript
// Domain doesn't depend on infrastructure
// Bad:
class OrderService {
  private repo = new TypeOrmOrderRepository() // concrete dep!
}

// Good:
@Injectable()
class OrderService {
  constructor(
    @Inject(ORDER_REPOSITORY_TOKEN)
    private readonly repo: IOrderRepository, // interface dep
  ) {}
}
```

## Module Design

```typescript
// users/users.module.ts
@Module({
  imports: [
    TypeOrmModule.forFeature([UserOrmEntity]),
    CqrsModule,
    ConfigModule,
  ],
  controllers: [UsersController],
  providers: [
    // Application
    CreateUserHandler,
    GetUserQueryHandler,
    // Domain services
    UserDomainService,
    // Infrastructure adapters
    {
      provide:  IUserRepository,   // injection token
      useClass: UserTypeOrmRepository,
    },
    {
      provide:  IPasswordHasher,
      useClass: BcryptPasswordHasher,
    },
  ],
  exports: [IUserRepository],  // only export what other modules need
})
export class UsersModule {}
```

## Event-Driven Architecture

```typescript
// Sagas coordinate cross-module workflows
@Injectable()
export class UserOnboardingSaga {
  @Saga()
  userCreated = (events$: Observable<unknown>): Observable<ICommand> => {
    return events$.pipe(
      ofType(UserCreatedEvent),
      map(event => new SendWelcomeEmailCommand(event.email, event.name)),
    )
  }
}
```

## ADR (Architecture Decision Record) Template

```markdown
# ADR-001: Use CQRS Pattern for Write-Heavy Modules

## Status
Accepted

## Context
Orders and inventory modules have complex write operations with multiple side effects.
Read and write models diverge significantly.

## Decision
Adopt CQRS using @nestjs/cqrs for these modules.
Simple CRUD modules (users, settings) remain using direct service calls.

## Consequences
+ Clear separation of read/write models
+ Easier to add event sourcing later
+ Better testability via command/query handlers
- Higher initial complexity
- Two data models to maintain in some cases
```

## Forbidden Patterns

- Never have circular dependencies between modules — restructure into shared modules
- Never access the database from the domain layer — only through repository interfaces
- Never put I/O (HTTP, DB, file system) in domain entities or value objects
- Never use `static` mutable state in services — it breaks testability and concurrency
- Never expose ORM entities directly to the API layer — map to DTOs
- Never put business rules in controllers — they belong in the domain or application layer
- Never use inheritance where composition would work — prefer interfaces and DI

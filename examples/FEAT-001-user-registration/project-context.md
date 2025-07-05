# Project Context - User Registration Feature

## Overview
This feature is part of our SaaS platform's authentication system. We're building a modern, secure user registration flow that will serve as the foundation for all user authentication and authorization features.

## Architecture

### System Architecture
- **Pattern**: Microservices with API Gateway
- **Style**: RESTful APIs with potential GraphQL in future
- **Database**: PostgreSQL for user data, Redis for caching/sessions
- **Message Queue**: RabbitMQ for async operations (email sending)

### Component Relationships
```
┌─────────────┐     ┌──────────────┐     ┌────────────────┐
│  Frontend   │────▶│  API Gateway │────▶│  Auth Service  │
└─────────────┘     └──────────────┘     └────────────────┘
                                                   │
                                          ┌────────▼────────┐
                                          │   PostgreSQL    │
                                          └────────┬────────┘
                                                   │
                    ┌──────────────┐      ┌────────▼────────┐
                    │ Email Service │◀─────│   RabbitMQ     │
                    └──────────────┘      └─────────────────┘
```

## Technical Stack
- **Language**: Node.js with TypeScript
- **Framework**: Express.js with TypeORM
- **Database**: PostgreSQL 14
- **Cache**: Redis 6
- **Email**: SendGrid API
- **Testing**: Jest, Supertest
- **Container**: Docker
- **CI/CD**: GitHub Actions

## Coding Standards

### TypeScript Guidelines
```typescript
// Use interfaces for data structures
interface CreateUserDto {
  email: string;
  password: string;
  firstName: string;
  lastName: string;
}

// Use classes for services
class RegistrationService {
  constructor(
    private userRepository: UserRepository,
    private emailService: EmailService
  ) {}
}
```

### Naming Conventions
- **Classes**: PascalCase (e.g., `UserService`, `EmailVerification`)
- **Interfaces**: PascalCase with 'I' prefix for contracts (e.g., `IUserRepository`)
- **Methods**: camelCase (e.g., `registerUser`, `sendVerificationEmail`)
- **Files**: kebab-case (e.g., `user-registration.service.ts`)
- **Database**: snake_case (e.g., `email_verifications`, `created_at`)

### Error Handling
```typescript
// Custom error classes
class DuplicateEmailError extends Error {
  constructor(email: string) {
    super(`Email ${email} is already registered`);
    this.name = 'DuplicateEmailError';
  }
}

// Consistent error responses
{
  "error": {
    "code": "DUPLICATE_EMAIL",
    "message": "This email is already registered",
    "timestamp": "2024-01-15T10:30:00Z"
  }
}
```

## Project Structure
```
src/
├── modules/
│   └── auth/
│       ├── controllers/
│       │   └── registration.controller.ts
│       ├── services/
│       │   ├── registration.service.ts
│       │   └── email-verification.service.ts
│       ├── repositories/
│       │   └── user.repository.ts
│       ├── entities/
│       │   ├── user.entity.ts
│       │   └── email-verification.entity.ts
│       ├── dto/
│       │   ├── create-user.dto.ts
│       │   └── verify-email.dto.ts
│       └── auth.module.ts
├── common/
│   ├── middleware/
│   │   ├── rate-limit.middleware.ts
│   │   └── validation.middleware.ts
│   └── exceptions/
│       └── http-exception.filter.ts
└── infrastructure/
    ├── database/
    │   └── migrations/
    └── email/
        └── templates/
```

## Development Patterns

### Repository Pattern
```typescript
@Injectable()
export class UserRepository {
  constructor(
    @InjectRepository(User)
    private repository: Repository<User>
  ) {}
  
  async findByEmail(email: string): Promise<User | null> {
    return this.repository.findOne({ where: { email } });
  }
}
```

### DTO Validation
```typescript
export class CreateUserDto {
  @IsEmail()
  @IsNotEmpty()
  email: string;

  @IsStrongPassword({
    minLength: 8,
    minLowercase: 1,
    minUppercase: 1,
    minNumbers: 1
  })
  password: string;
}
```

### Service Layer Pattern
- Business logic in services
- Controllers handle HTTP concerns only
- Repositories handle data access
- Clear separation of concerns

## Testing Strategy

### Test Structure
```
__tests__/
├── unit/
│   ├── services/
│   └── repositories/
├── integration/
│   ├── controllers/
│   └── workflows/
└── e2e/
    └── registration.e2e.spec.ts
```

### Testing Patterns
```typescript
describe('RegistrationService', () => {
  let service: RegistrationService;
  let mockUserRepo: jest.Mocked<UserRepository>;
  
  beforeEach(() => {
    // Setup mocks
  });
  
  it('should create user with hashed password', async () => {
    // Given
    const dto = createMockUserDto();
    
    // When
    const user = await service.registerUser(dto);
    
    // Then
    expect(user.password).not.toBe(dto.password);
    expect(bcrypt.compareSync(dto.password, user.password)).toBe(true);
  });
});
```

## Integration Points

### API Gateway
- Routes `/api/v1/auth/*` to auth service
- Handles authentication tokens
- Rate limiting at gateway level

### Email Service
- Async communication via RabbitMQ
- Retry mechanism for failed deliveries
- Template management system

### Frontend
- React SPA expecting JSON responses
- Expects consistent error format
- Requires CORS headers

## Security Considerations

### Password Security
- Bcrypt with cost factor 12
- Password complexity requirements
- No password history storage initially

### Token Security
- Cryptographically secure random tokens
- 24-hour expiration
- One-time use only
- Constant-time comparison

### API Security
- Rate limiting: 5 requests per hour per IP
- CORS configured for frontend domain only
- Security headers (Helmet.js)
- Input validation on all endpoints

## Performance Requirements

### Response Times
- Registration endpoint: < 500ms (including password hashing)
- Email sending: Async (immediate response to user)
- Verification endpoint: < 200ms

### Scalability
- Horizontal scaling ready
- Database connection pooling
- Redis for session management
- Stateless service design

## Deployment

### Environments
- Development: Local Docker Compose
- Staging: Kubernetes cluster
- Production: Kubernetes with auto-scaling

### Configuration
```yaml
# config/default.yml
database:
  host: ${DB_HOST}
  port: ${DB_PORT}
  username: ${DB_USER}
  password: ${DB_PASSWORD}
  
email:
  provider: sendgrid
  apiKey: ${SENDGRID_API_KEY}
  
redis:
  url: ${REDIS_URL}
```

### Monitoring
- APM: DataDog
- Logs: ELK Stack
- Metrics: Prometheus + Grafana
- Alerts: PagerDuty integration

## Related Documentation
- [Main API Documentation](../docs/api/README.md)
- [Authentication Architecture](../docs/architecture/auth.md)
- [Security Guidelines](../docs/security/guidelines.md)
- [Database Schema](../docs/database/schema.md)

## Notes for Development

### Known Considerations
1. Email delivery can be slow - always async
2. Use database transactions for user + verification record creation
3. Email field should be case-insensitive for lookups
4. Consider GDPR requirements for user data

### Preferred Libraries
- Validation: class-validator
- Email templates: Handlebars
- Password hashing: bcrypt (not bcryptjs)
- UUID: uuid v4
- Date handling: date-fns

### Team Conventions
- PR requires 2 approvals
- 80% test coverage minimum
- All endpoints must have OpenAPI docs
- Database migrations reviewed by DBA
- Security changes reviewed by security team
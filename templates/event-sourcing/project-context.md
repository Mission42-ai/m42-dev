# Event-Sourcing Project Context

## Overview
This project follows Event Sourcing and CQRS (Command Query Responsibility Segregation) patterns. All state changes are captured as immutable events, providing a complete audit trail and enabling powerful features like time-travel debugging and event replay.

## Architecture

### Event Sourcing Pattern
- **Events**: Immutable facts that describe something that happened
- **Aggregates**: Domain objects that produce events and maintain consistency
- **Event Store**: Persistent storage for all events
- **Projections**: Read models built from events

### CQRS Pattern
- **Commands**: Intentions to change state (write side)
- **Command Handlers**: Process commands and produce events
- **Queries**: Requests for data (read side)
- **Query Handlers**: Serve data from projections

### Data Flow
```
Command → Command Handler → Aggregate → Events → Event Store
                                           ↓
                                    Event Handlers
                                           ↓
                                    Projections → Query Handlers → Response
```

## Technical Stack
- Programming Language: [e.g., TypeScript, Java, C#]
- Event Store: [e.g., EventStore, PostgreSQL with event tables]
- Message Bus: [e.g., RabbitMQ, Kafka, NATS]
- Projection Store: [e.g., PostgreSQL, MongoDB, ElasticSearch]
- Framework: [e.g., NestJS CQRS, Axon, EventFlow]

## Coding Standards

### Event Naming
- Past tense: `OrderPlaced`, `PaymentProcessed`, `UserRegistered`
- Include aggregate ID and event metadata
- Version events from the start

### Aggregate Rules
- One aggregate per transaction
- Aggregates are consistency boundaries
- No direct references between aggregates
- Use domain events for communication

### Command Naming
- Imperative mood: `PlaceOrder`, `ProcessPayment`, `RegisterUser`
- Include all data needed for validation
- Commands should be idempotent when possible

### File Structure
```
src/
├── domain/
│   ├── aggregates/      # Aggregate roots
│   ├── events/          # Domain events
│   ├── value-objects/   # Value objects
│   └── exceptions/      # Domain exceptions
├── application/
│   ├── commands/        # Command DTOs
│   ├── command-handlers/# Command processing
│   ├── queries/         # Query DTOs
│   └── query-handlers/  # Query processing
├── infrastructure/
│   ├── event-store/     # Event persistence
│   ├── projections/     # Read model builders
│   └── repositories/    # Aggregate repositories
└── presentation/
    └── controllers/     # API endpoints
```

## Development Patterns

### Event Design
- Keep events small and focused
- Include enough data to be self-contained
- Never change published events (versioning instead)
- Consider event enrichment for integration events

### Aggregate Design
```typescript
// Example aggregate structure
class OrderAggregate extends AggregateRoot {
  apply(event: DomainEvent): void {
    // Update internal state based on event
  }
  
  // Business methods produce events
  placeOrder(customerId: string, items: OrderItem[]): void {
    // Validate invariants
    // Emit OrderPlaced event
  }
}
```

### Projection Design
- Projections are disposable (can be rebuilt)
- Optimize for query performance
- Denormalize as needed
- Handle eventual consistency

### Event Versioning Strategy
1. **Weak Schema**: Add optional fields (backward compatible)
2. **Strong Schema**: New event version with upcasting
3. **Event Transformation**: Transform old events during replay

## Testing Strategy

### Event Sourcing Tests
```typescript
// Given-When-Then pattern
given([
  new OrderCreated(orderId, customerId),
  new ItemAdded(orderId, itemId, quantity)
])
.when(new CompleteOrder(orderId))
.then([
  new OrderCompleted(orderId, totalAmount)
]);
```

### Test Categories
- **Unit Tests**: Aggregate behavior, pure domain logic
- **Integration Tests**: Event store, projections
- **Scenario Tests**: Full command-to-query flows
- **Event Replay Tests**: Verify deterministic behavior

## Integration Points

### Event Publishing
- Domain events vs Integration events
- Event ordering guarantees
- At-least-once delivery
- Idempotent event handlers

### External Systems
- Publish integration events
- Anti-corruption layer for incoming data
- Saga pattern for distributed transactions
- Compensating transactions

## Security Considerations

### Event Store Security
- Encrypt sensitive data in events
- Access control for event streams
- Audit trail is built-in
- GDPR compliance (event transformation)

### Command Security
- Authenticate commands
- Authorize based on aggregate state
- Rate limiting per user/tenant
- Command validation

## Performance Considerations

### Event Store
- Partitioning strategy (by aggregate type/tenant)
- Snapshot frequency for long streams
- Event batching for writes
- Async projections for read performance

### Projections
- Eventually consistent by design
- Projection lag monitoring
- Cache warming strategies
- Read model optimization

## Monitoring & Operations

### Key Metrics
- Event processing lag
- Projection rebuild time
- Command success/failure rates
- Event store throughput

### Operational Tools
- Event browser/viewer
- Projection rebuild commands
- Event replay utilities
- Consistency checkers

## Common Patterns

### Process Managers/Sagas
- Long-running business processes
- Coordinate between aggregates
- Handle distributed transactions
- Compensation logic

### Event Enrichment
- Add metadata for integration
- Include causation/correlation IDs
- Timestamp standardization
- User context

### Temporal Queries
- Query state at specific time
- Audit trail queries
- Change history
- Time-travel debugging

## Development Workflow

1. **Design Events First**: Start with event storming
2. **Model Aggregates**: Define boundaries and invariants
3. **Implement Commands**: Write side first
4. **Build Projections**: Create read models
5. **Test Scenarios**: Full flow testing

## Team Conventions

### Event Documentation
- Document event schemas
- Explain business meaning
- Note version changes
- Migration guides

### Code Reviews Focus
- Event design and naming
- Aggregate boundaries
- Consistency guarantees
- Performance implications

## Troubleshooting

### Common Issues
- Projection out of sync: Rebuild from events
- Event ordering issues: Check partitioning
- Performance degradation: Review snapshot strategy
- Consistency problems: Verify aggregate boundaries

### Debugging Tools
- Event stream browser
- Command/event correlation tracking
- Projection state inspector
- Event replay debugger

## Related Documentation
- [Event Sourcing Patterns Guide]
- [CQRS Implementation Details]
- [Domain-Driven Design Practices]
- [Event Store Operations Manual]
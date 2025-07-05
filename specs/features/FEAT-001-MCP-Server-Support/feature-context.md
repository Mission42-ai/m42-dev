# Feature Context

## Feature Overview
Create an MCP (Model Context Protocol) server that exposes m42-dev functionality as tools accessible to Claude Code. This enables Claude to orchestrate autonomous development workflows, manage features, and monitor progress programmatically through the MCP protocol.

## Integration with Existing System
### Dependencies
- **Modules/Features**: 
  - m42-dev.sh core script
  - Project state management system
  - Feature and milestone tracking
- **External Services**: None
- **Libraries**: 
  - @modelcontextprotocol/sdk (Node.js MCP SDK)
  - TypeScript for type safety
  - child_process for executing bash commands

### Exposed APIs
MCP Tools:

**Project Management:**
- `m42_init_project` - Initialize a new m42-dev project
- `m42_init_feature` - Create a new feature
- `m42_start_milestone` - Start milestone development
- `m42_status` - Get project/feature/milestone status
- `m42_list_features` - List all features
- `m42_list_milestones` - List milestones for a feature
- `m42_reset` - Reset feature or milestone

**Project Intelligence:**
- `m42_analyze_project` - Deep analysis of codebase architecture
- `m42_find_implementations` - Find specific patterns/implementations
- `m42_get_architecture_info` - Get architectural patterns and conventions
- `m42_search_codebase` - Search for code patterns or text

**Development Execution:**
- `m42_implement_task` - Create/modify files for a task
- `m42_run_tests` - Execute test suites
- `m42_validate_implementation` - Check implementation against patterns
- `m42_save_progress` - Save current development state

**Git Integration:**
- `m42_git_status` - Get current git status
- `m42_git_commit` - Create git commits
- `m42_git_diff` - View changes
- `m42_git_log` - View commit history

**Utility Tools:**
- `m42_read_specs` - Read specification files
- `m42_read_logs` - Read log files
- `m42_delegate_to_agent` - Delegate tasks to specialized agents

### Events
- **Published**: 
  - Tool execution start/complete events
  - Error events for failed operations
- **Consumed**: 
  - MCP protocol messages (tool calls, cancellations)

## Domain Model
### Entities
- **MCPServer**: Main server instance handling protocol communication
- **M42Tool**: Abstract base for all m42-dev tools
- **CommandExecutor**: Handles subprocess execution of m42-dev.sh
- **OutputParser**: Parses command outputs for structured responses

### Business Rules
- All long-running operations must support cancellation
- File paths must be validated before execution
- Commands must run with appropriate timeouts
- Output must be properly sanitized for JSON responses

### Value Objects
- **ToolResult**: Standardized tool execution result
- **M42Command**: Encapsulates m42-dev command with parameters
- **ExecutionContext**: Runtime context for tool execution

## Technical Constraints
### Performance
- Simple commands (status, list) must respond within 500ms
- Support concurrent tool executions (min 5)
- Stream output for long-running operations

### Security
- Validate all input parameters
- Restrict file access to project directory
- No execution of arbitrary commands
- Sanitize all outputs

### Scalability
- Stateless server design
- Process pool for concurrent executions
- Efficient subprocess management

## Data Model
### Schema
No database required - operates on file system state managed by m42-dev

### Migration Strategy
N/A - Uses existing m42-dev file structure

## Testing Requirements
### Unit Tests
- Tool parameter validation
- Command building logic
- Output parsing accuracy
- Error handling paths

### Integration Tests
- Real m42-dev.sh execution
- File system operations
- Concurrent tool execution
- Long-running operation handling

### E2E Tests
- Complete feature initialization flow
- Milestone execution with Claude Code
- Status tracking across operations
- Error recovery scenarios

## Deployment & Operations
### Configuration
```json
{
  "m42DevPath": "./m42-dev.sh",
  "workingDirectory": ".",
  "maxConcurrentOperations": 5,
  "commandTimeout": 600000,
  "logLevel": "info"
}
```

### Feature Flags
- `enableProgressUpdates`: Stream progress for long operations
- `enableMetrics`: Collect performance metrics
- `debugMode`: Verbose logging for troubleshooting

### Monitoring
- Tool execution count and duration
- Error rates by tool type
- Concurrent operation count
- Memory usage trends

## Notes
- The MCP server acts as a bridge between Claude Code and m42-dev bash script
- Designed for local development environments
- Future enhancement: Web-based UI for monitoring
- Consider adding resource management for multiple projects
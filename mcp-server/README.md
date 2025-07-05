# M42-Dev MCP Server

MCP (Model Context Protocol) server that exposes m42-dev functionality as tools accessible to Claude Code and other MCP clients.

## Installation

```bash
cd mcp-server
npm install
```

## Building

```bash
npm run build
```

## Running

### Development Mode

```bash
npm run dev
```

### Production Mode

```bash
npm run build
npm start
```

## Configuration

The server can be configured through environment variables:

- `M42_PROJECT_ROOT`: Project root directory (defaults to current directory)
- `M42_PATH`: Path to m42-dev.sh script (defaults to `./m42-dev.sh`)
- `LOG_LEVEL`: Logging level (debug, info, warn, error) - defaults to 'info'

## Available Tools

### Project Management

- `m42_init_project` - Initialize a new m42-dev project
- `m42_init_feature` - Create a new feature
- `m42_status` - Get project/feature/milestone status
- `m42_list_features` - List all features

### Coming Soon

- `m42_start_milestone` - Start milestone development
- `m42_list_milestones` - List milestones for a feature
- `m42_reset` - Reset feature or milestone
- `m42_analyze_project` - Deep analysis of codebase
- `m42_implement_task` - Create/modify files for a task
- `m42_run_tests` - Execute test suites
- `m42_git_status` - Get current git status
- `m42_git_commit` - Create git commits

## Integration with Claude Code

Add to your Claude Code settings:

```json
{
  "mcpServers": {
    "m42-dev": {
      "command": "node",
      "args": ["path/to/m42-dev/mcp-server/dist/index.js"],
      "env": {
        "M42_PROJECT_ROOT": "/path/to/your/project"
      }
    }
  }
}
```

## Development

### Testing

```bash
npm test
```

### Linting

```bash
npm run lint
```

### Type Checking

```bash
npm run typecheck
```
# M42-Dev Library Structure

This directory contains the modular components of the m42-dev tool, organized for maintainability and reusability.

## Directory Structure

```
lib/
├── config.sh              # Global configuration and constants
├── core/                  # Core functionality
│   └── context.sh        # Feature and milestone context management
├── commands/             # User-facing commands
│   ├── init_project.sh   # Initialize new project
│   ├── init_feature.sh   # Initialize new feature
│   ├── list_features.sh  # List features
│   ├── status.sh         # Show status
│   ├── start.sh          # Start milestone development
│   ├── recover.sh        # Recovery operations
│   └── reset.sh          # Reset feature/milestone
├── milestone/            # Milestone-related functions
│   ├── development.sh    # Development phase logic
│   ├── info.sh          # Milestone information utilities
│   ├── checklist.sh     # Checklist management
│   └── state.sh         # State management
├── review/              # Code review functionality
│   └── review.sh        # Review phase implementation
├── utils/               # Utility functions
│   └── logging.sh       # Logging and output formatting
└── prompts/             # Prompt utilities
    └── load-prompt.sh   # Template loading and substitution
```

## Module Dependencies

### Core Modules
- `config.sh` - Must be sourced first, sets up all environment variables
- `utils/logging.sh` - Provides logging functions used by all other modules
- `core/context.sh` - Manages feature and milestone contexts

### Command Modules
Each command module in `commands/` sources its required dependencies:
- Most depend on `logging.sh` and `context.sh`
- Development commands also source milestone modules
- Recovery commands source review and development modules

### Module Loading Order
The main `m42-dev` script sources modules in this order:
1. Configuration (`config.sh`)
2. Utilities (`logging.sh`, `context.sh`)
3. Commands (all command modules)
4. Additional utilities as needed

## Adding New Functionality

To add a new command:
1. Create a new file in `commands/` (e.g., `commands/my_command.sh`)
2. Source required dependencies at the top
3. Implement your command function
4. Add the command to the main switch statement in `m42-dev`

To add new utilities:
1. Place them in the appropriate directory
2. Source them where needed
3. Follow the existing naming conventions

## Environment Variables

All configuration is centralized in `config.sh`:
- `M42_ROOT` - Root directory of m42-dev
- `M42_LIB_DIR` - This library directory
- `M42_TEMPLATES_DIR` - Templates directory
- `M42_PROMPTS_DIR` - Prompts directory
- `M42_FEATURES_DIR` - Features storage directory
- `M42_MAX_ITERATIONS` - Maximum development iterations
- `M42_USE_PARALLEL_REVIEW` - Enable parallel review mode
- And more...

## Best Practices

1. **Single Responsibility**: Each module should have a clear, single purpose
2. **Explicit Dependencies**: Always source required modules at the top
3. **Use Logging Functions**: Use the provided logging functions for consistent output
4. **Error Handling**: Return non-zero exit codes on errors
5. **Documentation**: Add comments for complex logic
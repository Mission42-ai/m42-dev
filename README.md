# M42 Dev - Autonomous Development Tool

A powerful orchestration system that enables fully autonomous feature development using Claude Code. This tool manages complex feature implementations through milestone-based development with automatic dependency resolution, parallel execution, and quality gates.

## 🏗️ Project Structure

```
m42-dev/
├── m42-dev              # Main entry point (executable)
├── m42-dev.sh          # Symlink for backward compatibility
├── lib/                # Modular library components
│   ├── config.sh      # Configuration and constants
│   ├── commands/      # User-facing commands
│   ├── core/         # Core functionality
│   ├── milestone/    # Milestone management
│   ├── review/       # Code review logic
│   └── utils/        # Utilities
├── templates/          # Project and feature templates
├── prompts/           # Claude prompts for different phases
└── specs/             # Project specifications storage
```

The tool has been refactored into a clean, modular architecture where each component has a single responsibility. See `lib/README.md` for details on the library structure.

## 🌟 Features

- **Autonomous Development**: Claude Code agents work independently on feature milestones
- **Parallel Execution**: Multiple milestones run concurrently when dependencies allow
- **State Management**: Persistent progress tracking across development sessions
- **Quality Gates**: Automatic code review and iteration until standards are met
- **Flexible Architecture**: Works with any project structure and tech stack

## 📋 Table of Contents

- [Quick Start](#-quick-start)
- [Installation](#-installation)
- [How It Works](#-how-it-works)
- [Usage Guide](#-usage-guide)
- [Feature Structure](#-feature-structure)
- [Advanced Usage](#-advanced-usage)
- [Troubleshooting](#-troubleshooting)
- [Contributing](#-contributing)

## 🚀 Quick Start

```bash
# 1. Clone this tool to your project
git clone https://github.com/Mission42-ai/m42-dev.git tools/m42-dev

# 2. Install the Claude command
ln -s ../../tools/m42-dev/commands/develop-feature.md .claude/commands/

# 3. Start developing a feature
# In Claude Code:
/develop-feature FEAT-123-new-authentication
```

## 📦 Installation

### Method 1: Git Clone (Recommended)

```bash
# Navigate to your project root
cd your-project

# Clone the tool
git clone https://github.com/Mission42-ai/m42-dev.git tools/m42-dev

# Create .claude/commands directory if it doesn't exist
mkdir -p .claude/commands

# Link the command
ln -s ../../tools/m42-dev/commands/develop-feature.md .claude/commands/
```

### Method 2: Git Submodule

```bash
# Add as submodule
git submodule add https://github.com/yourusername/claude-autonomous-dev.git tools/claude-dev
git submodule init
git submodule update

# Link the command
mkdir -p .claude/commands
ln -s ../../tools/m42-dev/commands/develop-feature.md .claude/commands/
```

### Method 3: Direct Installation

```bash
# Run the installer
curl -sSL https://raw.githubusercontent.com/yourusername/claude-autonomous-dev/main/install.sh | bash
```

## 🔧 How It Works

### Architecture Overview

```
┌─────────────────┐     ┌──────────────┐     ┌──────────────┐
│   Requirements  │────▶│ Orchestrator │────▶│   Milestone  │
│  + Milestones   │     │   (Claude)   │     │    Agents    │
└─────────────────┘     └──────┬───────┘     └──────┬───────┘
                               │                      │
                               │ Monitors             │ Develop
                               ▼                      │
                        ┌──────────────┐              │
                        │    State     │◀─────────────┘
                        │  Management  │
                        └──────────────┘
```

### Development Flow

1. **Feature Definition**: Create requirements.yaml with milestones
2. **Dependency Analysis**: Tool identifies which milestones can run in parallel
3. **Autonomous Execution**: Claude agents work on each milestone
4. **Quality Control**: Automatic review and iteration
5. **Progress Tracking**: State persisted between sessions

## 📖 Usage Guide

### Creating a New Feature

```bash
# Using Claude command
/develop-feature FEAT-123-user-authentication

# Or using bash directly
tools/m42-dev/m42-dev.sh init FEAT-123-user-authentication
```

This creates:
```
specs/features/FEAT-123-user-authentication/
├── requirements.yaml      # Feature requirements and milestones
├── project-context.md     # Project-specific context
└── .claude-workflow/      # State management (created during execution)
```

### Defining Milestones

Edit `requirements.yaml` to define your milestones:

```yaml
milestones:
  - id: "M1"
    name: "Domain Model"
    dependencies: []  # Can start immediately
    estimated_hours: 4
    implementation_checklist:
      domain:
        "Create User aggregate": "pending"
        "Define UserRegistered event": "pending"
        "Implement password value object": "pending"
    acceptance_tests:
      - scenario: "User creation"
        given: ["Valid user data"]
        when: ["User.create() called"]
        then: ["User aggregate created", "UserRegistered event emitted"]

  - id: "M2"
    name: "Application Layer"
    dependencies: ["M1"]  # Waits for M1 to complete
    estimated_hours: 3
    implementation_checklist:
      commands:
        "Create RegisterUserCommand": "pending"
        "Implement command handler": "pending"
      queries:
        "Create GetUserByEmailQuery": "pending"
        "Implement query handler": "pending"

  - id: "M3"
    name: "API Layer"
    dependencies: ["M2"]  # Waits for M2
    # ...

  - id: "M4"
    name: "Testing"
    dependencies: ["M1"]  # Can run parallel to M2, M3 after M1
    # ...
```

### Starting Development

```bash
# Claude command (orchestrates everything)
/develop-feature FEAT-123-user-authentication

# What happens:
# 1. M1 starts (no dependencies)
# 2. When M1 completes → M2 and M4 start in parallel
# 3. When M2 completes → M3 starts
# 4. Continues until all milestones complete
```

### Monitoring Progress

```bash
# Check feature status
tools/m42-dev/m42-dev.sh status FEAT-123-user-authentication

# Check specific milestone
tools/m42-dev/m42-dev.sh status FEAT-123-user-authentication M1

# View logs
tail -f specs/features/FEAT-123/.claude-workflow/milestones/M1/iterations/dev_*.md
```

## 📁 Feature Structure

### requirements.yaml Structure

```yaml
feature:
  id: "FEAT-XXX"
  name: "Feature Name"
  description: "What and why"
  business_value:
    - "Value proposition 1"
    - "Value proposition 2"

requirements:
  functional:
    - id: "FR-1"
      priority: "P0"
      description: "Core functionality"
  technical:
    - "Must follow patterns"
    - "Performance requirements"
  non_functional:
    - metric: "response_time"
      target: "< 200ms"

milestones:
  - id: "M1"
    name: "Milestone Name"
    dependencies: []  # List of milestone IDs
    estimated_hours: 4
    implementation_checklist:
      category:
        "Task description": "pending|in_progress|completed"
    acceptance_tests:
      - scenario: "Test scenario"
        given: ["Preconditions"]
        when: ["Action"]
        then: ["Expected results"]
    definition_of_done:
      - "All checklist items completed"
      - "Tests passing"
      - "Code reviewed"

parallel_execution:
  max_concurrent_milestones: 3
  coordination:
    - "M1 must complete before M2, M3"
    - "M4 can run parallel to M2, M3"
```

### State Management

The tool maintains state in `.claude-workflow/`:

```
.claude-workflow/
├── state/
│   └── global.json           # Overall feature progress
├── milestones/
│   ├── M1/
│   │   ├── state/
│   │   │   ├── checklist.json    # Task progress
│   │   │   └── current.json      # Milestone status
│   │   ├── iterations/           # Development outputs
│   │   ├── reviews/              # Review results
│   │   └── context/              # Accumulated knowledge
│   └── M2/
│       └── ...
└── logs/                     # Execution logs
```

## 🔧 Advanced Usage

### Manual Milestone Control

```bash
# Start specific milestone
tools/m42-dev/m42-dev.sh start FEAT-123 M1

# Reset failed milestone
tools/m42-dev/m42-dev.sh reset FEAT-123 M1

# List all milestones
tools/m42-dev/m42-dev.sh milestones FEAT-123
```

### Custom Templates

Create your own templates in `templates/`:

```bash
# Copy and modify default templates
cp templates/default/* templates/my-framework/
# Edit templates for your specific needs
```

### Integration with CI/CD

```yaml
# .github/workflows/feature-dev.yml
name: Autonomous Feature Development
on:
  issue:
    types: [labeled]

jobs:
  develop:
    if: github.event.label.name == 'auto-develop'
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - name: Run autonomous development
        run: |
          ./tools/m42-dev/m42-dev.sh start FEAT-${{ github.event.issue.number }}
```

## 🐛 Troubleshooting

### Common Issues

**Script not found**
```bash
# Check installation
ls -la tools/m42-dev/
# Ensure execute permissions
chmod +x tools/m42-dev/m42-dev.sh
```

**Milestone stuck**
```bash
# Check logs
cat specs/features/FEAT-XXX/.claude-workflow/milestones/M1/reviews/review_*.json
# Reset and retry
tools/m42-dev/m42-dev.sh reset FEAT-XXX M1
```

**Dependencies not working**
```bash
# Verify requirements.yaml syntax
yq eval '.milestones' specs/features/FEAT-XXX/requirements.yaml
# Check global state
cat specs/features/FEAT-XXX/.claude-workflow/state/global.json
```

### Debug Mode

```bash
# Enable verbose logging
export CLAUDE_DEV_DEBUG=1
tools/m42-dev/m42-dev.sh start FEAT-XXX M1
```

## 🤝 Contributing

Contributions are welcome! Please read our [Contributing Guide](CONTRIBUTING.md) for details.

### Development Setup

```bash
# Clone the repository
git clone https://github.com/yourusername/claude-autonomous-dev.git
cd claude-autonomous-dev

# Run tests
./test.sh

# Make your changes
# ...

# Submit PR
```

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- Built for use with [Claude Code](https://claude.ai/code)
- Inspired by modern DevOps practices
- Thanks to all contributors

## 📞 Support

- **Issues**: [GitHub Issues](https://github.com/yourusername/claude-autonomous-dev/issues)
- **Discussions**: [GitHub Discussions](https://github.com/yourusername/claude-autonomous-dev/discussions)
- **Email**: support@example.com

---

Made with ❤️ by the Claude Autonomous Development Team
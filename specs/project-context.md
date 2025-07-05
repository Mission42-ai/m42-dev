# Project Context

## Project Overview
**Name:** M42 Dev - Autonomous Development Tool
**Description:** A powerful orchestration system that enables fully autonomous feature development using Claude Code. This tool manages complex feature implementations through milestone-based development with automatic dependency resolution, parallel execution, and quality gates.
**Primary Purpose:** To enable autonomous, AI-driven feature development by orchestrating Claude Code agents to work on complex software projects systematically and in parallel
**Target Users:** Software development teams, individual developers, and organizations looking to accelerate feature development through AI automation while maintaining high code quality standards

## Technical Stack
### Languages & Frameworks
- **Primary Language:** Bash Shell Script (POSIX-compliant with bash extensions)
- **Data Formats:** YAML (requirements), JSON (state management), Markdown (documentation)
- **Integration:** Claude Code CLI for AI-driven development

### Infrastructure & Tools
- **AI Engine:** Claude Code CLI (Anthropic's AI coding assistant)
- **Version Control:** Git for source control and automatic commit management
- **JSON Processing:** jq for state management and JSON manipulation
- **YAML Processing:** yq (mikefarah version) for parsing requirements and configurations
- **Shell Environment:** Bash-compatible (Linux, macOS, WSL on Windows)

### Development Tools
- **Testing:** Built-in quality gates and review mechanisms
- **Documentation:** Markdown-based templates and auto-generation
- **State Management:** JSON-based persistent state tracking
- **Logging:** Structured logging with iteration and review tracking

## Architecture Overview
### High-Level Architecture
The system follows a **orchestrator pattern** where the main bash script (`m42-dev.sh`) acts as a conductor, managing the lifecycle of feature development through autonomous AI agents. It implements:
- **Event-driven milestone execution** with dependency resolution
- **State machine** for tracking feature and milestone progress
- **Plugin-based template system** for different architectural patterns
- **Iterative development loop** with quality gates

### Key Components
1. **Main Orchestrator (`m42-dev.sh`)**
   - CLI interface with commands (init, start, status, reset)
   - Feature lifecycle management
   - Milestone dependency resolution and scheduling
   - State persistence and recovery

2. **Installation System (`install.sh`)**
   - Prerequisites verification (git, jq, yq)
   - Project structure creation
   - Claude command integration via symbolic links
   - Template copying and .gitignore setup

3. **Command Definitions (`commands/`)**
   - Claude Code command specifications
   - Tool restrictions and permissions
   - Execution parameters

4. **Template System (`templates/`)**
   - Architectural pattern templates (default, event-sourcing)
   - Project context templates
   - Requirements structure templates

5. **State Management (`.claude-workflow/`)**
   - Global feature state tracking
   - Per-milestone progress and checklists
   - Iteration outputs and review results

### Design Patterns
- **Command Pattern:** CLI command structure with action handlers
- **State Pattern:** Feature and milestone state machines
- **Template Method:** Customizable development workflows
- **Observer Pattern:** Event-driven milestone completion notifications
- **Strategy Pattern:** Different execution strategies based on dependencies
- **Repository Pattern:** State persistence abstraction

## Code Organization
### Directory Structure
```
m42-dev/
├── m42-dev.sh                  # Main orchestrator script
├── install.sh                  # Installation and setup
├── commands/                   # Claude command definitions
│   └── develop-feature.md      # Feature development command
├── examples/                   # Example feature implementations
│   └── FEAT-001-user-registration/
├── specs/                      # Project and feature specifications
│   ├── project-context.md      # Global project context
│   └── features/               # Active feature workspace
│       └── FEAT-XXX/
│           ├── requirements.yaml
│           ├── project-context.md
│           └── .claude-workflow/
├── templates/                  # Project templates
│   ├── default/               # General-purpose template
│   ├── event-sourcing/        # Event-driven architecture template
│   └── project-context-template.md
├── README.md                  # Project overview and quick start
├── SETUP_GUIDE.md            # Detailed setup instructions
├── CONTRIBUTING.md           # Contribution guidelines
└── LICENSE                   # MIT License
```

### Module Organization
- **Core Functions:** Grouped by functionality in `m42-dev.sh`
  - Feature management functions
  - Milestone orchestration functions
  - State management functions
  - Utility and helper functions
- **Templates:** Organized by architectural pattern
- **Commands:** Separate files for each Claude command type

### Naming Conventions
- **Features:** `FEAT-XXX-description` format
- **Milestones:** `M1`, `M2`, etc. with descriptive names
- **Functions:** `snake_case` for bash functions
- **Files:** `kebab-case` for scripts and documents
- **State Files:** `current.json`, `global.json`, `checklist.json`
- **Directories:** Lowercase with hyphens

## Key Technical Decisions
### Architecture Decisions
1. **Bash as Primary Language**
   - Rationale: Maximum portability, no runtime dependencies
   - Trade-off: Limited data structures, requires external tools (jq, yq)

2. **Milestone-Based Development**
   - Rationale: Manageable chunks, parallel execution, clear progress tracking
   - Trade-off: Overhead for simple features

3. **State Persistence in JSON**
   - Rationale: Human-readable, easy manipulation with jq, Git-friendly
   - Trade-off: Not as efficient as binary formats

4. **Template System**
   - Rationale: Adaptability to different architectures, best practices enforcement
   - Trade-off: Initial template creation overhead

### Technology Choices
1. **Claude Code CLI Integration**
   - Why: Advanced AI capabilities, autonomous development support
   - Alternative considered: Direct API integration (rejected for complexity)

2. **YAML for Requirements**
   - Why: Human-readable, hierarchical structure support, wide tooling support
   - Alternative: JSON (less readable), TOML (less hierarchical)

3. **Git for Version Control**
   - Why: Industry standard, good CLI tools, atomic commits per iteration
   - Built-in: Automatic commits after each development phase

### Trade-offs
1. **Automation vs Control**
   - Automated development with human review gates
   - Can intervene at milestone boundaries

2. **Speed vs Quality**
   - Iterative development with quality checks
   - Slower than direct implementation but higher consistency

3. **Complexity vs Flexibility**
   - Complex orchestration logic for flexible execution
   - Steeper learning curve but powerful capabilities

## Development Workflow
### Git Workflow
- **Branch Strategy:** Feature branches per FEAT-XXX
- **Commit Convention:** Automatic commits per iteration with structured messages
- **Commit Pattern:** `[FEAT-XXX] Milestone MX - Iteration Y: <summary>`
- **Merge Strategy:** Manual review and merge after feature completion

### Testing Strategy
- **Unit Tests:** Embedded in milestone checklists
- **Integration Tests:** Separate milestones for cross-component testing
- **Quality Gates:** Automatic review after each iteration
- **Acceptance Tests:** Defined per milestone in requirements.yaml

### CI/CD Pipeline
- **Local Development:** Full autonomy with local Claude Code
- **Integration:** Compatible with standard CI/CD systems
- **Deployment:** Milestone-based deployment readiness checks

## Domain Concepts
### Core Entities
1. **Feature:** Top-level development unit with business value
2. **Requirement:** Functional, technical, or non-functional specifications
3. **Milestone:** Atomic development unit (4-8 hours)
4. **Task:** Granular checklist item within a milestone
5. **Iteration:** Single development attempt within a milestone
6. **Review:** Quality assessment of an iteration

### Business Rules
1. **Milestone Dependencies:** Must be acyclic graph
2. **Quality Gates:** Must pass before milestone completion
3. **Max Iterations:** Limited to 10 per milestone
4. **Parallel Execution:** Respects dependency constraints
5. **State Persistence:** Survives session interruptions

### Glossary
- **Orchestrator:** Main control script managing execution
- **Agent:** Claude Code instance working on a milestone
- **Context:** Accumulated knowledge and project information
- **Checklist:** Trackable tasks within a milestone
- **Quality Gate:** Automated review checkpoint

## Integration Points
### External Services
- **Claude Code CLI:** Primary AI development engine
- **Git:** Version control and change tracking
- **File System:** State and output persistence

### Internal APIs
- **State Management API:** JSON-based state operations
- **Milestone API:** Dependency checking and execution
- **Context API:** Building and managing development context
- **Review API:** Quality assessment integration

### Data Flows
1. **Requirements Flow:** YAML → Parser → Milestone Queue → Execution
2. **State Flow:** Execution → State Update → JSON Persistence → Recovery
3. **Context Flow:** Project + Feature + Milestone + History → Claude Code
4. **Review Flow:** Git Diff → Review Prompt → Quality Assessment → Next Iteration

## Quality Standards
### Code Quality
- **Bash Best Practices:** 
  - `set -euo pipefail` for error handling
  - Function documentation
  - Input validation
  - Proper quoting
- **Code Review:** Built-in AI review after each iteration
- **Style Guide:** Consistent formatting and naming

### Performance Requirements
- **Milestone Duration:** 4-8 hours target
- **Iteration Timeout:** 600 seconds (10 minutes)
- **Pause Between Iterations:** 5 seconds (configurable)
- **Max Concurrent Milestones:** 2-3 (configurable)

### Security Considerations
- **No Credentials in Code:** Environment variables for sensitive data
- **File Permissions:** Proper workspace isolation
- **Git Integration:** No automatic pushes
- **Audit Trail:** Complete logging of all operations

## Common Patterns & Practices
### Error Handling
- **Fail-Fast:** Immediate exit on critical errors
- **Graceful Degradation:** Fallbacks for missing optional tools
- **State Recovery:** Resume from last known good state
- **Error Logging:** Detailed error messages with context

### Logging & Monitoring
- **Iteration Logs:** `iterations/dev_${iteration}.md`
- **Review Logs:** `reviews/review_${iteration}.json`
- **State Tracking:** Real-time state file updates
- **Progress Display:** Visual progress indicators

### Configuration Management
- **Environment Variables:**
  - `CLAUDE_CMD`: Claude executable path
  - `FEATURE_DIR`: Current feature directory
  - `FEATURE_ID`: Current feature identifier
- **Configuration Files:**
  - `requirements.yaml`: Feature configuration
  - `global.json`: Runtime state
  - Project-specific contexts

## Getting Started
### Prerequisites
1. **Operating System:** Linux, macOS, or Windows with WSL
2. **Required Tools:**
   - Bash 4.0+
   - Git 2.0+
   - jq 1.6+
   - yq 4.0+ (optional but recommended)
   - Claude Code CLI (latest version)

### Local Development Setup
1. Clone the repository:
   ```bash
   git clone <repository-url>
   cd m42-dev
   ```

2. Run installation:
   ```bash
   chmod +x install.sh
   ./install.sh
   ```

3. Initialize a feature:
   ```bash
   ./m42-dev.sh init --template default
   ```

4. Start development:
   ```bash
   ./m42-dev.sh start FEAT-001
   ```

### Common Tasks
- **Check Status:** `./m42-dev.sh status FEAT-001`
- **Reset Milestone:** `./m42-dev.sh reset FEAT-001 --milestone M1`
- **View Logs:** Check `.claude-workflow/milestones/M1/iterations/`
- **Resume Work:** Simply run `start` again - it resumes from last state
- **Manual Review:** Check `reviews/` directory for quality assessments

## Additional Resources
### Documentation
- **README.md:** Project overview and quick start
- **SETUP_GUIDE.md:** Detailed installation instructions
- **CONTRIBUTING.md:** Development guidelines
- **Example Features:** `examples/` directory for reference implementations

### Team Contacts
- **Project Maintainer:** Via GitHub issues
- **Community:** GitHub discussions
- **Bug Reports:** GitHub issue tracker

### Related Projects
- **Claude Code:** The AI development assistant powering m42-dev
- **Anthropic API:** For direct Claude integration
- **Similar Tools:** AI-powered development assistants and orchestrators
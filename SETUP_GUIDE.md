# Detailed Setup Guide for Claude Autonomous Development Tool

This guide provides step-by-step instructions for setting up and using the Claude Autonomous Development Tool in your projects.

## Prerequisites

Before you begin, ensure you have:

- **Claude Code** installed and configured
- **Git** version 2.0 or higher
- **Bash** shell (Linux, macOS, or WSL on Windows)
- **jq** for JSON processing: `sudo apt-get install jq` or `brew install jq`
- **yq** for YAML processing: 
  ```bash
  # Install yq (mikefarah version)
  wget https://github.com/mikefarah/yq/releases/latest/download/yq_linux_amd64 -O /usr/local/bin/yq
  chmod +x /usr/local/bin/yq
  ```

## Step 1: Installation in Your Project

### Option A: Simple Clone Method

```bash
# 1. Navigate to your project root
cd /path/to/your-project

# 2. Clone the tool
git clone https://github.com/yourusername/claude-autonomous-dev.git tools/claude-dev

# 3. Create Claude commands directory
mkdir -p .claude/commands

# 4. Create symbolic link for the command
ln -s ../../tools/claude-dev/commands/develop-feature.md .claude/commands/develop-feature.md

# 5. Verify installation
ls -la .claude/commands/develop-feature.md
# Should show: develop-feature.md -> ../../tools/claude-dev/commands/develop-feature.md
```

### Option B: Git Submodule Method (for version control)

```bash
# 1. Add as submodule
git submodule add https://github.com/yourusername/claude-autonomous-dev.git tools/claude-dev

# 2. Initialize submodule
git submodule init
git submodule update

# 3. Create symbolic link
mkdir -p .claude/commands
ln -s ../../tools/claude-dev/commands/develop-feature.md .claude/commands/develop-feature.md

# 4. Commit the changes
git add .gitmodules tools/claude-dev .claude/commands/develop-feature.md
git commit -m "Add Claude Autonomous Development Tool"
```

## Step 2: Project Configuration

### Create Project Structure

```bash
# Create specs directory for features
mkdir -p specs/features

# Create a project context file (optional but recommended)
cat > PROJECT_CONTEXT.md << 'EOF'
# Project Context

## Architecture Overview
- Describe your project's architecture
- List main technologies used
- Explain coding standards

## Development Patterns
- Design patterns used (e.g., MVC, Event Sourcing, CQRS)
- File organization structure
- Naming conventions

## Testing Strategy
- Test frameworks used
- Coverage requirements
- Test file locations
EOF
```

### Configure Tool Settings (Optional)

```bash
# Create local configuration
cat > tools/claude-dev/config.local.sh << 'EOF'
# Local configuration overrides
MAX_ITERATIONS=15  # Default is 10
PAUSE_BETWEEN_ITERATIONS=10  # Default is 5 seconds

# Project-specific paths
PROJECT_CONTEXT_FILE="PROJECT_CONTEXT.md"  # Default is project-context.md
EOF
```

## Step 3: Creating Your First Feature

### Using Claude Command (Recommended)

1. Open Claude Code in your project directory
2. Type the command:
   ```
   /develop-feature FEAT-001-user-authentication
   ```
3. Claude will create the feature structure and ask you to edit the requirements

### Using Bash Command

```bash
# Initialize a new feature
tools/claude-dev/claude-dev.sh init FEAT-001-user-authentication

# This creates:
# specs/features/FEAT-001-user-authentication/
# ├── requirements.yaml
# └── project-context.md
```

## Step 4: Defining Feature Requirements

Edit `specs/features/FEAT-001-user-authentication/requirements.yaml`:

```yaml
feature:
  id: "FEAT-001-user-authentication"
  name: "User Authentication System"
  version: "1.0.0"
  owner: "@your-team"
  target_release: "v2.0.0"
  
  description: |
    Implement a secure user authentication system with JWT tokens,
    password hashing, and session management.
  
  business_value:
    - "Secure user access to the application"
    - "Enable personalized user experiences"
    - "Compliance with security standards"

requirements:
  functional:
    - id: "FR-1"
      priority: "P0"
      description: "Users can register with email and password"
    - id: "FR-2"
      priority: "P0"
      description: "Users can login and receive JWT token"
    - id: "FR-3"
      priority: "P1"
      description: "Password reset functionality"
      
  technical:
    - "Use bcrypt for password hashing"
    - "JWT tokens with 24h expiration"
    - "Rate limiting on auth endpoints"
    
  non_functional:
    - metric: "auth_response_time"
      target: "< 200ms"
    - metric: "concurrent_sessions"
      target: "> 10000"

milestones:
  - id: "M1"
    name: "Database Schema & Models"
    description: "Create user table and data models"
    dependencies: []
    estimated_hours: 3
    
    implementation_checklist:
      database:
        "Create users table migration": "pending"
        "Add indexes for email": "pending"
        "Create sessions table": "pending"
      models:
        "Create User model": "pending"
        "Add password hashing methods": "pending"
        "Create Session model": "pending"
    
    acceptance_tests:
      - scenario: "User model creation"
        given: ["Valid user data"]
        when: ["User.create() is called"]
        then: ["User is saved with hashed password"]

  - id: "M2"
    name: "Authentication Service"
    description: "Core authentication logic"
    dependencies: ["M1"]
    estimated_hours: 4
    
    implementation_checklist:
      services:
        "Create AuthService class": "pending"
        "Implement register method": "pending"
        "Implement login method": "pending"
        "Implement token generation": "pending"
      validation:
        "Email validation": "pending"
        "Password strength validation": "pending"

  - id: "M3"
    name: "API Endpoints"
    description: "REST API for authentication"
    dependencies: ["M2"]
    estimated_hours: 3
    
    implementation_checklist:
      endpoints:
        "POST /api/auth/register": "pending"
        "POST /api/auth/login": "pending"
        "POST /api/auth/logout": "pending"
        "GET /api/auth/me": "pending"
      middleware:
        "Create auth middleware": "pending"
        "Add rate limiting": "pending"

  - id: "M4"
    name: "Testing"
    description: "Comprehensive test coverage"
    dependencies: ["M1"]  # Can start after models exist
    estimated_hours: 4
    
    implementation_checklist:
      unit_tests:
        "User model tests": "pending"
        "AuthService tests": "pending"
        "Token generation tests": "pending"
      integration_tests:
        "Registration flow test": "pending"
        "Login flow test": "pending"
        "Auth middleware test": "pending"

parallel_execution:
  max_concurrent_milestones: 2
  coordination:
    - "M1 must complete first"
    - "M2 depends on M1"
    - "M3 depends on M2"
    - "M4 can run parallel to M2 and M3"
```

## Step 5: Starting Development

### Automatic Orchestration

In Claude Code:
```
/develop-feature FEAT-001-user-authentication
```

Claude will:
1. Analyze dependencies
2. Start M1 (no dependencies)
3. When M1 completes, start M2 and M4 in parallel
4. When M2 completes, start M3
5. Continue until all milestones are complete

### Manual Control

```bash
# Start specific milestone
tools/claude-dev/claude-dev.sh start FEAT-001-user-authentication M1

# Check status
tools/claude-dev/claude-dev.sh status FEAT-001-user-authentication

# Output:
# Feature: FEAT-001-user-authentication
# Completed milestones: M1
# In progress: M2, M4
# Pending: M3
```

## Step 6: Monitoring Progress

### Real-time Monitoring

```bash
# Watch status
watch -n 5 'tools/claude-dev/claude-dev.sh status FEAT-001-user-authentication'

# Tail logs
tail -f specs/features/FEAT-001-user-authentication/.claude-workflow/logs/*.log

# Check specific milestone progress
cat specs/features/FEAT-001-user-authentication/.claude-workflow/milestones/M1/state/checklist.json | jq .
```

### Understanding State Files

```bash
# Global feature state
cat specs/features/FEAT-001/.claude-workflow/state/global.json

# Output:
{
  "feature_id": "FEAT-001-user-authentication",
  "milestones_completed": ["M1"],
  "milestones_in_progress": ["M2", "M4"],
  "milestones_pending": ["M3"],
  "start_time": "2024-01-15T10:00:00Z"
}

# Milestone checklist
cat specs/features/FEAT-001/.claude-workflow/milestones/M1/state/checklist.json

# Shows each task as pending/in_progress/completed
```

## Step 7: Handling Issues

### When a Milestone Fails

```bash
# 1. Check the review feedback
cat specs/features/FEAT-001/.claude-workflow/milestones/M2/reviews/review_5.json

# 2. See what issues were found
{
  "quality_passed": false,
  "issues": [
    "Missing error handling in login method",
    "No input validation for email"
  ]
}

# 3. Reset and retry
tools/claude-dev/claude-dev.sh reset FEAT-001-user-authentication M2
tools/claude-dev/claude-dev.sh start FEAT-001-user-authentication M2
```

### Manual Intervention

Sometimes you may need to:
1. Edit the code manually to fix specific issues
2. Update the checklist to reflect manual changes
3. Continue automated development

```bash
# Edit code manually
# ... make your changes ...

# Update checklist
vi specs/features/FEAT-001/.claude-workflow/milestones/M2/state/checklist.json
# Mark completed items as "completed"

# Continue
tools/claude-dev/claude-dev.sh start FEAT-001-user-authentication M2
```

## Step 8: Completion and Cleanup

### When Development Completes

```bash
# Final status check
tools/claude-dev/claude-dev.sh status FEAT-001-user-authentication

# All milestones should show as completed
# Review the created/modified files
```

### Create Pull Request

```bash
# Create feature branch if not already on one
git checkout -b feat/001-user-authentication

# Add all changes
git add .

# Commit with summary
git commit -m "feat: Implement user authentication system

- Database schema and models (M1)
- Authentication service with JWT (M2)  
- REST API endpoints (M3)
- Comprehensive test coverage (M4)

Developed using Claude Autonomous Development Tool"

# Push and create PR
git push origin feat/001-user-authentication
```

## Best Practices

### 1. Milestone Design
- Keep milestones small (4-8 hours)
- Clear dependencies
- Atomic and testable
- Include acceptance criteria

### 2. Checklist Items
- Be specific and measurable
- One task = one file or one method
- Include test tasks

### 3. Parallel Execution
- Identify truly independent work
- Testing can often run parallel
- Documentation can be separate

### 4. Error Recovery
- Check logs frequently
- Reset stuck milestones
- Manual intervention is OK

### 5. State Management
- Commit .claude-workflow to git for history
- Back up state before major changes
- Use reset sparingly

## Troubleshooting Checklist

- [ ] All prerequisites installed? (jq, yq, git)
- [ ] Claude command properly linked?
- [ ] Feature directory has correct structure?
- [ ] requirements.yaml has valid YAML syntax?
- [ ] Milestone dependencies form valid DAG?
- [ ] Sufficient disk space for iterations?
- [ ] Git repository initialized?
- [ ] Claude Code has file system access?

## Getting Help

1. Check logs: `specs/features/FEAT-XXX/.claude-workflow/logs/`
2. Review state files for clues
3. Reset problematic milestones
4. Open issue on GitHub
5. Check documentation for updates

---

Remember: The tool is designed to augment, not replace, human developers. Feel free to intervene, guide, and improve the generated code as needed!
#!/bin/bash
# m42-dev.sh - M42 Autonomous Development Tool
# 
# Tool für Feature-basierte autonome Entwicklung mit Claude Code CLI
# Unterstützt parallele Milestone-Entwicklung mit State Management

set -euo pipefail

# =============================================================================
# CONFIGURATION
# =============================================================================

# Tool directories
TOOL_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJECT_ROOT="$( cd "$TOOL_DIR/../.." && pwd )"
FEATURES_DIR="$PROJECT_ROOT/specs/features"

# Feature-specific variables (set by set_feature_context)
CURRENT_FEATURE=""
FEATURE_DIR=""
WORK_DIR=""
REQUIREMENTS_FILE=""
PROJECT_CONTEXT_FILE=""

# Development settings
MAX_ITERATIONS=10
PAUSE_BETWEEN_ITERATIONS=5

# Claude Code settings
CLAUDE_CMD="claude"
CLAUDE_FLAGS="--no-update-files --dangerously-skip-permissions"

# Milestone variables
CURRENT_MILESTONE=""
MILESTONE_DIR=""

# =============================================================================
# FEATURE MANAGEMENT
# =============================================================================

# Set feature context
set_feature_context() {
    local feature_id="$1"
    CURRENT_FEATURE="$feature_id"
    FEATURE_DIR="$FEATURES_DIR/$feature_id"
    WORK_DIR="$FEATURE_DIR/.claude-workflow"
    REQUIREMENTS_FILE="$FEATURE_DIR/requirements.yaml"
    PROJECT_CONTEXT_FILE="$FEATURE_DIR/project-context.md"
}

# Initialize new feature
init_feature() {
    local feature_id="${1:-}"
    
    if [[ -z "$feature_id" ]]; then
        echo "❌ Error: Feature ID required"
        echo "Usage: $0 init <feature-id>"
        echo "Example: $0 init FEAT-123-new-auth-system"
        exit 1
    fi
    
    echo "🆕 Initializing feature: $feature_id"
    
    set_feature_context "$feature_id"
    
    if [[ -d "$FEATURE_DIR" ]]; then
        echo "⚠️  Feature $feature_id already exists"
        echo "Use '$0 reset $feature_id' to start over"
        exit 1
    fi
    
    # Create feature directory
    mkdir -p "$FEATURE_DIR"
    
    # Create template files
    create_feature_templates "$feature_id"
    
    echo "✅ Feature $feature_id initialized!"
    echo ""
    echo "📝 Next steps:"
    echo "1. Edit $REQUIREMENTS_FILE"
    echo "2. Edit $PROJECT_CONTEXT_FILE"
    echo "3. Run: $0 start $feature_id M1"
}

# Create feature templates
create_feature_templates() {
    local feature_id="$1"
    
    # Requirements template
    cat > "$REQUIREMENTS_FILE" <<EOF
# ===== FEATURE OVERVIEW =====
feature:
  id: "$feature_id"
  name: "Feature Name Here"
  version: "1.0.0"
  owner: "@your-team"
  target_release: "v1.0.0"
  
  description: |
    Brief description of what this feature does.
    Why is it needed? What problem does it solve?
  
  business_value:
    - "Improves user experience by..."
    - "Reduces operational costs by..."
    - "Enables new capabilities for..."

# ===== HIGH-LEVEL REQUIREMENTS =====
requirements:
  functional:
    - id: "FR-1"
      priority: "P0"
      description: "Core functionality that MUST work"
      
    - id: "FR-2"
      priority: "P1"
      description: "Important but not critical functionality"
      
  technical:
    - "Must follow Event Sourcing pattern"
    - "CQRS for commands and queries"
    - "TypeScript with strict mode"
    - "100% test coverage for domain logic"
    
  non_functional:
    - metric: "response_time_p95"
      target: "< 200ms"
    - metric: "availability"
      target: "> 99.9%"

# ===== MILESTONES =====
milestones:
  # Milestone 1: Foundation
  - id: "M1"
    name: "Domain Model & Infrastructure"
    description: "Create domain entities, aggregates, and base infrastructure"
    dependencies: []  # No dependencies, can start immediately
    estimated_hours: 4
    
    implementation_checklist:
      domain:
        "Create [Feature]Aggregate extending AggregateRoot": "pending"
        "Define domain events (e.g., [Feature]Created, [Feature]Updated)": "pending"
        "Implement value objects for domain concepts": "pending"
        "Add domain validation rules": "pending"
        
      infrastructure:
        "Create I[Feature]Repository interface": "pending"
        "Implement PostgreSQL repository": "pending"
        "Setup event store integration": "pending"
        "Configure dependency injection": "pending"
    
    acceptance_tests:
      - scenario: "Domain model validation"
        given: ["Valid domain entity created"]
        when: ["Business rules applied"]
        then: ["State changes correctly", "Domain events emitted"]
        
      - scenario: "Repository operations"
        given: ["Domain entity exists"]
        when: ["Save and retrieve from repository"]
        then: ["Entity persisted correctly", "Events stored"]
    
    definition_of_done:
      - "All checklist items completed"
      - "Unit tests pass with >95% coverage"
      - "Domain events properly structured"
      - "Repository integration tested"

  # Milestone 2: Application Layer
  - id: "M2"
    name: "Commands, Queries & Handlers"
    description: "Implement CQRS pattern with commands and queries"
    dependencies: ["M1"]  # Needs domain model first
    estimated_hours: 3
    
    implementation_checklist:
      commands:
        "Create command DTOs (Create[Feature]Command, etc.)": "pending"
        "Implement command handlers": "pending"
        "Add command validation": "pending"
        "Wire up with event bus": "pending"
        
      queries:
        "Define query interfaces (Get[Feature]ByIdQuery, etc.)": "pending"
        "Implement query handlers": "pending"
        "Create read models/projections": "pending"
        "Add query result DTOs": "pending"
        
      services:
        "Create application service interfaces": "pending"
        "Implement business orchestration": "pending"
        "Add transaction management": "pending"
    
    acceptance_tests:
      - scenario: "Command execution"
        given: ["Valid command submitted"]
        when: ["Command handler processes"]
        then: ["Aggregate updated", "Events published", "Success result"]
        
      - scenario: "Query execution"
        given: ["Data exists in read model"]
        when: ["Query executed"]
        then: ["Correct data returned", "Performance within SLA"]

  # Milestone 3: API Layer
  - id: "M3"
    name: "REST API & Integration"
    description: "Expose functionality through REST endpoints"
    dependencies: ["M2"]  # Needs application layer
    estimated_hours: 3
    
    implementation_checklist:
      api:
        "Create REST controllers": "pending"
        "Define API routes": "pending"
        "Add request/response DTOs": "pending"
        "Implement error handling": "pending"
        
      integration:
        "Add OpenAPI documentation": "pending"
        "Configure authentication/authorization": "pending"
        "Setup request validation": "pending"
        "Add rate limiting": "pending"
        
      middleware:
        "Create logging middleware": "pending"
        "Add correlation ID tracking": "pending"
        "Implement error transformation": "pending"

  # Milestone 4: Testing & Quality (can run parallel to M3)
  - id: "M4"
    name: "Comprehensive Testing"
    description: "Unit, integration, and E2E tests"
    dependencies: ["M2"]  # Can start after application layer
    estimated_hours: 4
    
    implementation_checklist:
      unit_tests:
        "Domain model tests": "pending"
        "Command handler tests": "pending"
        "Query handler tests": "pending"
        "Service tests": "pending"
        
      integration_tests:
        "Repository integration tests": "pending"
        "Event store integration tests": "pending"
        "API endpoint tests": "pending"
        "Database transaction tests": "pending"
        
      e2e_tests:
        "Complete user journey tests": "pending"
        "Performance tests": "pending"
        "Error scenario tests": "pending"

# ===== PARALLEL EXECUTION STRATEGY =====
parallel_execution:
  max_concurrent_milestones: 2
  coordination:
    - "M1 must complete before M2, M3, M4"
    - "M2 must complete before M3"
    - "M4 can run parallel to M3"
  
  suggested_assignment:
    - agent_1: ["M1", "M2", "M3"]  # Main development path
    - agent_2: ["M4"]              # Testing in parallel

# ===== GLOBAL DEFINITION OF DONE =====
global_definition_of_done:
  - "All milestones completed"
  - "All tests passing"
  - "Code review passed"
  - "Documentation complete"
  - "Performance benchmarks met"
  - "Security scan passed"
EOF

    # Project context template
    cat > "$PROJECT_CONTEXT_FILE" <<'EOF'
# Project Context

## m42-core Architecture Overview
This feature is part of the m42-core platform and must follow these architectural principles:

### Core Patterns
1. **Event Sourcing**: All state changes through events
2. **CQRS**: Separate command and query models
3. **Domain-Driven Design**: Rich domain models with business logic
4. **Hexagonal Architecture**: Clear separation of concerns

### Technical Stack
- TypeScript with strict mode
- Node.js 20+
- PostgreSQL for persistence
- Prisma ORM for data access
- Jest for testing
- Express/Fastify for HTTP layer

### Code Organization
```
src/
  core/
    domain/
      [feature]/
        aggregates/     # Domain aggregates
        events/         # Domain events
        value-objects/  # Value objects
        repositories/   # Repository interfaces
    application/
      [feature]/
        commands/       # Command DTOs and handlers
        queries/        # Query DTOs and handlers
        services/       # Application services
    infrastructure/
      persistence/      # Repository implementations
      http/            # REST controllers
```

## Feature-Specific Context
[Add any feature-specific requirements, constraints, or integration points here]

## Integration Points
- Which existing modules does this feature interact with?
- What events does it publish/consume?
- External service dependencies?

## Non-Functional Requirements
- Performance targets
- Security considerations
- Scalability requirements
- Monitoring and observability needs
EOF

    echo "📄 Created template files:"
    echo "  - $REQUIREMENTS_FILE"
    echo "  - $PROJECT_CONTEXT_FILE"
}

# List all features
list_features() {
    echo "📋 Available features:"
    echo ""
    
    if [[ ! -d "$FEATURES_DIR" ]] || [[ -z "$(ls -A "$FEATURES_DIR" 2>/dev/null)" ]]; then
        echo "  No features found."
        echo "  Create one with: $0 init <feature-id>"
        return
    fi
    
    for feature_dir in "$FEATURES_DIR"/*/; do
        if [[ -d "$feature_dir" ]]; then
            local feature_id=$(basename "$feature_dir")
            local status="📄 not started"
            local milestones_info=""
            
            if [[ -f "$feature_dir/.claude-workflow/state/global.json" ]]; then
                local completed=$(jq -r '.milestones_completed | length' "$feature_dir/.claude-workflow/state/global.json" 2>/dev/null || echo "0")
                local in_progress=$(jq -r '.milestones_in_progress | length' "$feature_dir/.claude-workflow/state/global.json" 2>/dev/null || echo "0")
                
                if [[ "$completed" -gt 0 ]] || [[ "$in_progress" -gt 0 ]]; then
                    status="🚀 active"
                    milestones_info=" ($completed completed, $in_progress in progress)"
                fi
            fi
            
            echo "  $feature_id - $status$milestones_info"
        fi
    done
}

# =============================================================================
# WORKSPACE MANAGEMENT
# =============================================================================

setup_workspace() {
    local milestone="${1:-}"
    
    if [[ -z "$CURRENT_FEATURE" ]]; then
        echo "❌ Error: No feature context set"
        exit 1
    fi
    
    if [[ -z "$milestone" ]]; then
        echo "🔧 Setting up workspace for feature $CURRENT_FEATURE..."
        
        # Create general directories
        mkdir -p "$WORK_DIR"/{milestones,state,logs}
        
        # Check for requirements
        if [[ ! -f "$REQUIREMENTS_FILE" ]]; then
            echo "❌ Requirements not found for $CURRENT_FEATURE"
            echo "Run: $0 init $CURRENT_FEATURE"
            exit 1
        fi
        
        # Initialize global state
        if [[ ! -f "$WORK_DIR/state/global.json" ]]; then
            cat > "$WORK_DIR/state/global.json" <<EOF
{
    "feature_id": "$CURRENT_FEATURE",
    "milestones_completed": [],
    "milestones_in_progress": [],
    "global_patterns": {},
    "start_time": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
}
EOF
        fi
        
        echo "✅ Workspace ready!"
    else
        echo "🔧 Setting up milestone $milestone for $CURRENT_FEATURE..."
        
        MILESTONE_DIR="$WORK_DIR/milestones/$milestone"
        mkdir -p "$MILESTONE_DIR"/{iterations,reviews,state,context}
        
        # Initialize milestone checklist
        initialize_milestone_checklist "$milestone"
        
        # Initialize milestone context
        cat > "$MILESTONE_DIR/context/accumulated.json" <<EOF
{
    "milestone_id": "$milestone",
    "completed_files": [],
    "implemented_features": [],
    "established_patterns": {},
    "dependencies_added": []
}
EOF
        
        echo "✅ Milestone $milestone ready!"
    fi
}

# Initialize milestone checklist from requirements
initialize_milestone_checklist() {
    local milestone="$1"
    local milestone_dir="$WORK_DIR/milestones/$milestone"
    
    echo "📋 Extracting checklist for milestone $milestone..."
    
    if command -v yq &> /dev/null; then
        yq eval ".milestones[] | select(.id == \"$milestone\") | .implementation_checklist" "$REQUIREMENTS_FILE" \
            > "$milestone_dir/state/checklist.json" 2>/dev/null
        
        if [[ ! -s "$milestone_dir/state/checklist.json" ]]; then
            echo "⚠️  No checklist found for milestone $milestone"
            echo '{"tasks": {"Initialize": "pending"}}' > "$milestone_dir/state/checklist.json"
        fi
    else
        echo "⚠️  yq not found. Using default checklist."
        echo '{"tasks": {"Initialize": "pending"}}' > "$milestone_dir/state/checklist.json"
    fi
    
    # Initialize milestone state
    cat > "$milestone_dir/state/current.json" <<EOF
{
    "milestone_id": "$milestone",
    "current_iteration": 0,
    "phase": "not_started",
    "quality_passed": false,
    "start_time": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
}
EOF
}

# =============================================================================
# DEVELOPMENT WORKFLOW
# =============================================================================

run_milestone_development() {
    local milestone="$1"
    CURRENT_MILESTONE="$milestone"
    MILESTONE_DIR="$WORK_DIR/milestones/$milestone"
    
    # Check dependencies
    if ! check_milestone_dependencies "$milestone"; then
        echo "❌ Dependencies not met for milestone $milestone"
        echo "Complete required milestones first."
        exit 1
    fi
    
    # Update global state
    update_global_state_milestone_start "$milestone"
    
    local iteration=1
    local quality_passed=false
    
    echo "🤖 Starting development for $CURRENT_FEATURE - Milestone $milestone"
    echo "Max iterations: $MAX_ITERATIONS"
    echo ""
    
    show_milestone_info "$milestone"
    echo ""
    
    while [[ $iteration -le $MAX_ITERATIONS ]] && [[ "$quality_passed" == "false" ]]; do
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        echo "🔄 ITERATION $iteration"
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        
        # Development phase
        echo "👨‍💻 Phase 1: Development"
        run_development_phase $iteration
        
        # Commit changes
        echo "📝 Committing changes..."
        commit_changes $iteration
        
        # Review phase
        echo "🔍 Phase 2: Code Review"
        local review_result=$(run_review_phase $iteration)
        
        # Check quality gates
        if [[ $(echo "$review_result" | jq -r '.quality_passed') == "true" ]]; then
            quality_passed=true
            echo "✅ Quality gates PASSED!"
        else
            echo "❌ Quality gates failed. Issues found:"
            echo "$review_result" | jq -r '.issues[]' | sed 's/^/   - /'
            prepare_feedback_context "$review_result" $iteration
        fi
        
        # Update state
        update_milestone_state $iteration "$quality_passed" "$review_result"
        
        ((iteration++))
        
        if [[ "$quality_passed" == "false" ]] && [[ $iteration -le $MAX_ITERATIONS ]]; then
            echo "⏳ Waiting $PAUSE_BETWEEN_ITERATIONS seconds..."
            sleep $PAUSE_BETWEEN_ITERATIONS
        fi
    done
    
    # Final summary
    final_milestone_summary "$milestone" "$quality_passed" $((iteration-1))
}

# Run development phase
run_development_phase() {
    local iteration=$1
    local output_file="$MILESTONE_DIR/iterations/dev_${iteration}.md"
    
    # Create development context
    local dev_context=$(create_development_context $iteration)
    
    # Save context for debugging
    echo "$dev_context" > "$MILESTONE_DIR/iterations/context_${iteration}.md"
    
    # Execute Claude
    echo "Running Claude Code..."
    $CLAUDE_CMD $CLAUDE_FLAGS \
        --prompt "$dev_context" \
        > "$output_file" 2>&1 || true
    
    echo "Development output saved to: $output_file"
    
    # Update checklist based on output
    update_checklist_from_output $iteration
    
    # Accumulate context
    accumulate_context $iteration
}

# Create development context
create_development_context() {
    local iteration=$1
    
    # Get milestone info
    local milestone_info=$(get_milestone_info "$CURRENT_MILESTONE")
    
    # Build context
    cat <<EOF
You are implementing $CURRENT_FEATURE - Milestone $CURRENT_MILESTONE.

=== PROJECT CONTEXT ===
$(cat "$PROJECT_CONTEXT_FILE")

=== MILESTONE INFORMATION ===
$milestone_info

=== IMPLEMENTATION CHECKLIST ===
Current status of tasks:

$(show_milestone_checklist_status)

Focus on items marked as 'pending' or 'in_progress'.

=== ACCUMULATED CONTEXT ===
Previous iterations completed:
$(cat "$MILESTONE_DIR/context/accumulated.json" | jq -r '
    "Files: " + (.completed_files | join(", ")) + "\n" +
    "Features: " + (.implemented_features | join(", "))
')

=== INSTRUCTIONS ===
1. Work through the checklist systematically
2. Follow m42-core architecture patterns
3. Use Event Sourcing and CQRS
4. Include comprehensive error handling
5. Write clean, maintainable code

Start implementing now:
EOF

    # Add feedback if not first iteration
    if [[ $iteration -gt 1 ]]; then
        local feedback_file="$MILESTONE_DIR/reviews/feedback_$((iteration-1)).json"
        if [[ -f "$feedback_file" ]]; then
            echo ""
            echo "=== PREVIOUS REVIEW FEEDBACK ==="
            echo "Fix these issues from the last review:"
            jq -r '.issues[]' "$feedback_file" | sed 's/^/- /'
        fi
    fi
}

# Run review phase
run_review_phase() {
    local iteration=$1
    local review_output="$MILESTONE_DIR/reviews/review_${iteration}.json"
    
    # Get commit info
    local commit_info=$(git log -1 --pretty=format:"%H|%s" 2>/dev/null || echo "no-git|Manual review")
    local commit_diff=$(git diff HEAD~1 HEAD 2>/dev/null || echo "No git diff available")
    
    # Create review context
    local review_context=$(create_review_context "$commit_info" "$commit_diff")
    
    # Execute review
    echo "Running Claude Code for review..."
    local review_result=$($CLAUDE_CMD $CLAUDE_FLAGS \
        --prompt "$review_context" \
        2>/dev/null || echo '{"quality_passed": false, "issues": ["Review failed"]}')
    
    # Parse and save result
    echo "$review_result" | jq '.' > "$review_output" 2>/dev/null || \
        echo '{"quality_passed": false, "issues": ["Review parsing failed"]}' > "$review_output"
    
    cat "$review_output"
}

# Create review context
create_review_context() {
    local commit_info=$1
    local commit_diff=$2
    
    cat <<EOF
Review the implementation for $CURRENT_FEATURE - Milestone $CURRENT_MILESTONE.

=== PROJECT CONTEXT ===
$(cat "$PROJECT_CONTEXT_FILE")

=== MILESTONE REQUIREMENTS ===
$(get_milestone_info "$CURRENT_MILESTONE")

=== CHECKLIST STATUS ===
Verify these items are actually implemented:
$(show_milestone_checklist_status)

=== CHANGES TO REVIEW ===
Commit: $commit_info

$commit_diff

=== REVIEW CRITERIA ===
1. All checklist items marked complete are actually implemented
2. Code follows m42-core patterns (Event Sourcing, CQRS, DDD)
3. Proper error handling and validation
4. Tests included where appropriate
5. No hardcoded values or secrets
6. Clean, maintainable code

Respond with JSON:
{
  "quality_passed": true/false,
  "score": 0-100,
  "issues": ["Issue 1", "Issue 2"],
  "positive_aspects": ["Good thing 1"],
  "recommendations": ["Suggestion 1"]
}
EOF
}

# =============================================================================
# HELPER FUNCTIONS
# =============================================================================

# Get milestone info from requirements
get_milestone_info() {
    local milestone=$1
    
    if command -v yq &> /dev/null; then
        yq eval ".milestones[] | select(.id == \"$milestone\")" "$REQUIREMENTS_FILE" 2>/dev/null
    else
        echo "Milestone: $milestone"
    fi
}

# Check milestone dependencies
check_milestone_dependencies() {
    local milestone=$1
    
    if command -v yq &> /dev/null; then
        local deps=$(yq eval ".milestones[] | select(.id == \"$milestone\") | .dependencies[]" "$REQUIREMENTS_FILE" 2>/dev/null)
        
        if [[ -z "$deps" ]]; then
            return 0  # No dependencies
        fi
        
        # Check each dependency
        local global_state="$WORK_DIR/state/global.json"
        for dep in $deps; do
            if ! jq -e ".milestones_completed | contains([\"$dep\"])" "$global_state" >/dev/null 2>&1; then
                echo "⚠️  Dependency $dep not completed"
                return 1
            fi
        done
    fi
    
    return 0
}

# Show milestone info
show_milestone_info() {
    local milestone=$1
    
    echo "📌 Milestone: $milestone"
    if command -v yq &> /dev/null; then
        echo "Name: $(yq eval ".milestones[] | select(.id == \"$milestone\") | .name" "$REQUIREMENTS_FILE")"
        echo "Description: $(yq eval ".milestones[] | select(.id == \"$milestone\") | .description" "$REQUIREMENTS_FILE")"
        echo "Dependencies: $(yq eval ".milestones[] | select(.id == \"$milestone\") | .dependencies | join(\", \")" "$REQUIREMENTS_FILE")"
    fi
}

# Show milestone checklist status
show_milestone_checklist_status() {
    local checklist="$MILESTONE_DIR/state/checklist.json"
    
    if [[ -f "$checklist" ]]; then
        jq -r 'to_entries | .[] | "[\(.key)]" as $cat | .value | to_entries | .[] | "\($cat) \(.key): \(.value)"' "$checklist" | \
        while read line; do
            if [[ "$line" =~ "completed" ]]; then
                echo "✅ $line"
            elif [[ "$line" =~ "in_progress" ]]; then
                echo "🔄 $line"
            else
                echo "⬜ $line"
            fi
        done
    else
        echo "No checklist found"
    fi
}

# Update checklist from output
update_checklist_from_output() {
    local iteration=$1
    local output_file="$MILESTONE_DIR/iterations/dev_${iteration}.md"
    
    echo "📋 Updating checklist..."
    
    # This is a simplified version - in reality, Claude would update this
    # For now, just track that we attempted the iteration
    local checklist="$MILESTONE_DIR/state/checklist.json"
    
    # Mark first pending item as in_progress (simulation)
    # In real usage, Claude's output would drive these updates
}

# Accumulate context
accumulate_context() {
    local iteration=$1
    local context_file="$MILESTONE_DIR/context/accumulated.json"
    
    # In real usage, this would parse Claude's output
    # For now, just track the iteration
    jq --arg iter "$iteration" \
        '.last_iteration = $iter' \
        "$context_file" > "$context_file.tmp" && \
        mv "$context_file.tmp" "$context_file"
}

# Update milestone state
update_milestone_state() {
    local iteration=$1
    local quality_passed=$2
    local review_result=$3
    
    cat > "$MILESTONE_DIR/state/current.json" <<EOF
{
    "milestone_id": "$CURRENT_MILESTONE",
    "current_iteration": $iteration,
    "phase": "$([ "$quality_passed" == "true" ] && echo "completed" || echo "in_progress")",
    "quality_passed": $quality_passed,
    "last_review": $review_result,
    "last_update": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
}
EOF
}

# Update global state - milestone start
update_global_state_milestone_start() {
    local milestone=$1
    local global_state="$WORK_DIR/state/global.json"
    
    jq --arg ms "$milestone" \
        '.milestones_in_progress += [$ms] | .milestones_in_progress |= unique' \
        "$global_state" > "$global_state.tmp" && \
        mv "$global_state.tmp" "$global_state"
}

# Update global state - milestone complete
update_global_state_milestone_complete() {
    local milestone=$1
    local global_state="$WORK_DIR/state/global.json"
    
    jq --arg ms "$milestone" \
        '.milestones_completed += [$ms] | 
         .milestones_in_progress -= [$ms] | 
         .milestones_completed |= unique' \
        "$global_state" > "$global_state.tmp" && \
        mv "$global_state.tmp" "$global_state"
}

# Commit changes
commit_changes() {
    local iteration=$1
    
    # Check if git repo exists
    if ! git rev-parse --git-dir > /dev/null 2>&1; then
        echo "⚠️  Not in a git repository, skipping commit"
        return
    fi
    
    # Stage changes
    git add -A
    
    # Check for changes
    if git diff --cached --quiet; then
        echo "No changes to commit"
        return
    fi
    
    # Create commit
    local checklist_progress=$(show_milestone_checklist_status | grep "✅" | head -3 | sed 's/✅ /- /')
    
    git commit -m "feat($CURRENT_FEATURE): Milestone $CURRENT_MILESTONE - Iteration $iteration" \
        -m "Automated development by Claude Autonomous Development System" \
        -m "" \
        -m "Progress:" \
        -m "$checklist_progress" \
        || echo "Commit failed"
}

# Prepare feedback context
prepare_feedback_context() {
    local review_result=$1
    local iteration=$2
    
    echo "$review_result" > "$MILESTONE_DIR/reviews/feedback_${iteration}.json"
}

# Final milestone summary
final_milestone_summary() {
    local milestone=$1
    local quality_passed=$2
    local total_iterations=$3
    
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "📊 MILESTONE SUMMARY"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "Feature: $CURRENT_FEATURE"
    echo "Milestone: $milestone"
    
    if [[ "$quality_passed" == "true" ]]; then
        echo "Status: ✅ COMPLETED"
        echo "Iterations: $total_iterations"
        
        # Update global state
        update_global_state_milestone_complete "$milestone"
        
        echo ""
        echo "📋 Final checklist:"
        show_milestone_checklist_status | head -10
        
        echo ""
        echo "🎉 Milestone $milestone completed successfully!"
        
        # Suggest next milestone
        if command -v yq &> /dev/null; then
            local next_milestones=$(yq eval ".milestones[] | select(.dependencies | contains([\"$milestone\"])) | .id" "$REQUIREMENTS_FILE" 2>/dev/null)
            if [[ -n "$next_milestones" ]]; then
                echo ""
                echo "📌 Next available milestones:"
                echo "$next_milestones" | sed 's/^/   - /'
            fi
        fi
    else
        echo "Status: ❌ INCOMPLETE"
        echo "Iterations used: $total_iterations (max reached)"
        echo ""
        echo "Manual intervention required to complete this milestone."
        echo "Review the feedback and continue with:"
        echo "  $0 start $CURRENT_FEATURE $milestone"
    fi
}

# Show status
show_status() {
    local feature_id="${1:-}"
    local milestone="${2:-}"
    
    if [[ -z "$feature_id" ]]; then
        # Show all features
        list_features
        return
    fi
    
    set_feature_context "$feature_id"
    
    if [[ ! -d "$FEATURE_DIR" ]]; then
        echo "❌ Feature $feature_id not found"
        exit 1
    fi
    
    echo "📊 Status for $feature_id"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    
    # Global status
    if [[ -f "$WORK_DIR/state/global.json" ]]; then
        local global_state=$(cat "$WORK_DIR/state/global.json")
        echo "Completed milestones: $(echo "$global_state" | jq -r '.milestones_completed | join(", ")')"
        echo "In progress: $(echo "$global_state" | jq -r '.milestones_in_progress | join(", ")')"
        echo ""
    fi
    
    # Milestone-specific status
    if [[ -n "$milestone" ]]; then
        local milestone_dir="$WORK_DIR/milestones/$milestone"
        
        if [[ ! -d "$milestone_dir" ]]; then
            echo "Milestone $milestone not started"
            return
        fi
        
        echo "Milestone $milestone status:"
        
        if [[ -f "$milestone_dir/state/current.json" ]]; then
            local state=$(cat "$milestone_dir/state/current.json")
            echo "Phase: $(echo "$state" | jq -r '.phase')"
            echo "Iteration: $(echo "$state" | jq -r '.current_iteration')"
            echo "Quality passed: $(echo "$state" | jq -r '.quality_passed')"
        fi
        
        echo ""
        echo "Checklist progress:"
        if [[ -f "$milestone_dir/state/checklist.json" ]]; then
            local total=$(jq -r '[.. | select(type=="string")] | length' "$milestone_dir/state/checklist.json")
            local completed=$(jq -r '[.. | select(type=="string" and . == "completed")] | length' "$milestone_dir/state/checklist.json")
            echo "Progress: $completed/$total ($(( completed * 100 / total ))%)"
        fi
    else
        # Show all milestones status
        echo "Milestones overview:"
        if command -v yq &> /dev/null && [[ -f "$REQUIREMENTS_FILE" ]]; then
            yq eval '.milestones[].id' "$REQUIREMENTS_FILE" | while read -r ms; do
                local status="⬜ not started"
                
                if jq -e ".milestones_completed | contains([\"$ms\"])" "$WORK_DIR/state/global.json" >/dev/null 2>&1; then
                    status="✅ completed"
                elif jq -e ".milestones_in_progress | contains([\"$ms\"])" "$WORK_DIR/state/global.json" >/dev/null 2>&1; then
                    status="🔄 in progress"
                fi
                
                echo "  $ms - $status"
            done
        fi
    fi
}

# =============================================================================
# MAIN COMMAND HANDLER
# =============================================================================

main() {
    local command="${1:-}"
    
    case "$command" in
        "init")
            init_feature "${2:-}"
            ;;
            
        "list")
            list_features
            ;;
            
        "start")
            local feature_id="${2:-}"
            local milestone="${3:-}"
            
            if [[ -z "$feature_id" ]] || [[ -z "$milestone" ]]; then
                echo "❌ Error: Feature ID and milestone required"
                echo "Usage: $0 start <feature-id> <milestone>"
                echo "Example: $0 start FEAT-123 M1"
                exit 1
            fi
            
            set_feature_context "$feature_id"
            setup_workspace
            setup_workspace "$milestone"
            run_milestone_development "$milestone"
            ;;
            
        "status")
            show_status "${2:-}" "${3:-}"
            ;;
            
        "milestones")
            local feature_id="${2:-}"
            
            if [[ -z "$feature_id" ]]; then
                echo "❌ Error: Feature ID required"
                echo "Usage: $0 milestones <feature-id>"
                exit 1
            fi
            
            set_feature_context "$feature_id"
            
            if [[ ! -f "$REQUIREMENTS_FILE" ]]; then
                echo "❌ Feature $feature_id not found"
                exit 1
            fi
            
            echo "📋 Milestones for $feature_id:"
            if command -v yq &> /dev/null; then
                yq eval '.milestones[] | "  " + .id + " - " + .name + " (deps: " + (.dependencies | join(", ")) + ")"' "$REQUIREMENTS_FILE"
            else
                echo "  Install yq to see milestone details"
            fi
            ;;
            
        "reset")
            local feature_id="${2:-}"
            local milestone="${3:-}"
            
            if [[ -z "$feature_id" ]]; then
                echo "❌ Error: Feature ID required"
                echo "Usage: $0 reset <feature-id> [milestone]"
                exit 1
            fi
            
            set_feature_context "$feature_id"
            
            if [[ -n "$milestone" ]]; then
                echo "🔄 Resetting milestone $milestone for $feature_id..."
                rm -rf "$WORK_DIR/milestones/$milestone"
                
                # Update global state
                local global_state="$WORK_DIR/state/global.json"
                jq --arg ms "$milestone" \
                    '.milestones_in_progress -= [$ms] | .milestones_completed -= [$ms]' \
                    "$global_state" > "$global_state.tmp" && \
                    mv "$global_state.tmp" "$global_state"
            else
                echo "🔄 Resetting entire feature $feature_id..."
                read -p "Are you sure? This will delete all progress! (y/N) " -n 1 -r
                echo
                if [[ $REPLY =~ ^[Yy]$ ]]; then
                    rm -rf "$FEATURE_DIR"
                    echo "✅ Feature reset complete"
                else
                    echo "❌ Reset cancelled"
                fi
            fi
            ;;
            
        *)
            echo "🤖 Claude Autonomous Development Tool"
            echo ""
            echo "Usage: $0 <command> [options]"
            echo ""
            echo "Feature Management:"
            echo "  init <feature-id>              - Initialize new feature"
            echo "  list                           - List all features"
            echo ""
            echo "Development:"
            echo "  start <feature-id> <milestone> - Start milestone development"
            echo "  status [feature-id] [milestone] - Show status"
            echo "  milestones <feature-id>        - List milestones for feature"
            echo ""
            echo "Utilities:"
            echo "  reset <feature-id> [milestone] - Reset feature or milestone"
            echo ""
            echo "Examples:"
            echo "  $0 init FEAT-123-auth         - Create new feature"
            echo "  $0 start FEAT-123-auth M1     - Start first milestone"
            echo "  $0 status FEAT-123-auth       - Check progress"
            echo "  $0 start FEAT-123-auth M4     - Start M4 (if parallel)"
            exit 1
            ;;
    esac
}

# Run main
main "$@"
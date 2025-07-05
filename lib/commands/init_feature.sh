#!/bin/bash
# Feature initialization commands

# Source dependencies
source "$M42_LIB_DIR/utils/logging.sh"
source "$M42_LIB_DIR/core/context.sh"

# Initialize new feature
init_feature() {
    local feature_id="${1:-}"
    
    if [[ -z "$feature_id" ]]; then
        log_error "Error: Feature ID required"
        echo "Usage: m42-dev init <feature-id>"
        echo "Example: m42-dev init FEAT-123-new-auth-system"
        return 1
    fi
    
    # Validate feature ID format
    if [[ ! "$feature_id" =~ ^[A-Za-z0-9_-]+$ ]]; then
        log_error "Invalid feature ID. Use only letters, numbers, hyphens, and underscores."
        return 1
    fi
    
    # Set context
    set_feature_context "$feature_id"
    
    # Check if feature already exists
    if [[ -d "$FEATURE_DIR" ]]; then
        log_error "Feature $feature_id already exists!"
        return 1
    fi
    
    log_info "${EMOJI_NEW} Initializing feature: $feature_id"
    
    # Create feature directory
    mkdir -p "$FEATURE_DIR"
    
    # Setup workspace
    setup_workspace "$feature_id"
    
    # Create templates
    create_feature_templates "$feature_id"
    
    log_success "Feature $feature_id initialized!"
    echo ""
    log_info "Next steps:"
    echo "1. Edit $REQUIREMENTS_FILE"
    echo "2. Edit $PROJECT_CONTEXT_FILE"
    echo "3. Run: m42-dev start $feature_id M1"
}

# Setup workspace structure
setup_workspace() {
    local feature_id="$1"
    
    # Create workflow directories
    mkdir -p "$WORK_DIR"/{milestones,state,logs}
    
    # Initialize global state
    cat > "$WORK_DIR/state/global.json" <<EOF
{
  "feature_id": "$feature_id",
  "milestones_completed": [],
  "milestones_in_progress": [],
  "global_patterns": {},
  "start_time": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
}
EOF
}

# Create feature templates
create_feature_templates() {
    local feature_id="$1"
    
    # Check if templates exist
    local req_template="$M42_TEMPLATES_DIR/feature/requirements.yaml"
    local ctx_template="$M42_TEMPLATES_DIR/feature/feature-context.md"
    
    if [[ ! -f "$req_template" ]]; then
        log_error "Template not found: $req_template"
        echo "Please ensure templates directory is properly set up"
        return 1
    fi
    
    if [[ ! -f "$ctx_template" ]]; then
        log_error "Template not found: $ctx_template"
        echo "Please ensure templates directory is properly set up"
        return 1
    fi
    
    # Copy and process requirements template
    sed "s/{{FEATURE_ID}}/$feature_id/g" "$req_template" > "$REQUIREMENTS_FILE"
    
    # Copy feature context template
    cp "$ctx_template" "$PROJECT_CONTEXT_FILE"
    
    log_info "${EMOJI_FILE} Created template files:"
    echo "  - $REQUIREMENTS_FILE"
    echo "  - $PROJECT_CONTEXT_FILE"
}
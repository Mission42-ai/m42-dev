#!/bin/bash
# Start milestone command

# Source dependencies
source "$M42_LIB_DIR/utils/logging.sh"
source "$M42_LIB_DIR/core/context.sh"
source "$M42_LIB_DIR/milestone/development.sh"

# Start milestone development
start_milestone() {
    local feature_id="${1:-}"
    local milestone="${2:-}"
    
    if [[ -z "$feature_id" ]] || [[ -z "$milestone" ]]; then
        log_error "Error: Feature ID and milestone required"
        echo "Usage: m42-dev start <feature-id> <milestone>"
        echo "Example: m42-dev start FEAT-123 M1"
        return 1
    fi
    
    set_feature_context "$feature_id"
    
    if [[ ! -f "$REQUIREMENTS_FILE" ]]; then
        log_error "Feature $feature_id not found"
        return 1
    fi
    
    log_info "${EMOJI_ROCKET} Starting $CURRENT_FEATURE - Milestone $milestone"
    
    # Check if milestone already exists
    if [[ -d "$WORK_DIR/milestones/$milestone" ]]; then
        log_warning "Milestone $milestone already started!"
        echo "Use 'm42-dev recover $feature_id $milestone' to continue"
        return 1
    fi
    
    # Run milestone development
    run_milestone_development "$milestone"
}
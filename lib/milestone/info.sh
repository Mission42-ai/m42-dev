#!/bin/bash
# Milestone information utilities

# Get milestone info from requirements
get_milestone_info() {
    local milestone=$1
    
    if command -v yq &> /dev/null; then
        yq eval ".milestones[] | select(.id == \"$milestone\")" "$REQUIREMENTS_FILE" 2>/dev/null
    else
        echo "Milestone: $milestone"
    fi
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
                log_warning "Dependency $dep not completed"
                return 1
            fi
        done
    fi
    
    return 0
}

# List milestones for a feature
list_milestones() {
    local feature_id="${1:-}"
    
    if [[ -z "$feature_id" ]]; then
        log_error "Error: Feature ID required"
        echo "Usage: m42-dev milestones <feature-id>"
        return 1
    fi
    
    set_feature_context "$feature_id"
    
    if [[ ! -f "$REQUIREMENTS_FILE" ]]; then
        log_error "Feature $feature_id not found"
        return 1
    fi
    
    log_info "Milestones for $feature_id:"
    if command -v yq &> /dev/null; then
        yq eval '.milestones[] | "  " + .id + " - " + .name + " (deps: " + (.dependencies | join(", ")) + ")"' "$REQUIREMENTS_FILE"
    else
        echo "  Install yq to see milestone details"
    fi
}
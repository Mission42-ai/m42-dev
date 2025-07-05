#!/bin/bash
# Milestone state management

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
    
    log_info "Committing changes for iteration $iteration..."
    
    # Check if there are changes to commit
    if [[ -z $(git status --porcelain 2>/dev/null) ]]; then
        log_warning "No changes to commit"
        return
    fi
    
    # Add all changes
    git add -A
    
    # Create commit message
    local commit_msg="feat($CURRENT_FEATURE): Milestone $CURRENT_MILESTONE - Iteration $iteration

Automated development iteration by m42-dev

Feature: $CURRENT_FEATURE
Milestone: $CURRENT_MILESTONE
Iteration: $iteration"
    
    # Commit
    git commit -m "$commit_msg" || {
        log_error "Failed to commit changes"
        return 1
    }
    
    log_success "Changes committed successfully"
}
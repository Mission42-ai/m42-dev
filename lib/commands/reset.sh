#!/bin/bash
# Reset commands

# Source dependencies
source "$M42_LIB_DIR/utils/logging.sh"
source "$M42_LIB_DIR/core/context.sh"

# Reset feature or milestone
reset_feature() {
    local feature_id="${1:-}"
    local milestone="${2:-}"
    
    if [[ -z "$feature_id" ]]; then
        log_error "Error: Feature ID required"
        echo "Usage: m42-dev reset <feature-id> [milestone]"
        return 1
    fi
    
    set_feature_context "$feature_id"
    
    if [[ -n "$milestone" ]]; then
        log_info "🔄 Resetting milestone $milestone for $feature_id..."
        rm -rf "$WORK_DIR/milestones/$milestone"
        
        # Update global state
        local global_state="$WORK_DIR/state/global.json"
        jq --arg ms "$milestone" \
            '.milestones_in_progress -= [$ms] | .milestones_completed -= [$ms]' \
            "$global_state" > "$global_state.tmp" && \
            mv "$global_state.tmp" "$global_state"
    else
        log_info "🔄 Resetting entire feature $feature_id..."
        read -p "Are you sure? This will delete all progress! (y/N) " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            rm -rf "$FEATURE_DIR"
            log_success "Feature reset complete"
        else
            log_error "Reset cancelled"
        fi
    fi
}
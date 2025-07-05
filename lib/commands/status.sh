#!/bin/bash
# Status command

# Source dependencies
source "$M42_LIB_DIR/utils/logging.sh"
source "$M42_LIB_DIR/core/context.sh"
source "$M42_LIB_DIR/milestone/info.sh"
source "$M42_LIB_DIR/milestone/checklist.sh"

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
        log_error "Feature $feature_id not found"
        return 1
    fi
    
    echo "${EMOJI_INFO} Status for $feature_id"
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
        show_milestone_status "$milestone"
    else
        show_all_milestones_status
    fi
}

# Show specific milestone status
show_milestone_status() {
    local milestone="$1"
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
}

# Show all milestones status
show_all_milestones_status() {
    echo "Milestones overview:"
    if command -v yq &> /dev/null && [[ -f "$REQUIREMENTS_FILE" ]]; then
        yq eval '.milestones[].id' "$REQUIREMENTS_FILE" | while read -r ms; do
            local status="⬜ not started"
            
            if jq -e ".milestones_completed | contains([\"$ms\"])" "$WORK_DIR/state/global.json" >/dev/null 2>&1; then
                status="${EMOJI_SUCCESS} completed"
            elif jq -e ".milestones_in_progress | contains([\"$ms\"])" "$WORK_DIR/state/global.json" >/dev/null 2>&1; then
                status="🔄 in progress"
            fi
            
            echo "  $ms - $status"
        done
    fi
}
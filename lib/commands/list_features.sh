#!/bin/bash
# List features command

# Source dependencies
source "$M42_LIB_DIR/utils/logging.sh"
source "$M42_LIB_DIR/core/context.sh"

# List all features
list_features() {
    log_info "Available features:"
    echo ""
    
    if [[ ! -d "$M42_FEATURES_DIR" ]] || [[ -z "$(ls -A "$M42_FEATURES_DIR" 2>/dev/null)" ]]; then
        echo "  No features found."
        echo "  Create one with: m42-dev init <feature-id>"
        return
    fi
    
    # List features with their status
    for feature_dir in "$M42_FEATURES_DIR"/*; do
        if [[ -d "$feature_dir" ]]; then
            local feature_id=$(basename "$feature_dir")
            local status_icon="${EMOJI_FOLDER}"
            local status_text=""
            
            # Check milestone status
            if [[ -f "$feature_dir/.claude-workflow/state/global.json" ]]; then
                local completed=$(jq -r '.milestones_completed | length' "$feature_dir/.claude-workflow/state/global.json" 2>/dev/null || echo "0")
                local in_progress=$(jq -r '.milestones_in_progress | length' "$feature_dir/.claude-workflow/state/global.json" 2>/dev/null || echo "0")
                
                if [[ "$completed" -gt 0 ]] || [[ "$in_progress" -gt 0 ]]; then
                    status_icon="${EMOJI_ROCKET}"
                    status_text="active"
                    
                    if [[ "$completed" -gt 0 ]] && [[ "$in_progress" -gt 0 ]]; then
                        status_text="$status_text ($completed completed, $in_progress in progress)"
                    elif [[ "$completed" -gt 0 ]]; then
                        status_text="$status_text ($completed completed)"
                    else
                        status_text="$status_text ($in_progress in progress)"
                    fi
                fi
            fi
            
            if [[ -n "$status_text" ]]; then
                echo "  $feature_id - $status_icon $status_text"
            else
                echo "  $feature_id"
            fi
        fi
    done
}
#!/bin/bash
# Milestone checklist utilities

# Initialize milestone checklist
initialize_milestone_checklist() {
    local milestone=$1
    local checklist_file="$MILESTONE_DIR/state/checklist.json"
    
    mkdir -p "$(dirname "$checklist_file")"
    
    # Extract checklist from requirements.yaml
    if command -v yq &> /dev/null; then
        yq eval -o=json ".milestones[] | select(.id == \"$milestone\") | .implementation_checklist" "$REQUIREMENTS_FILE" \
            > "$checklist_file" 2>/dev/null || {
            log_error "Failed to extract checklist for milestone $milestone"
            echo '{}' > "$checklist_file"
        }
    else
        log_warning "yq not found. Using default checklist."
        echo '{
            "setup": {
                "Initialize project": "pending",
                "Setup dependencies": "pending"
            }
        }' > "$checklist_file"
    fi
}

# Show milestone checklist status
show_milestone_checklist_status() {
    local checklist="$MILESTONE_DIR/state/checklist.json"
    
    if [[ -f "$checklist" ]]; then
        jq -r 'to_entries | .[] | "[\(.key)]" as $cat | .value | to_entries | .[] | "\($cat) \(.key): \(.value)"' "$checklist" | \
        while read line; do
            if [[ "$line" =~ "completed" ]]; then
                echo "${EMOJI_SUCCESS} $line"
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
    
    log_info "Updating checklist..."
    
    # This is a simplified version - in reality, Claude would update this
    # For now, just track that we attempted the iteration
    local checklist="$MILESTONE_DIR/state/checklist.json"
    
    # Mark first pending item as in_progress (simulation)
    # In real usage, Claude's output would drive these updates
}
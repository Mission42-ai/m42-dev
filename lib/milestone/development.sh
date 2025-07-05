#!/bin/bash
# Milestone development functions

# Source dependencies
source "$M42_LIB_DIR/utils/logging.sh"
source "$M42_LIB_DIR/core/context.sh"
source "$M42_LIB_DIR/milestone/info.sh"
source "$M42_LIB_DIR/milestone/checklist.sh"
source "$M42_LIB_DIR/milestone/state.sh"
source "$M42_LIB_DIR/prompts/load-prompt.sh"

# Run milestone development
run_milestone_development() {
    local milestone="$1"
    set_milestone_context "$milestone"
    
    # Check dependencies
    if ! check_milestone_dependencies "$milestone"; then
        log_error "Dependencies not met for milestone $milestone"
        echo "Complete required milestones first."
        return 1
    fi
    
    # Update global state
    update_global_state_milestone_start "$milestone"
    
    # Initialize milestone directory
    mkdir -p "$MILESTONE_DIR"/{iterations,reviews,state,context}
    
    # Initialize checklist
    initialize_milestone_checklist "$milestone"
    
    # Initialize accumulated context
    echo '{
        "completed_files": [],
        "implemented_features": [],
        "patterns_used": [],
        "decisions_made": []
    }' > "$MILESTONE_DIR/context/accumulated.json"
    
    # Show milestone info
    show_milestone_info "$milestone"
    echo ""
    
    # Initialize state
    cat > "$MILESTONE_DIR/state/current.json" <<EOF
{
    "milestone_id": "$milestone",
    "current_iteration": 0,
    "phase": "in_progress",
    "quality_passed": false,
    "start_time": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
}
EOF
    
    # Development loop
    local iteration=1
    local quality_passed=false
    
    while [[ $iteration -le $M42_MAX_ITERATIONS ]] && [[ "$quality_passed" != "true" ]]; do
        log_section "Iteration $iteration of $M42_MAX_ITERATIONS"
        
        # Development phase
        run_development_phase $iteration
        
        # Commit changes
        commit_changes $iteration
        
        # Review phase
        local review_result=$(run_review_phase $iteration)
        
        # Check quality gates
        quality_passed=$(echo "$review_result" | jq -r '.quality_passed')
        
        if [[ "$quality_passed" == "true" ]]; then
            log_success "Quality gates PASSED! 🎉"
            update_milestone_state $iteration "true" "$review_result"
            break
        else
            log_warning "Quality gates not passed. Issues found:"
            echo "$review_result" | jq -r '.issues[]' | sed 's/^/   - /'
            
            # Prepare feedback for next iteration
            prepare_feedback_context "$review_result" $iteration
            update_milestone_state $iteration "false" "$review_result"
            
            # Pause before next iteration
            if [[ $iteration -lt $M42_MAX_ITERATIONS ]]; then
                echo ""
                echo "⏸️  Pausing for $M42_PAUSE_BETWEEN_ITERATIONS seconds before next iteration..."
                sleep $M42_PAUSE_BETWEEN_ITERATIONS
            fi
        fi
        
        ((iteration++))
    done
    
    # Final summary
    final_milestone_summary "$milestone" "$quality_passed" $((iteration-1))
}

# Run development phase
run_development_phase() {
    local iteration=$1
    local output_file="$MILESTONE_DIR/iterations/dev_${iteration}.md"
    local error_file="$MILESTONE_DIR/iterations/dev_${iteration}_errors.txt"
    
    log_info "Starting development phase..."
    
    # Create development context
    local dev_context=$(create_development_context $iteration)
    
    # Save context for debugging
    echo "$dev_context" > "$MILESTONE_DIR/iterations/context_${iteration}.txt"
    
    # Execute development
    log_info "${EMOJI_ROBOT} Running Claude Code for development..."
    
    # Ensure output directory exists
    mkdir -p "$(dirname "$output_file")"
    
    if echo "$dev_context" | $M42_CLAUDE_CMD --print > "$output_file" 2>"$error_file"; then
        log_success "Development phase completed"
    else
        log_warning "Development phase had errors (see $error_file)"
    fi
    
    # Show brief summary of what was done
    echo "Development output saved to: $output_file"
    if [[ -f "$output_file" ]]; then
        echo "Summary: $(head -n 5 "$output_file" | grep -E '^(Created|Modified|Implemented)' || echo "See output file for details")"
    fi
    
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
    
    # Get project context
    local project_context=$(cat "$PROJECT_CONTEXT_FILE" 2>/dev/null || echo "No project context available")
    
    # Get checklist status
    local checklist_status=$(show_milestone_checklist_status)
    
    # Get accumulated context
    local accumulated_context=$(cat "$MILESTONE_DIR/context/accumulated.json" | jq -r '
        "Files: " + (.completed_files | join(", ")) + "\n" +
        "Features: " + (.implemented_features | join(", "))
    ' 2>/dev/null || echo "No previous iterations")
    
    # Build previous feedback section if not first iteration
    local previous_feedback=""
    if [[ $iteration -gt 1 ]]; then
        local feedback_file="$MILESTONE_DIR/reviews/feedback_$((iteration-1)).json"
        if [[ -f "$feedback_file" ]]; then
            previous_feedback=$'\n\n=== PREVIOUS REVIEW FEEDBACK ===\nFix these issues from the last review:\n'
            previous_feedback+=$(jq -r '.issues[]' "$feedback_file" | sed 's/^/- /')
        fi
    fi
    
    # Load and populate the prompt template
    load_prompt "$M42_PROMPTS_DIR/milestone/development.md" \
        "CURRENT_FEATURE=$CURRENT_FEATURE" \
        "CURRENT_MILESTONE=$CURRENT_MILESTONE" \
        "PROJECT_CONTEXT=$project_context" \
        "MILESTONE_INFO=$milestone_info" \
        "CHECKLIST_STATUS=$checklist_status" \
        "ACCUMULATED_CONTEXT=$accumulated_context" \
        "PREVIOUS_FEEDBACK=$previous_feedback"
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

# Prepare feedback context
prepare_feedback_context() {
    local review_result="$1"
    local iteration=$2
    
    # Save review issues as feedback for next iteration
    echo "$review_result" | jq '{issues: .issues, recommendations: .recommendations}' \
        > "$MILESTONE_DIR/reviews/feedback_${iteration}.json"
}

# Final milestone summary
final_milestone_summary() {
    local milestone=$1
    local quality_passed=$2
    local total_iterations=$3
    
    echo ""
    log_section "Milestone $milestone Summary"
    
    if [[ "$quality_passed" == "true" ]]; then
        log_success "Milestone COMPLETED successfully!"
        update_global_state_milestone_complete "$milestone"
    else
        log_error "Milestone NOT completed after $total_iterations iterations"
        echo "Review the issues and run recovery commands if needed."
    fi
    
    echo ""
    echo "Total iterations: $total_iterations"
    echo "Final status: $([ "$quality_passed" == "true" ] && echo "PASSED" || echo "FAILED")"
    echo ""
    echo "Artifacts:"
    echo "  - Development outputs: $MILESTONE_DIR/iterations/"
    echo "  - Review results: $MILESTONE_DIR/reviews/"
    echo "  - Current state: $MILESTONE_DIR/state/current.json"
}
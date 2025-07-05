#!/bin/bash
# Recovery commands

# Source dependencies
source "$M42_LIB_DIR/utils/logging.sh"
source "$M42_LIB_DIR/core/context.sh"
source "$M42_LIB_DIR/milestone/state.sh"
source "$M42_LIB_DIR/review/review.sh"
source "$M42_LIB_DIR/milestone/development.sh"

# Recover from failure
recover_from_failure() {
    local feature_id="${1:-}"
    local milestone="${2:-}"
    local action="${3:-review}"  # Default to review
    
    if [[ -z "$feature_id" ]] || [[ -z "$milestone" ]]; then
        log_error "Error: Feature ID and milestone required"
        echo "Usage: m42-dev recover <feature-id> <milestone> [review|continue|next]"
        echo "  review   - Re-run review for last iteration"
        echo "  continue - Continue development from current iteration"
        echo "  next     - Force next iteration"
        return 1
    fi
    
    set_feature_context "$feature_id"
    set_milestone_context "$milestone"
    
    if [[ ! -d "$MILESTONE_DIR" ]]; then
        log_error "Milestone $milestone not found"
        return 1
    fi
    
    # Load current state
    local current_state=$(cat "$MILESTONE_DIR/state/current.json")
    local current_iteration=$(echo "$current_state" | jq -r '.current_iteration')
    local phase=$(echo "$current_state" | jq -r '.phase')
    
    log_info "Current state: Iteration $current_iteration, Phase: $phase"
    
    case "$action" in
        "review")
            log_info "${EMOJI_SEARCH} Re-running review for iteration $current_iteration..."
            cd "$M42_ROOT"  # Ensure we're in the right directory for git
            local review_result=$(run_review_phase $current_iteration)
            
            # Check quality gates
            if [[ $(echo "$review_result" | jq -r '.quality_passed') == "true" ]]; then
                log_success "Quality gates PASSED!"
                update_milestone_state $current_iteration "true" "$review_result"
                final_milestone_summary "$milestone" "true" $current_iteration
            else
                log_error "Quality gates failed. Issues found:"
                echo "$review_result" | jq -r '.issues[]' | sed 's/^/   - /'
                prepare_feedback_context "$review_result" $current_iteration
                update_milestone_state $current_iteration "false" "$review_result"
                echo ""
                echo "📝 Run 'm42-dev recover $feature_id $milestone continue' to proceed with fixes"
            fi
            ;;
            
        "continue")
            log_info "🔄 Continuing development from iteration $current_iteration..."
            local next_iteration=$((current_iteration + 1))
            
            if [[ $next_iteration -gt $M42_MAX_ITERATIONS ]]; then
                log_error "Maximum iterations ($M42_MAX_ITERATIONS) reached"
                return 1
            fi
            
            # Run next development iteration
            echo "Starting iteration $next_iteration..."
            run_development_phase $next_iteration
            commit_changes $next_iteration
            
            # Run review
            local review_result=$(run_review_phase $next_iteration)
            
            # Update state
            if [[ $(echo "$review_result" | jq -r '.quality_passed') == "true" ]]; then
                update_milestone_state $next_iteration "true" "$review_result"
                final_milestone_summary "$milestone" "true" $next_iteration
            else
                update_milestone_state $next_iteration "false" "$review_result"
                log_error "Quality gates still failing. Run recover again or check the issues."
            fi
            ;;
            
        "next")
            log_info "⏩ Forcing next iteration..."
            local next_iteration=$((current_iteration + 1))
            update_milestone_state $next_iteration "false" '{"quality_passed": false, "issues": ["Manually advanced"]}'
            echo "Updated to iteration $next_iteration"
            ;;
            
        *)
            log_error "Unknown action: $action"
            echo "Valid actions: review, continue, next"
            return 1
            ;;
    esac
}
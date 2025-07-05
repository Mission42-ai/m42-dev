#!/bin/bash
# Code review functions

# Source dependencies
source "$M42_LIB_DIR/utils/logging.sh"
source "$M42_LIB_DIR/core/context.sh"
source "$M42_LIB_DIR/milestone/info.sh"
source "$M42_LIB_DIR/milestone/checklist.sh"
source "$M42_LIB_DIR/prompts/load-prompt.sh"

# Run review phase
run_review_phase() {
    local iteration=$1
    local review_output="$MILESTONE_DIR/reviews/review_${iteration}.json"
    
    log_info "${EMOJI_SEARCH} Starting review phase for iteration $iteration"
    
    # Run pre-flight checks
    log_info "🛫 Running pre-flight checks..."
    local preflight_results=""
    
    # Check for package.json to determine project type
    if [[ -f "package.json" ]]; then
        # Node.js project checks
        echo "  - Building project..."
        local build_result=$(npm run build --if-present 2>&1 || npx tsc --noEmit 2>&1 || echo "No build configured")
        preflight_results+="Build Check:\n$build_result\n\n"
        
        echo "  - Running linter..."
        local lint_result=$(npm run lint --if-present 2>&1 || echo "No linter configured")
        preflight_results+="Lint Check:\n$lint_result\n\n"
        
        echo "  - Running tests..."
        local test_result=$(npm test -- --run --reporter=dot 2>&1 || echo "Tests need attention")
        preflight_results+="Test Results:\n$test_result\n\n"
    elif [[ -f "Cargo.toml" ]]; then
        # Rust project checks
        echo "  - Checking Rust project..."
        local check_result=$(cargo check 2>&1 || echo "Cargo check failed")
        preflight_results+="Cargo Check:\n$check_result\n\n"
        
        echo "  - Running tests..."
        local test_result=$(cargo test 2>&1 || echo "Tests need attention")
        preflight_results+="Test Results:\n$test_result\n\n"
    elif [[ -f "go.mod" ]]; then
        # Go project checks
        echo "  - Building Go project..."
        local build_result=$(go build ./... 2>&1 || echo "Go build failed")
        preflight_results+="Build Check:\n$build_result\n\n"
        
        echo "  - Running tests..."
        local test_result=$(go test ./... 2>&1 || echo "Tests need attention")
        preflight_results+="Test Results:\n$test_result\n\n"
    else
        preflight_results="No recognized project type for pre-flight checks"
    fi
    
    # Get commit info
    local commit_info=$(git log -1 --pretty=format:"%H|%s" 2>/dev/null || echo "no-git|Manual review")
    local commit_diff=$(git diff HEAD~1 HEAD 2>/dev/null || echo "No git diff available")
    
    log_info "📝 Creating review context..."
    # Create review context
    local review_context=$(create_review_context "$commit_info" "$commit_diff" "$preflight_results")
    
    # Execute review
    log_info "${EMOJI_ROBOT} Running Claude Code for comprehensive review with parallel subagents..."
    
    # Save review context for debugging
    echo "$review_context" > "$MILESTONE_DIR/reviews/context_${iteration}.txt"
    
    # Run Claude and capture both output and errors (with timeout)
    local review_result=""
    
    # Use timeout command to prevent hanging (5 minutes max for review)
    if command -v timeout >/dev/null 2>&1; then
        review_result=$(echo "$review_context" | timeout 300 $M42_CLAUDE_CMD --print 2>"$MILESTONE_DIR/reviews/errors_${iteration}.txt")
    else
        review_result=$(echo "$review_context" | $M42_CLAUDE_CMD --print 2>"$MILESTONE_DIR/reviews/errors_${iteration}.txt")
    fi
    
    if [[ -z "$review_result" ]]; then
        log_error "Claude review failed. Check errors in reviews/errors_${iteration}.txt"
        review_result='{"quality_passed": false, "issues": ["Claude review execution failed - check error log"]}'
    fi
    
    # Save raw output for debugging
    echo "$review_result" > "$MILESTONE_DIR/reviews/raw_${iteration}.txt"
    
    # Parse and extract JSON from review output
    extract_review_json "$review_result" "$review_output"
    
    # Display review summary
    display_review_summary "$review_output"
    
    cat "$review_output"
}

# Extract JSON from review output
extract_review_json() {
    local review_result="$1"
    local review_output="$2"
    
    # Strip markdown code blocks if present
    local clean_result="$review_result"
    
    # Method 1: Check if result starts with ```json
    if [[ "$review_result" =~ ^[[:space:]]*\`\`\`json ]]; then
        # Extract content between ```json and ```
        clean_result=$(echo "$review_result" | sed -n '/```json/,/```/{/```json/d;/```/d;p}')
    # Method 2: Check if result starts with just ```
    elif [[ "$review_result" =~ ^[[:space:]]*\`\`\` ]]; then
        # Extract content between ``` and ```
        clean_result=$(echo "$review_result" | sed -n '/```/,/```/{/```/d;p}')
    fi
    
    # Parse and save result
    if echo "$clean_result" | jq '.' > "$review_output" 2>/dev/null; then
        log_success "Review completed successfully"
    else
        log_error "Failed to parse review JSON from cleaned result"
        echo "Attempting to extract JSON from output..."
        
        # Try multiple extraction methods
        # Method 1: Extract the first complete JSON object
        if echo "$review_result" | grep -o '{[^}]*}' | head -1 | jq '.' > "$review_output" 2>/dev/null; then
            log_success "Successfully extracted simple JSON from output"
        # Method 2: Try to find JSON using a more complex pattern
        elif echo "$review_result" | perl -0777 -ne 'print $1 if /(\{(?:[^{}]|(?R))*\})/' | jq '.' > "$review_output" 2>/dev/null; then
            log_success "Successfully extracted nested JSON from output"
        # Method 3: Try to extract between first { and last }
        elif echo "$review_result" | sed -n '/{/,/}/{p}' | jq '.' > "$review_output" 2>/dev/null; then
            log_success "Successfully extracted JSON using sed"
        else
            log_error "All JSON extraction methods failed"
            echo '{"quality_passed": false, "issues": ["Review output was not valid JSON"], "score": 0, "critical_issues": [], "metrics": {}}' > "$review_output"
        fi
    fi
}

# Display review summary
display_review_summary() {
    local review_output="$1"
    
    echo ""
    log_info "Review Summary:"
    local score=$(jq -r '.score // 0' "$review_output")
    local quality_passed=$(jq -r '.quality_passed // false' "$review_output")
    local critical_count=$(jq -r '.critical_issues | length // 0' "$review_output" 2>/dev/null || echo "0")
    
    echo "  - Score: $score/100"
    echo "  - Quality Gates: $([ "$quality_passed" == "true" ] && echo "${EMOJI_SUCCESS} PASSED" || echo "${EMOJI_ERROR} FAILED")"
    echo "  - Critical Issues: $critical_count"
    
    if [[ "$critical_count" -gt 0 ]]; then
        echo ""
        log_warning "Critical Issues Found:"
        jq -r '.critical_issues[]? | "  - [\(.severity)] \(.issue)"' "$review_output" 2>/dev/null || true
    fi
}

# Create review context
create_review_context() {
    local commit_info=$1
    local commit_diff=$2
    local preflight_results=$3
    
    # Get required data
    local project_context=$(cat "$PROJECT_CONTEXT_FILE" 2>/dev/null || echo "No project context file found")
    local milestone_requirements=$(get_milestone_info "$CURRENT_MILESTONE" 2>&1)
    local checklist_status=$(show_milestone_checklist_status 2>&1)
    
    # Use parallel review prompt if requested
    local review_prompt_file="$M42_PROMPTS_DIR/review/milestone-review.md"
    if [[ "${M42_USE_PARALLEL_REVIEW:-true}" == "true" ]]; then
        review_prompt_file="$M42_PROMPTS_DIR/review/milestone-review-parallel.md"
    fi
    
    # Load and populate the review prompt template
    load_prompt "$review_prompt_file" \
        "CURRENT_FEATURE=$CURRENT_FEATURE" \
        "CURRENT_MILESTONE=$CURRENT_MILESTONE" \
        "PROJECT_CONTEXT=$project_context" \
        "MILESTONE_REQUIREMENTS=$milestone_requirements" \
        "CHECKLIST_STATUS=$checklist_status" \
        "COMMIT_INFO=$commit_info" \
        "COMMIT_DIFF=$commit_diff" \
        "PREFLIGHT_RESULTS=$preflight_results"
}
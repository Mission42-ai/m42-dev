#!/bin/bash
# Project initialization commands

# Source dependencies
source "$M42_LIB_DIR/utils/logging.sh"
source "$M42_LIB_DIR/prompts/load-prompt.sh"

# Initialize project structure
init_project() {
    local force="${1:-}"
    
    log_info "${EMOJI_BUILD} Initializing M42 project structure..."
    
    # Check if specs directory already exists
    if [[ -d "$M42_SPECS_DIR" ]] && [[ "$force" != "--force" ]]; then
        log_warning "Project already initialized (specs/ directory exists)"
        echo "Use 'm42-dev init-project --force' to reinitialize and regenerate project-context.md"
        return 1
    fi
    
    # Create directory structure
    mkdir -p "$M42_SPECS_DIR/features"
    mkdir -p "$M42_SPECS_DIR/logs"
    log_info "${EMOJI_FOLDER} Created project structure:"
    echo "  - specs/"
    echo "  - specs/features/"
    echo "  - specs/logs/"
    
    # Generate project context using Claude
    echo ""
    log_info "${EMOJI_SEARCH} Analyzing project codebase..."
    generate_project_context
    
    echo ""
    log_success "Project initialized successfully!"
    echo ""
    log_info "Next steps:"
    echo "1. Review and enhance specs/project-context.md"
    echo "2. Create your first feature: m42-dev init <feature-id>"
}

# Generate project context using Claude
generate_project_context() {
    local context_file="$M42_SPECS_DIR/project-context.md"
    local template_file="$M42_TEMPLATES_DIR/project/project-context-template.md"
    
    # Check if template exists
    if [[ ! -f "$template_file" ]]; then
        log_error "Template not found: $template_file"
        echo "Creating basic project-context.md..."
        echo "# Project Context" > "$context_file"
        echo "" >> "$context_file"
        echo "Please fill out this file with your project details." >> "$context_file"
        return
    fi
    
    # Load template content
    local template_content=$(cat "$template_file")
    
    # Create analysis prompt using the external prompt file
    local analysis_prompt=$(load_prompt "$M42_PROMPTS_DIR/project/analyze-project.md" \
        "TEMPLATE_CONTENT=$template_content" \
        "CONTEXT_FILE=$context_file")
    
    # Save analysis prompt for debugging
    echo "$analysis_prompt" > "$M42_SPECS_DIR/logs/analysis-prompt.txt"
    
    # Run Claude to analyze project with extended timeout
    log_info "${EMOJI_ROBOT} Running Claude Code to analyze project..."
    echo "⏳ This may take a few minutes as Claude analyzes your codebase..."
    
    # Set extended timeout for this operation (10 minutes)
    export BASH_DEFAULT_TIMEOUT_MS=600000
    export BASH_MAX_TIMEOUT_MS=600000
    
    echo "$analysis_prompt" | $M42_CLAUDE_CMD --print \
        > "$M42_SPECS_DIR/logs/analysis-output.txt" 2>&1 || {
            log_error "Claude analysis failed. Check specs/logs/analysis-output.txt for details."
            echo "Creating basic project-context.md..."
            cp "$template_file" "$context_file"
            return
        }
    
    # Check if project-context.md was created
    if [[ -f "$context_file" ]]; then
        log_success "Project context generated: specs/project-context.md"
    else
        log_warning "Project context generation incomplete. Creating from template..."
        cp "$template_file" "$context_file"
    fi
}
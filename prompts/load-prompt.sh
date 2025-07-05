#!/bin/bash

# Load and process a prompt template
# Usage: load_prompt <prompt_file> [variable1=value1] [variable2=value2] ...

load_prompt() {
    local prompt_file="$1"
    shift
    
    if [[ ! -f "$prompt_file" ]]; then
        echo "Error: Prompt file not found: $prompt_file" >&2
        return 1
    fi
    
    # Read the prompt template
    local prompt_content=$(cat "$prompt_file")
    
    # Replace template variables
    while [[ $# -gt 0 ]]; do
        local var_assignment="$1"
        shift
        
        # Split on first = to get variable name and value
        local var_name="${var_assignment%%=*}"
        local var_value="${var_assignment#*=}"
        
        # Escape special characters in the value for sed
        var_value=$(printf '%s\n' "$var_value" | sed 's/[[\.*^$()+?{|]/\\&/g')
        
        # Replace the variable in the prompt
        prompt_content=$(echo "$prompt_content" | sed "s|{{${var_name}}}|${var_value}|g")
    done
    
    echo "$prompt_content"
}

# Export the function so it can be used by m42-dev.sh
export -f load_prompt
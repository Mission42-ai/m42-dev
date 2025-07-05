#!/bin/bash
# Feature context management

# Feature-specific variables (set by set_feature_context)
export CURRENT_FEATURE=""
export FEATURE_DIR=""
export WORK_DIR=""
export REQUIREMENTS_FILE=""
export PROJECT_CONTEXT_FILE=""
export CURRENT_MILESTONE=""
export MILESTONE_DIR=""

# Set feature context
set_feature_context() {
    local feature_id="$1"
    CURRENT_FEATURE="$feature_id"
    FEATURE_DIR="$M42_FEATURES_DIR/$feature_id"
    WORK_DIR="$FEATURE_DIR/.claude-workflow"
    REQUIREMENTS_FILE="$FEATURE_DIR/requirements.yaml"
    PROJECT_CONTEXT_FILE="$FEATURE_DIR/feature-context.md"
}

# Set milestone context
set_milestone_context() {
    local milestone="$1"
    CURRENT_MILESTONE="$milestone"
    MILESTONE_DIR="$WORK_DIR/milestones/$milestone"
}

# Check if feature exists
feature_exists() {
    local feature_id="$1"
    [[ -d "$M42_FEATURES_DIR/$feature_id" ]]
}

# Check if milestone exists
milestone_exists() {
    local feature_id="$1"
    local milestone="$2"
    set_feature_context "$feature_id"
    [[ -d "$WORK_DIR/milestones/$milestone" ]]
}
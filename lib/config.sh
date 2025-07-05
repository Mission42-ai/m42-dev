#!/bin/bash
# Configuration and constants for m42-dev

# Tool directories
export M42_ROOT="$( cd "$( dirname "${BASH_SOURCE[0]}" )/.." && pwd )"
export M42_LIB_DIR="$M42_ROOT/lib"
export M42_TEMPLATES_DIR="$M42_ROOT/templates"
export M42_PROMPTS_DIR="$M42_ROOT/prompts"
export M42_SPECS_DIR="$M42_ROOT/specs"
export M42_FEATURES_DIR="$M42_SPECS_DIR/features"

# Development settings
export M42_MAX_ITERATIONS=${M42_MAX_ITERATIONS:-10}
export M42_PAUSE_BETWEEN_ITERATIONS=${M42_PAUSE_BETWEEN_ITERATIONS:-5}

# Claude Code settings
export M42_CLAUDE_CMD=${M42_CLAUDE_CMD:-"claude"}
export M42_CLAUDE_FLAGS=${M42_CLAUDE_FLAGS:-""}

# Review settings
export M42_USE_PARALLEL_REVIEW=${M42_USE_PARALLEL_REVIEW:-true}

# Colors for output
export COLOR_RESET='\033[0m'
export COLOR_RED='\033[0;31m'
export COLOR_GREEN='\033[0;32m'
export COLOR_YELLOW='\033[0;33m'
export COLOR_BLUE='\033[0;34m'

# Emoji shortcuts
export EMOJI_SUCCESS="✅"
export EMOJI_ERROR="❌"
export EMOJI_WARNING="⚠️"
export EMOJI_INFO="📋"
export EMOJI_SEARCH="🔍"
export EMOJI_BUILD="🏗️"
export EMOJI_ROBOT="🤖"
export EMOJI_FOLDER="📁"
export EMOJI_FILE="📄"
export EMOJI_ROCKET="🚀"
export EMOJI_NEW="🆕"
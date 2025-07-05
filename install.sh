#!/bin/bash

# M42 Dev Tool Installer
# This script helps install the tool in your project

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${GREEN}M42 Dev Tool Installer${NC}"
echo "============================================="
echo

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Check prerequisites
echo "Checking prerequisites..."

if ! command_exists git; then
    echo -e "${RED}Error: Git is not installed${NC}"
    exit 1
fi

if ! command_exists jq; then
    echo -e "${YELLOW}Warning: jq is not installed${NC}"
    echo "Install with: sudo apt-get install jq (Ubuntu) or brew install jq (macOS)"
    exit 1
fi

if ! command_exists yq; then
    echo -e "${YELLOW}Warning: yq is not installed${NC}"
    echo "Install with:"
    echo "  wget https://github.com/mikefarah/yq/releases/latest/download/yq_linux_amd64 -O /usr/local/bin/yq"
    echo "  chmod +x /usr/local/bin/yq"
    exit 1
fi

# Get project directory
if [ -z "$1" ]; then
    echo "Usage: ./install.sh /path/to/your/project"
    exit 1
fi

PROJECT_DIR="$1"

if [ ! -d "$PROJECT_DIR" ]; then
    echo -e "${RED}Error: Project directory does not exist: $PROJECT_DIR${NC}"
    exit 1
fi

cd "$PROJECT_DIR"

# Check if it's a git repository
if [ ! -d ".git" ]; then
    echo -e "${YELLOW}Warning: $PROJECT_DIR is not a git repository${NC}"
    read -p "Continue anyway? (y/n) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi

echo
echo "Installing M42 Dev Tool..."

# Create tools directory
mkdir -p tools

# Copy the tool
echo "1. Copying tool files..."
cp -r "$SCRIPT_DIR" tools/m42-dev

# Create Claude commands directory
echo "2. Setting up Claude commands..."
mkdir -p .claude/commands

# Create symbolic link for the command
ln -sf ../../tools/m42-dev/commands/develop-feature.md .claude/commands/develop-feature.md

# Create specs directory
echo "3. Creating project structure..."
mkdir -p specs/features

# Copy example if requested
read -p "Would you like to copy an example feature? (y/n) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    cp -r "$SCRIPT_DIR/examples/FEAT-001-user-registration" specs/features/
    echo -e "${GREEN}Example feature copied to specs/features/FEAT-001-user-registration${NC}"
fi

# Create project context template
if [ ! -f "PROJECT_CONTEXT.md" ]; then
    echo "4. Creating project context template..."
    cat > PROJECT_CONTEXT.md << 'EOF'
# Project Context

## Overview
[Describe your project here]

## Architecture
[Describe your architecture pattern]

## Technical Stack
- Programming Language: 
- Framework: 
- Database: 
- Testing Framework: 

## Coding Standards
[Your coding standards]

## Development Patterns
[Common patterns used in your project]
EOF
    echo -e "${GREEN}Created PROJECT_CONTEXT.md - Please edit this file${NC}"
fi

# Make scripts executable
echo "5. Setting permissions..."
chmod +x tools/m42-dev/m42-dev.sh

# Create .gitignore entries
echo "6. Updating .gitignore..."
if [ -f ".gitignore" ]; then
    if ! grep -q "\.claude-workflow/" .gitignore; then
        echo -e "\n# M42 Dev Tool" >> .gitignore
        echo ".claude-workflow/" >> .gitignore
        echo "*.claude-backup" >> .gitignore
    fi
else
    cat > .gitignore << 'EOF'
# M42 Dev Tool
.claude-workflow/
*.claude-backup
EOF
fi

echo
echo -e "${GREEN}Installation complete!${NC}"
echo
echo "Next steps:"
echo "1. Edit PROJECT_CONTEXT.md with your project details"
echo "2. Open Claude Code in this directory"
echo "3. Run: /develop-feature FEAT-XXX to start developing a feature"
echo
echo "Quick test:"
echo "  cd $PROJECT_DIR"
echo "  tools/m42-dev/m42-dev.sh --help"
echo
echo "Documentation:"
echo "  - Setup Guide: tools/m42-dev/SETUP_GUIDE.md"
echo "  - README: tools/m42-dev/README.md"
echo
echo -e "${GREEN}Happy autonomous development!${NC}"
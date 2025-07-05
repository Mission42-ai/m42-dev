# M42-Dev Prompts

This directory contains all the prompts used by the m42-dev tool to interact with Claude.

## Structure

- `project/` - Prompts for project-level operations
  - `analyze-project.md` - Analyzes codebase to generate project context
  
- `milestone/` - Prompts for milestone development
  - `development.md` - Main development prompt for implementing milestones
  
- `review/` - Prompts for code review
  - `milestone-review.md` - Reviews milestone implementation and provides quality scores

## Template Variables

The prompts use template variables that are replaced at runtime:

- `{{CURRENT_FEATURE}}` - The feature ID being worked on
- `{{CURRENT_MILESTONE}}` - The milestone ID being implemented
- `{{PROJECT_CONTEXT}}` - Content from project-context.md
- `{{MILESTONE_INFO}}` - Milestone details from requirements.yaml
- `{{CHECKLIST_STATUS}}` - Current status of implementation checklist
- `{{ACCUMULATED_CONTEXT}}` - Context from previous iterations
- `{{COMMIT_INFO}}` - Git commit information
- `{{COMMIT_DIFF}}` - Git diff for review
- `{{PREVIOUS_FEEDBACK}}` - Feedback from previous review (if any)

## Usage

These prompts are loaded by m42-dev.sh and populated with actual values before being sent to Claude.

## Review Modes

The tool supports two review modes:

1. **Standard Review** (`milestone-review.md`) - Simple, direct review focusing on quality criteria
2. **Parallel Subagent Review** (`milestone-review-parallel.md`) - Comprehensive review using 6 specialized subagents running in parallel:
   - Code Quality Analyst
   - Test Engineer
   - Architecture Guardian
   - Documentation Reviewer
   - Risk Assessor
   - Bug Hunter

By default, the parallel review is enabled. To use the standard review, set:
```bash
export USE_PARALLEL_REVIEW=false
```

## Pre-flight Checks

The review process automatically runs pre-flight checks based on project type:
- **Node.js**: build, lint, and test
- **Rust**: cargo check and test
- **Go**: go build and test
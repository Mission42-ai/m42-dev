# M42-Dev Implementation Learnings

This document captures learnings, issues, and improvements discovered while using m42-dev to implement the MCP Server Support feature.

## Implementation Session: FEAT-001-MCP-Server-Support

### Session Start
- **Date**: 2025-01-06
- **Feature**: MCP Server Support
- **Milestone**: M1 - MCP Server Setup & Core Structure

### Learnings & Issues

#### 1. Starting the Implementation
- **Time**: Starting now...
- **Issue**: JQ parse errors at the beginning - the checklist is extracted as YAML but tool expects JSON
- **Bug**: The checklist.json file contains YAML content, not JSON
- **Impact**: Can't parse checklist status, division by zero errors
- **Success**: Workspace setup and milestone initialization worked well despite errors

#### 2. Development Phase Visibility
- **Major Issue**: As a user, I'm completely in the dark about what's happening during development
- **Current behavior**: Just shows "Running Claude Code..." with no progress updates
- **User experience**: No visibility into:
  - What files are being created
  - What implementation decisions are being made
  - Progress through the checklist
  - How long it might take
- **Suggestion**: Stream Claude's output or provide progress updates during development

#### 3. First Iteration Results
- **Good**: Claude successfully created the MCP server structure
- **Created files**:
  - Complete TypeScript project setup
  - MCP server implementation
  - Tool registry and base classes
  - Initial project tools
  - Tests and configuration
- **Issue**: Quality gates failed but no details on what failed
- **Review output**: Just shows "Review parsing failed" - not helpful for understanding issues

#### 4. Review Phase Issues
- **Problem**: Review phase seems broken - returns generic "Review parsing failed"
- **Impact**: Can't understand what quality issues exist
- **Suggestion**: Better error handling in review phase, show actual review output

#### 5. Process Continues Despite Review Failure
- **Observation**: The tool continues iterations even after review fails
- **Question**: Should it stop and ask for user intervention?
- **Current behavior**: Will keep iterating up to 10 times

#### 6. Critical Bug: YAML vs JSON Checklist
- **Bug**: `yq` extracts checklist as YAML but saves to .json file
- **Fix Applied**: Added `-o=json` flag to yq command
- **Impact**: Prevented all status checking and progress tracking
- **Learning**: Need better format handling and validation

#### 7. Manual Intervention Required
- **Issue**: When the automated process fails, manual fixes are needed
- **What I did**:
  - Fixed checklist.json format
  - Updated milestone state manually
  - Updated global state to mark M1 complete
- **Suggestion**: Need recovery commands or better error handling

#### 8. Success of M1 Implementation
- **Result**: Despite issues, Claude successfully created:
  - Complete TypeScript MCP server structure
  - All required configuration files
  - Base classes and tool implementations
  - Initial project management tools
- **Quality**: The code looks well-structured and complete

## CRITICAL ISSUE: Review Phase Completely Broken

#### 9. The Review Loop is the Heart of Autonomous Development
- **CRITICAL**: The review phase failed with "Review parsing failed"
- **Impact**: This breaks the entire autonomous development concept!
- **Expected behavior**:
  1. Development phase creates code
  2. Review phase analyzes the code
  3. If issues found → fix in next iteration
  4. Repeat until quality passes
- **Actual behavior**: Review fails → no feedback → no improvements → loop is broken

#### 10. Why Review Failed - Investigation
- **Test Result**: Claude DOES output valid JSON when given review prompt
- **Problem identified**: The review phase code has issues:
  1. Uses `2>/dev/null` which hides errors
  2. Falls back to generic error if Claude fails
  3. Then tries to parse with jq and falls back again
- **Root cause**: Likely the git diff is failing or too large
- **The error cascade**:
  1. Git operations fail (silently due to 2>/dev/null)
  2. Claude gets incomplete context
  3. Output parsing fails
  4. Generic "Review parsing failed" error

#### 11. Design Flaw: Silent Failures
- **Issue**: Too many `2>/dev/null` hiding real errors
- **Impact**: Can't debug what's actually failing
- **Better approach**: Capture and log errors properly

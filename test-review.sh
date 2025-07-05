#!/bin/bash

# Test the review prompt format
cat <<'EOF'
Review the implementation for FEAT-TEST - Milestone M1.

=== PROJECT CONTEXT ===
Test project context

=== MILESTONE REQUIREMENTS ===
Test requirements

=== CHECKLIST STATUS ===
Verify these items are actually implemented:
- Task 1: completed
- Task 2: completed

=== CHANGES TO REVIEW ===
Commit: abc123|Test commit

Test diff content

=== REVIEW CRITERIA ===
1. All checklist items marked complete are actually implemented
2. Code follows m42-core patterns (Event Sourcing, CQRS, DDD)
3. Proper error handling and validation
4. Tests included where appropriate
5. No hardcoded values or secrets
6. Clean, maintainable code

Respond with JSON:
{
  "quality_passed": true/false,
  "score": 0-100,
  "issues": ["Issue 1", "Issue 2"],
  "positive_aspects": ["Good thing 1"],
  "recommendations": ["Suggestion 1"]
}
EOF
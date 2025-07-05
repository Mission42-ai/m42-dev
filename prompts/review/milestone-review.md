Review the implementation for {{CURRENT_FEATURE}} - Milestone {{CURRENT_MILESTONE}}.

=== PROJECT CONTEXT ===
{{PROJECT_CONTEXT}}

=== MILESTONE REQUIREMENTS ===
{{MILESTONE_REQUIREMENTS}}

=== CHECKLIST STATUS ===
Verify these items are actually implemented:
{{CHECKLIST_STATUS}}

=== CHANGES TO REVIEW ===
Commit: {{COMMIT_INFO}}

{{COMMIT_DIFF}}

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
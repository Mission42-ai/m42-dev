Review the implementation for {{CURRENT_FEATURE}} - Milestone {{CURRENT_MILESTONE}} using specialized analysis.

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

=== PRE-FLIGHT CHECK RESULTS ===
{{PREFLIGHT_RESULTS}}

IMPORTANT: Initialize ALL subagent tasks at once using parallel Task() calls for comprehensive analysis!

Orchestrate a thorough review using these specialized subagents:

SUBAGENT 1 - CODE QUALITY ANALYST:
Task: "Analyze code changes for:
- Clean code principles (DRY, SOLID, KISS)
- Naming conventions and readability
- Error handling and edge cases
- Performance implications
- Code complexity and maintainability
Provide severity ratings (high/medium/low) for each finding."

SUBAGENT 2 - TEST ENGINEER:
Task: "Review testing quality:
- Test coverage for new/modified code
- Test naming and organization
- Edge cases and boundary conditions tested
- Mock usage appropriateness
- Test isolation and independence
- Test data management
- Assertion quality and specificity
- Missing test scenarios
Rate overall test quality (1-10) and identify critical gaps."

SUBAGENT 3 - ARCHITECTURE GUARDIAN:
Task: "Verify architecture compliance:
- Design pattern adherence
- Module boundaries and coupling
- Dependency direction
- Interface segregation
- Abstraction levels
- Technical debt introduced
Flag any architectural violations with specific remediation suggestions."

SUBAGENT 4 - DOCUMENTATION REVIEWER:
Task: "Assess documentation:
- Code comments appropriateness
- README updates if needed
- API documentation completeness
- Type definitions and interfaces documented
- Complex logic explained
Rate documentation completeness (1-10) and clarity."

SUBAGENT 5 - RISK ASSESSOR:
Task: "Identify risks:
- Breaking changes in public APIs
- Configuration changes needed
- Backward compatibility issues
- Security vulnerabilities introduced
- Performance degradation risks
- Scalability concerns
Classify each risk by impact (high/medium/low) and likelihood."

SUBAGENT 6 - BUG HUNTER:
Task: "Hunt for functional issues:
- Logic errors or bugs
- Race conditions
- Null/undefined reference possibilities
- Input validation gaps
- State management issues
- Memory leaks
Provide concrete scenarios where failures could occur."

MAIN ORCHESTRATOR FINAL TASK:
After ALL subagents complete their analysis:
1. Synthesize findings from all subagents
2. Resolve any conflicting assessments
3. Prioritize all issues by severity and impact
4. Generate final verdict with this JSON structure:

```json
{
  "quality_passed": true/false,
  "score": 0-100,
  "critical_issues": [
    {
      "issue": "Description",
      "severity": "high/medium/low",
      "source": "which subagent found it",
      "fix": "Specific remediation"
    }
  ],
  "issues": ["Other non-critical issues"],
  "positive_aspects": ["Good things found"],
  "recommendations": ["Improvement suggestions"],
  "metrics": {
    "code_quality_score": 0-10,
    "test_quality_score": 0-10,
    "documentation_score": 0-10,
    "architecture_compliance": 0-10
  }
}
```

Quality gates:
- Pass if score >= 80 AND no high-severity critical issues
- Consider test coverage, code quality, and architecture compliance
- Factor in the milestone requirements completion
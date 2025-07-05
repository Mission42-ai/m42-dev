---
allowed-tools: Bash(*), Read(specs/features/**), TodoWrite(*), TodoRead, LS(specs/features/**)
description: Orchestrates autonomous feature development by managing the claude-dev.sh bash script
---
# Feature Development Orchestrator

Initialize and validate feature:
!`FEATURE_ID="${1:-}"; if [ -z "$FEATURE_ID" ]; then echo "ERROR: Feature ID required. Usage: /develop-feature FEAT-XXX"; exit 1; fi; echo "🚀 Orchestrating development for: $FEATURE_ID"`

## Step 1: Check Current Status

!`tools/claude-autonomous-dev/claude-dev.sh status $1`

## Step 2: Initialize Feature (if needed)

!`if [ ! -f "specs/features/$1/requirements.yaml" ]; then echo "📝 Feature not initialized. Creating..."; tools/claude-autonomous-dev/claude-dev.sh init $1; echo "Please edit requirements.yaml and project-context.md before continuing."; else echo "✅ Feature already initialized"; fi`

## Step 3: Analyze Milestones and Dependencies

Show all milestones:
!`tools/claude-autonomous-dev/claude-dev.sh milestones $1`

Parse dependency structure:
!`echo "=== Milestone Dependencies ==="; yq eval '.milestones[] | .id + ": depends on [" + (.dependencies | join(", ")) + "]"' specs/features/$1/requirements.yaml 2>/dev/null || echo "Could not parse dependencies"`

Identify starting milestones (no dependencies):
!`echo "=== Can Start Immediately ==="; yq eval '.milestones[] | select(.dependencies | length == 0) | .id' specs/features/$1/requirements.yaml 2>/dev/null`

## Step 4: Launch Development

Based on the dependency analysis above, I will now:

1. **Start independent milestones** in parallel
2. **Monitor progress** using the status command
3. **Launch dependent milestones** as their dependencies complete

### Starting Milestone Development

For each milestone that can start, I'll run:
```bash
# In separate terminal/process:
tools/claude-autonomous-dev/claude-dev.sh start $1 <milestone-id>
```

The bash script will handle:
- Creating workspace for the milestone
- Running development iterations
- Self-review and quality gates
- State management and progress tracking

### Monitoring Progress

I'll periodically check status:
```bash
tools/claude-autonomous-dev/claude-dev.sh status $1
```

This shows:
- Which milestones are completed ✅
- Which are in progress 🔄
- Which are pending ⬜
- Current iteration for active milestones

## Step 5: Handle Milestone Completion

When a milestone completes:

1. **Verify completion**:
   !`echo "Checking completion status..."; [ -f "specs/features/$1/.claude-workflow/state/global.json" ] && jq '.milestones_completed' specs/features/$1/.claude-workflow/state/global.json || echo "No state file yet"`

2. **Identify newly available milestones**:
   Based on completed milestones, determine which new ones can start

3. **Launch next milestones**:
   ```bash
   tools/claude-autonomous-dev/claude-dev.sh start $1 <next-milestone>
   ```

## Step 6: Parallel Execution Strategy

Check the defined strategy:
!`yq eval '.parallel_execution.suggested_assignment' specs/features/$1/requirements.yaml 2>/dev/null || echo "No parallel strategy defined"`

I'll manage multiple milestone executions according to this strategy:
- Agent 1: Sequential milestones (e.g., M1 → M2 → M3)
- Agent 2: Parallel track (e.g., M4)
- Agent 3: Another parallel track (e.g., M5, M6)

## Step 7: Handle Issues

If a milestone fails or gets stuck:

1. **Check logs**:
   ```bash
   tail -f specs/features/$1/.claude-workflow/milestones/<milestone>/iterations/dev_*.md
   ```

2. **Reset if needed**:
   ```bash
   tools/claude-autonomous-dev/claude-dev.sh reset $1 <milestone>
   ```

3. **Retry**:
   ```bash
   tools/claude-autonomous-dev/claude-dev.sh start $1 <milestone>
   ```

## Step 8: Final Summary

Once all milestones complete:
!`echo "=== Final Status ==="; tools/claude-autonomous-dev/claude-dev.sh status $1`

Generate summary:
!`[ -f "specs/features/$1/.claude-workflow/state/global.json" ] && echo "Completed Milestones:" && jq -r '.milestones_completed[]' specs/features/$1/.claude-workflow/state/global.json || echo "Development still in progress"`

## My Role as Orchestrator

I coordinate the bash script executions by:
1. **Analyzing dependencies** to determine execution order
2. **Launching milestone development** in the correct sequence
3. **Monitoring progress** and reacting to completions
4. **Managing parallel executions** for efficiency
5. **Handling errors** and retries as needed

The actual development work is done by the autonomous milestone agents launched via:
```bash
tools/claude-autonomous-dev/claude-dev.sh start <feature-id> <milestone>
```

Each milestone runs autonomously until completion, then I coordinate the next steps.
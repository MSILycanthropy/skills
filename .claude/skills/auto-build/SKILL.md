---
name: auto-build
description: "Decomposes a task into subtasks, gets approval, then autonomously implements each subtask with git commits, validation, and self-review. Use when asked to build a feature, implement something, or auto-build a task."
argument-hint: "[task description]"
allowed-tools:
  - Task
  - Read
  - Write
  - Edit
  - Glob
  - Grep
  - Bash
  - AskUserQuestion
---

# Auto-Build

Decomposes a task into subtasks, gets user approval, then autonomously implements each one with built-in validation and rollback via git.

## Workflow

### Phase 0: Understand

1. The task description comes from `$ARGUMENTS`.
2. Scan the codebase to gather context:
   - Read README, package.json / Cargo.toml / pyproject.toml / go.mod / Makefile (whichever exist)
   - Identify language, framework, and project structure
   - Detect test runner: check package.json `scripts.test`, look for pytest/cargo test/go test/Makefile test target
   - Detect lint/typecheck: eslint, tsc, clippy, mypy, ruff, etc.
   - Note key patterns: directory structure, naming conventions, existing architecture
3. Store this context — it feeds into every subsequent phase.

### Phase 1: Plan

1. Spawn a `build-planner` subagent using the Task tool:
   - `subagent_type`: general-purpose
   - Pass the task description AND the codebase context gathered in Phase 0
   - Include: "You are a build planning specialist. Decompose this task into 2-7 ordered subtasks. Each subtask should be a coherent, independently committable unit of change. List target files, descriptions, and dependencies between subtasks. If you need more than 7 subtasks, warn that the task may be too large and suggest how to split it."
2. Present the plan to the user.
3. **Scope guard**: if more than 7 subtasks, warn: "This task has [N] subtasks — it may be too large for a single auto-build. Consider splitting it. Continue anyway?"
4. Ask: "Does this plan look good? You can reorder subtasks, modify descriptions, or remove/add items."
5. Wait for approval. Incorporate any feedback before proceeding.

### Phase 2: Build

1. Create a git branch from the current branch:
   - Name: `claude-code/<task-slug>` (lowercase, hyphens, max 50 chars)
   - Use `git checkout -b claude-code/<task-slug>`

2. For each subtask **sequentially** (order matters):
   a. Report progress: "Starting subtask [N]/[total]: [title]"
   b. Spawn a Task agent:
      - `subagent_type`: general-purpose
      - Prompt includes: the subtask description, target files to read and modify, codebase context from Phase 0, and what previous subtasks already changed
      - Include: "Implement this subtask. Read the target files first to understand existing code. Make the changes described. Verify there are no syntax errors. Follow existing code patterns and conventions. Do NOT add excessive comments — code should be self-describing."
   c. After the agent completes, review the changes briefly
   d. Stage and commit with a descriptive message: `auto-build: [subtask title]`
   e. Report: "Completed subtask [N]/[total]: [title]"

3. If a subtask fails or produces clearly broken output, stop and report to the user rather than continuing.

### Phase 3: Validate

1. **Run tests** (if a test runner was detected in Phase 0):
   - Execute the test command
   - If tests fail, note which tests and why

2. **Run lint/typecheck** (if detected in Phase 0):
   - Execute lint/typecheck commands
   - Note any new warnings or errors

3. **Self-review**: Spawn a `build-reviewer` subagent:
   - `subagent_type`: general-purpose
   - Get the full diff: `git diff main..HEAD` (or whatever the base branch is)
   - Pass: original task description, the subtask plan, and the full diff
   - Include: "You are a build review specialist. Review this diff against the original task. Check: (1) all subtasks implemented correctly, (2) no bugs or missed edge cases, (3) code follows existing patterns, (4) nothing missing from the original task description. Return a structured review with overall assessment, per-subtask verification, and any issues found."

4. Collect all validation results.

### Phase 4: Present

1. Show the user a summary:
   ```
   ## Build Complete

   **Branch**: `claude-code/<slug>`
   **Commits**: [N] commits
   **Files changed**: [list]

   ### Test Results
   [pass/fail summary, or "no tests detected"]

   ### Lint/Type Check
   [pass/fail summary, or "not detected"]

   ### Self-Review
   [Overall assessment from build-reviewer]
   [Issues table if any]
   ```

2. Show a condensed diff: for each changed file, show a brief summary of what changed.

3. Offer options:
   - "Merge to [base branch]" — fast-forward merge the build branch
   - "Fix issues" — address specific problems from validation
   - "Discard branch" — delete the branch and return to the base branch

4. Wait for the user's decision and act on it.

## Important

- Do NOT skip the human approval step after Phase 1. The user must approve the plan before any code is written.
- Do NOT continue past a broken subtask. Stop, report, and let the user decide.
- Each subtask gets its own commit. This gives clean rollback if needed.
- The git branch isolates all changes. The user's working branch is untouched until they choose to merge.
- If no test runner or linter is detected, skip those validation steps — don't guess or install tooling.
- Keep the user informed of progress throughout Phase 2. Don't go silent during a long build.

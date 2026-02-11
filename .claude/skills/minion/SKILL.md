---
name: minion
description: "Autonomous spec-driven task agent. Takes a natural language task, runs a full pipeline (research → specify → plan → tasks → implement → review), and opens a PR. Use when asked to minion a task, run a task autonomously, or fire-and-forget a feature implementation."
argument-hint: "[task description] [--dry-run] [--skip-research] [--base <branch>] [--no-draft] [--reviewers <users>] [--label <labels>] [--forge <github|codeberg>]"
allowed-tools:
  - Task
  - Read
  - Write
  - Edit
  - Glob
  - Grep
  - Bash
  - WebSearch
  - WebFetch
  - AskUserQuestion
---

# Minion

Autonomous spec-driven implementation agent. Takes a task description, produces a spec, plan, and task breakdown, implements everything, self-reviews, and opens a PR.

The PR is the review point — no human approval gates during execution.

## Flag Parsing

Parse `$ARGUMENTS` for:
- **Task description**: Everything that isn't a flag
- `--dry-run`: Stop after Phase 4 (tasks). No implementation, no PR.
- `--skip-research`: Skip Phase 1 (research). Use when the task is straightforward.
- `--base <branch>`: Base branch for the PR (default: current branch)
- `--no-draft`: Open as a ready PR instead of draft (default: draft)
- `--reviewers <users>`: Comma-separated GitHub usernames to request review
- `--label <labels>`: Comma-separated labels to apply to the PR (GitHub only)
- `--forge <github|codeberg>`: Override auto-detected forge. Use when auto-detection picks the wrong remote.

If the task description is empty, stop and ask the user what they want to build.

## Phase 0: Setup

1. Parse flags from `$ARGUMENTS`.
2. Record the base branch (current branch, or `--base` value).
3. Detect the forge:
   - Run `git remote get-url origin` to get the remote URL.
   - If `--forge` flag is set, use that value.
   - Otherwise: `codeberg.org` in URL → `codeberg`. `github.com` in URL → `github`.
   - If neither matches, ask the user which forge they're using.
   - Store the forge type for Phase 7.
4. Scan the codebase for context:
   - Read README, package.json / Cargo.toml / pyproject.toml / go.mod / Makefile (whichever exist)
   - Identify language, framework, project structure
   - Detect test runner: check package.json `scripts.test`, look for pytest/cargo test/go test/Makefile test target
   - Detect lint/typecheck: eslint, tsc, clippy, mypy, ruff, etc.
   - Note key patterns: directory structure, naming conventions, existing architecture
5. Create a feature slug from the task description (lowercase, hyphens, max 40 chars).
6. Create the working branch: `minion/<feature-slug>`
7. Create the artifact directory: `.minion/specs/<feature-slug>/`
8. Report: "Starting minion for: [task]. Branch: minion/[slug]. Forge: [github|codeberg]"

## Phase 1: Research (skip if `--skip-research`)

1. Spawn a `research-planner` subagent using the Task tool:
   - `subagent_type`: general-purpose
   - Prompt: "You are a research planning specialist. The task is: [task description]. The codebase uses [language/framework from Phase 0]. Identify 2-4 things that need research to implement this well — unknowns, best practices, API details, library choices. For each, provide 1-2 web search queries. Return a structured research plan. If the task is completely straightforward with no unknowns, return 'NO_RESEARCH_NEEDED'."

2. If the planner returns `NO_RESEARCH_NEEDED`, skip to Phase 2.

3. For each research sub-question, spawn a `web-researcher` Task agent **in parallel**:
   - `subagent_type`: general-purpose
   - Prompt: "You are a web research specialist. Use WebSearch and WebFetch to investigate: [sub-question]. Execute these search queries: [queries]. Read the 3-5 most relevant sources. Extract key findings with source URLs and confidence levels. Never fabricate sources."

4. Collect all findings into a research summary.
5. Write findings to `.minion/specs/<feature-slug>/research.md`
6. Stage and commit: `minion: add research for <feature-slug>`

## Phase 2: Specify

1. Read the spec template from the skill's reference directory.
2. Spawn a `minion-specifier` subagent using the Task tool:
   - `subagent_type`: general-purpose
   - Prompt: Pass the task description, codebase context from Phase 0, research findings from Phase 1 (or "research skipped" if `--skip-research`), and the spec template content.
   - Include: "You are a specification specialist. Generate a complete feature spec following the template. Read relevant codebase files to ground the spec in reality. Make autonomous decisions for any ambiguities — document them in the Decisions Made section."

3. Write the spec to `.minion/specs/<feature-slug>/spec.md`
4. Stage and commit: `minion: add spec for <feature-slug>`

## Phase 3: Plan

1. Read the plan template from the skill's reference directory.
2. Spawn a `minion-planner` subagent using the Task tool:
   - `subagent_type`: general-purpose
   - Prompt: Pass the spec from Phase 2, codebase context from Phase 0, and the plan template content.
   - Include: "You are an implementation planning specialist. Generate a concrete implementation plan following the template. Read codebase files to understand existing architecture. Every file change must be listed. Architecture decisions need real alternatives."

3. Write the plan to `.minion/specs/<feature-slug>/plan.md`
4. Stage and commit: `minion: add plan for <feature-slug>`

## Phase 4: Tasks

1. Read the tasks template from the skill's reference directory.
2. Spawn a `minion-tasker` subagent using the Task tool:
   - `subagent_type`: general-purpose
   - Prompt: Pass the spec from Phase 2, the plan from Phase 3, and the tasks template content.
   - Include: "You are a task breakdown specialist. Generate a phased, ordered task list following the template. Each task is one commit. Mark parallelizable tasks with [P]. 2-12 tasks total."

3. Write the task list to `.minion/specs/<feature-slug>/tasks.md`
4. Stage and commit: `minion: add tasks for <feature-slug>`

**If `--dry-run`**: Stop here. Report: "Dry run complete. Artifacts in .minion/specs/[slug]/. Branch: minion/[slug]. Review spec.md, plan.md, and tasks.md before running without --dry-run."

## Phase 5: Implement

Parse the task list from Phase 4. For each task **sequentially** (respect dependency order; tasks marked `[P]` within the same phase can be spawned in parallel):

1. Report progress: "Implementing T-[XXX]: [title] ([N]/[total])"

2. Spawn a Task agent:
   - `subagent_type`: general-purpose
   - Prompt includes:
     - The task description and target files
     - Codebase context from Phase 0
     - The full spec (so the agent understands requirements)
     - What previous tasks already changed
   - Include: "Implement this task. Read the target files first. Follow existing code patterns. Do NOT add excessive comments. Verify no syntax errors. If you encounter an issue that blocks implementation, describe it clearly in your response."

3. Check the agent's response for success/failure.

4. **On failure**: Retry up to 2 times with the error context appended to the prompt. If still failing after 2 retries, stage whatever partial work exists, commit with `minion: partial — [task title]`, and continue to the next task. Track failures.

5. **On success**: Stage all changes and commit with the commit message from the task list.

6. Report: "Completed T-[XXX]: [title]"

After all tasks, report any failures: "Completed [N]/[total] tasks. [M] tasks had issues: [list]."

## Phase 6: Self-Review

1. Get the full diff: `git diff <base-branch>..HEAD` (excluding `.minion/` directory changes).

2. Spawn a `build-reviewer` subagent using the Task tool:
   - `subagent_type`: general-purpose
   - Prompt: Pass the original task description, the spec, the task list, and the full diff.
   - Include: "You are a build review specialist. Review this diff against the spec. Check: (1) all requirements implemented, (2) no bugs or missed edge cases, (3) code follows existing patterns, (4) nothing missing. Return a structured review with overall assessment (PASS/PASS WITH NOTES/NEEDS FIXES), per-task verification, and issues found."

3. If the review returns **NEEDS FIXES** with CRITICAL or HIGH severity issues:
   - For each critical/high issue, spawn a Task agent to fix it.
   - Stage and commit fixes: `minion: fix — [issue description]`
   - Do NOT re-run the full review. One round of fixes is enough.

4. Write the review to `.minion/specs/<feature-slug>/review.md`
5. Stage and commit: `minion: add review for <feature-slug>`

## Phase 7: PR

1. Push the branch: `git push -u origin minion/<feature-slug>`

2. Build the PR description:
   ```
   ## Summary
   [2-3 bullets from the spec overview]

   ## Spec
   [Link to .minion/specs/<feature-slug>/spec.md on the branch]

   ## Changes
   [File change summary from the plan]

   ## Self-Review
   [Overall assessment from Phase 6]
   [Issues table if any remain]

   ## Artifacts
   All spec artifacts are in `.minion/specs/<feature-slug>/`:
   - `spec.md` — Feature specification
   - `plan.md` — Implementation plan
   - `tasks.md` — Task breakdown
   - `review.md` — Self-review results
   [- `research.md` — Research findings (if research was run)]

   🤖 Generated with [Claude Code](https://claude.com/claude-code) `/minion`
   ```

3. Open the PR based on the forge detected in Phase 0:

   ### GitHub

   - Use `gh pr create` with appropriate flags.
   - Default: draft PR. Use `--no-draft` for ready PR.
   - Add reviewers if `--reviewers` flag was set.
   - Add labels if `--label` flag was set.

   ### Codeberg

   - Requires `CODEBERG_TOKEN` environment variable. If not set, fail with:
     "CODEBERG_TOKEN not set. Generate one at Codeberg → Settings → Applications → Access Tokens (needs `write:repository` scope), then `export CODEBERG_TOKEN=your-token` in your shell."
   - Extract owner and repo from the remote URL:
     - HTTPS: `https://codeberg.org/{owner}/{repo}.git` → parse owner/repo
     - SSH: `git@codeberg.org:{owner}/{repo}.git` → parse owner/repo
   - Strip `.git` suffix if present.
   - For draft PRs (default): prefix the title with `WIP: `. Codeberg treats `WIP:` titles as drafts. If `--no-draft`, use the title as-is.
   - Create the PR via curl:
     ```bash
     curl -s -X POST "https://codeberg.org/api/v1/repos/{owner}/{repo}/pulls" \
       -H "Authorization: token $CODEBERG_TOKEN" \
       -H "Content-Type: application/json" \
       -d '{
         "title": "[title]",
         "body": "[PR description]",
         "head": "minion/<feature-slug>",
         "base": "[base-branch]"
       }'
     ```
   - Parse the response JSON to extract the PR URL (field: `html_url`).
   - If `--reviewers` was set, the Codeberg API doesn't support review requests on create. Log a note: "Codeberg doesn't support assigning reviewers via API on PR creation. Assign reviewers manually."
   - `--label` is not supported on Codeberg (requires label IDs, not names). If set, log: "Labels are not supported for Codeberg PRs. Apply labels manually."

4. Report the PR URL to the user.

## Important

- No human approval gates. The PR is the review point. Use `--dry-run` to review artifacts before implementation.
- Failed tasks get 2 retries with error context. After that, commit partial work and continue. Don't block the entire pipeline on one task.
- All artifacts go in `.minion/specs/<feature-slug>/` and are committed to the branch. This creates a traceable record of the agent's reasoning.
- Reuse existing agents: `research-planner` and `web-researcher` for Phase 1, `build-reviewer` for Phase 6. The 3 new agents (`minion-specifier`, `minion-planner`, `minion-tasker`) handle the spec pipeline.
- The feature slug must be consistent across all phases — it's used for the branch name, artifact directory, and PR.
- Keep the user informed with progress reports at the start and end of each phase.

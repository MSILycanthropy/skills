---
name: code-review
description: Review code changes, diffs, outstanding changes, or modified files. Use when asked to review, check, or analyze code quality, changes, uncommitted work, or changes since diverging from a branch (e.g., main).
---

# Code Review Skill

Run a comprehensive code review on diffs, uncommitted changes, or modified files.

## When to Use

- User asks to review code, changes, or a diff
- User asks to check code quality on recent or uncommitted work
- User asks to review changes since diverging from a branch (e.g., "review my changes against main")
- User asks to review a PR, MR, or set of modified files

## Process

### Step 1: Determine the Scope

Figure out what to review. Ask if unclear, otherwise infer from context:

| User says                         | Scope                                       |
| --------------------------------- | ------------------------------------------- |
| "review my changes"               | Uncommitted changes (`git diff`)            |
| "review against main"             | Changes since main (`git diff main...HEAD`) |
| "review this file"                | Specific file(s) mentioned                  |
| "review the last commit"          | Last commit (`git diff HEAD~1`)             |
| "review the PR" / "review the MR" | Changes on current branch vs base branch    |

### Step 2: Gather the Diff

Use the appropriate git command to get the diff. For example:

```bash
# Uncommitted changes (staged + unstaged)
git diff HEAD

# Against a branch
git diff main...HEAD

# Last N commits
git diff HEAD~N

# Specific file
git diff -- path/to/file
```

Also read the full content of changed files when you need surrounding context to understand the change.

### Step 3: Perform the Review

Analyze the diff against the following checks. Skip checks that aren't relevant to the language or changes.

#### Checks to Perform

| Check                   | What to look for                                                                |
| ----------------------- | ------------------------------------------------------------------------------- |
| **Bugs & Logic**        | Off-by-one errors, null/undefined access, race conditions, wrong comparisons    |
| **Security**            | Injection risks, hardcoded secrets, missing auth checks, unsafe deserialization |
| **Performance**         | N+1 queries, unnecessary loops, missing indexes, large allocations in hot paths |
| **Error Handling**      | Swallowed exceptions, missing error cases, unhelpful error messages             |
| **Type Safety**         | Implicit `any`, unsafe casts, missing null checks, wrong generics               |
| **API Design**          | Breaking changes, inconsistent naming, missing validation, wrong HTTP methods   |
| **Concurrency**         | Data races, missing locks, deadlock potential, unsafe shared state              |
| **Resource Management** | Leaks (connections, file handles, listeners), missing cleanup                   |
| **Code Clarity**        | Confusing names, overly complex logic, missing comments on non-obvious code     |
| **Duplication**         | Copy-pasted logic that should be extracted, repeated patterns                   |
| **Testing**             | Missing tests for new logic, broken test assertions, inadequate coverage        |
| **Best Practices**      | Language/framework anti-patterns, deprecated API usage, style violations        |

### Step 4: Report

Display results in this **exact format**:

---

## Code Review Results

**X issues found across Y checks**

| #   | Severity     | Source       | Location      | Problem            | Why              | Fix           |
| --- | ------------ | ------------ | ------------- | ------------------ | ---------------- | ------------- |
| 1   | **CRITICAL** | Bug & Logic  | `file.ts:42`  | Brief problem desc | Why this matters | Suggested fix |
| 2   | **HIGH**     | Security     | `auth.ts:18`  | Brief problem desc | Why this matters | Suggested fix |
| 3   | **MEDIUM**   | Performance  | `query.ts:91` | Brief problem desc | Why this matters | Suggested fix |
| 4   | **LOW**      | Code Clarity | `utils.ts:7`  | Brief problem desc | Why this matters | Suggested fix |

After displaying the table, write a summary using the bundled `scripts/review_summary.sh` script to render colored output in the terminal:

```bash
bash .claude/skills/code-review/scripts/review_summary.sh \
  --critical <count> \
  --high <count> \
  --medium <count> \
  --low <count> \
  --checks "Bugs & Logic:pass,Security:pass,Error Handling:pass,Concurrency:skip:no concurrent code"
```

This renders a colored severity breakdown and check list. Pass counts of 0 for severities with no issues. For each check, use `pass` if it was run or `skip:<reason>` if it was skipped.

---

#### Severity Definitions

- **CRITICAL** — Will cause bugs, data loss, or security vulnerabilities. Must fix before merge.
- **HIGH** — Likely to cause problems. Strongly recommended to fix.
- **MEDIUM** — Code smell or maintainability concern. Should fix.
- **LOW** — Nitpick or style suggestion. Nice to fix.

Sort issues by severity (CRITICAL first, then HIGH, MEDIUM, LOW). Number issues sequentially starting from 1.

### Step 5: Offer to Fix

After displaying the table, always ask:

> Would you like me to fix any of these issues? (e.g., "Fix issue #1" or "Fix issues #2 and #3")

If the user asks to fix issues, apply the fixes directly to the files and briefly summarize what you changed.

## Clean Review

If no issues are found, say:

> ## Code Review Results
>
> **0 issues found across Y checks**
>
> Looks clean. No issues found across Y checks.
>
> **Checks performed:**
> _(list all checks as above)_

## Examples

- "Review my uncommitted changes"
- "Code review against main"
- "Check the last 3 commits for issues"
- "Review src/auth/ for security issues"
- "Review this PR before I merge"

# Plan Template

Generate an implementation plan following this exact structure. The plan must be grounded in the actual codebase — read files, don't guess.

```markdown
# Plan: [Feature Name]

## Summary
[2-3 sentences: what will be built, the high-level approach, and key technical choices]

## Technical Context
- **Language**: [detected from codebase]
- **Framework**: [detected or "none"]
- **Package manager**: [detected]
- **Test runner**: [detected command or "none detected"]
- **Lint/typecheck**: [detected or "none detected"]
- **Key patterns**: [1-3 notable conventions from the codebase]
- **Relevant existing code**: [files/modules this feature interacts with]

## Architecture Decisions

### AD-001: [Decision Title]
- **Context**: [Why this decision is needed]
- **Decision**: [What we're doing]
- **Alternatives considered**:
  - [Alternative A] — [why not chosen]
  - [Alternative B] — [why not chosen]

### AD-002: [Decision Title]
[Same structure — include as many as needed]

## File Changes

### New Files
| File | Purpose |
|------|---------|
| `path/to/file.ext` | [What it contains] |

### Modified Files
| File | Changes |
|------|---------|
| `path/to/file.ext` | [What changes and why] |

## Dependencies
- **New dependencies**: [packages to add, or "none"]
- **Existing dependencies used**: [relevant packages already in the project]

## Risks

| Risk | Impact | Mitigation |
|------|--------|------------|
| [What could go wrong] | [Consequence] | [How to handle it] |

## Out of Scope
- [Things explicitly NOT included in this implementation]
```

## Rules

- The Technical Context section must be based on actual file reads, not assumptions.
- Architecture decisions are only needed when there's a genuine choice. Don't create ADs for obvious decisions.
- File Changes must list every file that will be created or modified — the task breakdown depends on this.
- Keep the plan concrete. "Implement the feature" is not a plan. "Add a GET /health endpoint in src/routes/health.ts that returns { status: 'ok' }" is.
- Risks should be real, not hypothetical. Focus on things likely to cause issues during implementation.
- 1-4 architecture decisions for a typical feature. If you need more, the feature may be too large.

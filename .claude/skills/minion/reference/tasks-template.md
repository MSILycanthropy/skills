# Tasks Template

Generate a phased task breakdown following this exact structure. Each task must be independently committable.

```markdown
# Tasks: [Feature Name]

## Phase 1: [Phase Name — e.g., "Foundation", "Core Logic"]

### T-001: [Task Title]
- **Files**: `path/to/file1.ext`, `path/to/file2.ext`
- **Description**: [Specific implementation instructions — what to create/modify and how]
- **Requirements**: FR-001, FR-002
- **Depends on**: none
- **Commit message**: `[type]: [description]`

### T-002: [Task Title] `[P]`
- **Files**: `path/to/file.ext`
- **Description**: [Specific instructions]
- **Requirements**: FR-003
- **Depends on**: T-001
- **Commit message**: `[type]: [description]`

## Phase 2: [Phase Name — e.g., "Integration", "Testing"]

### T-003: [Task Title]
- **Files**: `path/to/file.ext`
- **Description**: [Specific instructions]
- **Requirements**: FR-004, NFR-001
- **Depends on**: T-001, T-002
- **Commit message**: `[type]: [description]`

## Task Summary

| ID | Task | Phase | Depends On | Parallel |
|----|------|-------|------------|----------|
| T-001 | [Title] | 1 | — | — |
| T-002 | [Title] | 1 | T-001 | [P] |
| T-003 | [Title] | 2 | T-001, T-002 | — |
```

## Rules

- 2-12 tasks total. Fewer for simple features, more for complex ones. If you need more than 12, the feature is too large.
- Every task must map to at least one spec requirement (FR-xxx or NFR-xxx).
- Tasks within the same phase can be marked `[P]` (parallel) if they have no interdependencies and don't modify the same files.
- Tasks across phases are always sequential — Phase 2 starts after Phase 1 completes.
- Each task gets its own commit. The commit message should follow conventional commits: `feat:`, `fix:`, `refactor:`, `test:`, `docs:`.
- The Description field should be specific enough that an implementation agent can execute it without ambiguity. Include function signatures, endpoint paths, data structures — whatever the implementer needs.
- List ALL files the task will touch in the Files field. The implementer reads these first.
- Include the Task Summary table at the end — it gives a quick overview of the dependency graph.
- If tests exist in the project, include a testing task (usually last phase).

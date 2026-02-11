# Spec Template

Generate a spec following this exact structure. Fill every section — make autonomous decisions where the task description is ambiguous.

```markdown
# Spec: [Feature Name]

## Overview
[2-3 sentence description of what this feature does and why it exists]

## User Scenarios

### Scenario 1: [Name]
**As a** [role]
**I want** [action]
**So that** [outcome]

#### Acceptance Criteria
- **Given** [precondition]
  **When** [action]
  **Then** [expected result]
- **Given** [precondition]
  **When** [action]
  **Then** [expected result]

### Scenario 2: [Name]
[Same structure — add as many scenarios as the feature requires]

## Functional Requirements

| ID | Requirement | Priority | Scenario |
|----|-------------|----------|----------|
| FR-001 | [Specific, testable requirement] | Must | S1 |
| FR-002 | [Specific, testable requirement] | Must | S1 |
| FR-003 | [Specific, testable requirement] | Should | S2 |

Priority: Must (blocks launch) / Should (important but deferrable) / Could (nice to have)

## Non-Functional Requirements

| ID | Requirement | Category |
|----|-------------|----------|
| NFR-001 | [Requirement] | Performance |
| NFR-002 | [Requirement] | Security |

Categories: Performance, Security, Compatibility, Accessibility, Reliability

## Decisions Made
[List any ambiguities in the task description that you resolved autonomously, with reasoning]
- **Decision**: [what you decided]
  **Reasoning**: [why]

## Success Criteria
- [ ] [Measurable criterion that proves the feature works]
- [ ] [Another criterion]
- [ ] All acceptance criteria pass
- [ ] No regressions in existing functionality
```

## Rules

- Every functional requirement must map to at least one scenario.
- Write acceptance criteria that are directly testable — no vague language.
- If the task description is ambiguous, make a decision and document it in "Decisions Made." Do NOT leave placeholders or ask questions.
- Keep requirements atomic: one requirement = one testable behavior.
- 3-8 functional requirements for a typical feature. If you need more than 12, the feature may be too large.
- Non-functional requirements are optional — only include them when the feature has real performance, security, or compatibility concerns.

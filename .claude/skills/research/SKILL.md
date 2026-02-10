---
name: research
description: "Conducts technical deep research on implementation approaches, best practices, and architecture decisions. Use when the user says 'research [topic]', 'look into [topic]', 'what are the best ways to implement [topic]', or needs to understand tradeoffs between technical approaches."
argument-hint: "[topic to research]"
isolatedContext: true
allowed-tools:
  - WebSearch
  - WebFetch
  - Read
  - Glob
  - Grep
---

# Technical Deep Research

A 5-phase research system optimized for technical deep dives during active development. Produces practical, implementation-focused research with code examples and tradeoff analysis.

## When to Use

| Need | Use This? |
|------|-----------|
| Quick API lookup | No — just search |
| "How should we implement X?" | Yes |
| "What are the tradeoffs between A and B?" | Yes |
| "Best practices for X in our stack" | Yes |
| "How do other projects solve X?" | Yes |

## The System

```
PHASE 0: Classify & Scan Codebase
    ↓
PHASE 1: Plan (subquestions + search strategy)
    ↓
PHASE 2: Research (web search + source reading)
    ↓
PHASE 3: Synthesize (findings + code examples)
    ↓
PHASE 4: Write (structured markdown to docs/research/)
```

Say: **"research [topic]"** or **"/research [topic]"**

The system automatically:
1. Scans the current codebase for context (language, patterns, dependencies)
2. Plans targeted research queries
3. Searches and reads multiple sources
4. Synthesizes findings with practical recommendations
5. Writes a markdown report to `docs/research/`

---

## Phase 0: Classify & Scan Codebase

### Classify the research type:

| Type | Example | Depth |
|------|---------|-------|
| **Quick Compare** | "research: tree-walking vs bytecode interpreters" | 2-3 sources |
| **Implementation Guide** | "research: how to implement garbage collection" | 5-8 sources |
| **Architecture Decision** | "research: best approach for our type system" | 8-12 sources |

### Scan the codebase:

Before searching the web, understand the project:

1. **Read key files**: Look at the project root for README, Cargo.toml/package.json/go.mod/etc.
2. **Identify the stack**: Language, framework, build system, key dependencies
3. **Understand current architecture**: Grep for relevant patterns, read related source files
4. **Note constraints**: What's already built that the research needs to work with?

This context is critical — generic research is far less useful than research that accounts for what's already in the codebase.

---

## Phase 1: Plan

Break the topic into 3-5 targeted subquestions. For each:

- Write 1-2 specific search queries (short, 2-5 words)
- Identify what type of source would be most valuable
- Note what you already know vs. what needs verification

**Source priority for technical research:**
1. Official documentation and specs
2. Source code of well-known projects (reference implementations)
3. Technical blog posts from practitioners (not SEO content)
4. Academic papers (for algorithms/data structures)
5. Conference talks and their accompanying materials
6. Stack Overflow / GitHub issues (for gotchas and edge cases)

**Avoid:** Tutorial mills, AI-generated content farms, outdated blog posts (check dates)

---

## Phase 2: Research

Execute searches and read sources:

- Start broad, then narrow based on what you find
- **Always fetch and read full pages** — search snippets are not enough
- For each useful source, extract:
  - Key claims or recommendations
  - Code examples or pseudocode
  - Performance characteristics or benchmarks
  - Known pitfalls or failure modes
- Track contradictions — if sources disagree, note both positions

### Source quality check:
- Is this from someone who has actually built this? (practitioner > theorist)
- Is it recent enough to be relevant?
- Does it show real code or just hand-wave?
- Do multiple independent sources agree?

---

## Phase 3: Synthesize

Organize findings into a coherent picture:

1. **Approaches**: List the distinct approaches found, with clear names
2. **Tradeoffs**: For each approach, what does it optimize for and what does it sacrifice?
3. **Fit assessment**: Given our codebase and constraints, which approaches are viable?
4. **Code examples**: Adapt examples to our language/stack where possible
5. **Recommendation**: State a clear recommendation with reasoning

### Handling uncertainty:
- If the answer is "it depends" — specify what it depends on
- If sources conflict — present both sides and explain the disagreement
- If you couldn't find good info — say so, don't fill gaps with speculation

---

## Phase 4: Write

Output a markdown file to `docs/research/` with this structure:

```
docs/research/YYYY-MM-DD-topic-name.md
```

### Report template:

````markdown
# Research: [Topic Name]
> Date: [YYYY-MM-DD]
> Type: [Quick Compare | Implementation Guide | Architecture Decision]
> Project context: [language, key constraints]

## TL;DR
[2-3 sentence summary of the key finding/recommendation]

## Context
[What prompted this research, what we need to decide or understand]

## Our Codebase
[Relevant details about current implementation, constraints, dependencies]

## Approaches

### Approach 1: [Name]
[Description, how it works, where it's used in practice]

**Pros:**
- ...

**Cons:**
- ...

**Example:**
```[language]
// Adapted to our stack
```

### Approach 2: [Name]
[Same structure]

## Tradeoffs Summary
| | Approach 1 | Approach 2 | Approach 3 |
|---|---|---|---|
| Complexity | ... | ... | ... |
| Performance | ... | ... | ... |
| Maintainability | ... | ... | ... |
| Fit with our codebase | ... | ... | ... |

## Recommendation
[Clear recommendation with reasoning. Reference specific aspects of our codebase.]

## Open Questions
[Things that couldn't be fully resolved, might need experimentation]

## Sources
[Numbered list of sources with URLs and brief description of what each contributed]
````

---

## Key Principles

1. **Codebase-first**: Always scan the project before searching the web. Generic advice is cheap; contextual advice is gold.
2. **Practitioner sources**: Prefer people who've built the thing over people who've written about the thing.
3. **Show code**: Every approach should have a concrete code example, ideally adapted to the project's language and style.
4. **Honest uncertainty**: "I couldn't find reliable info on this" is more useful than confident speculation.
5. **Actionable output**: The report should help make a decision or start implementation, not just catalog information.
6. **Timestamped files**: Research gets stale. Dating the files makes it easy to know when to re-research.

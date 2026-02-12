---
name: technical-planning
description: "Creates research-informed technical roadmaps and implementation plans. Investigates approaches, evaluates tradeoffs, and produces structured planning documents with architecture decisions, phased breakdowns, and dependency graphs. Use when asked to plan an implementation, create a technical roadmap, or figure out how to build something."
argument-hint: "[what you want to build or implement]"
allowed-tools:
  - Task
  - Read
  - Write
  - Glob
  - Grep
  - AskUserQuestion
  - WebSearch
  - WebFetch
  - Bash
---

# Technical Planning

Creates implementation roadmaps through a research → architect → decompose pipeline with human approval at key decision points. Produces a directory of planning documents whose structure is driven by the content.

## Workflow

### Phase 0: Scope

1. The implementation goal comes from `$ARGUMENTS`.
2. Scan the codebase for context:
   - Read README, package.json / Cargo.toml / pyproject.toml / go.mod / Makefile (whichever exist)
   - Identify language, framework, project structure, key dependencies
   - Note existing architecture, patterns, and constraints
   - If this is a greenfield project with no codebase, note that — the plan should account for initial setup.
3. Ask the user:
   - What directory to save the planning output in. Suggest `docs/plans/YYYY-MM-DD-<goal-slug>/` as a default.
   - Any constraints they want to declare upfront: stack preferences, timeline, scale requirements, things that are non-negotiable.
4. Store all context — it feeds into every subsequent phase.

### Phase 1: Research

1. Spawn a `research-planner` subagent using the Task tool:
   - `subagent_type`: general-purpose
   - Pass the implementation goal AND codebase context as the prompt
   - Include: "You are a technical research planner. Given this implementation goal and codebase context, identify 3-5 areas that need investigation before an implementation plan can be made. These should cover: viable architectural approaches, key technology/library choices, known pitfalls or hard problems in this domain, and any integration concerns with the existing codebase. For each area, provide 2-3 web-search-optimized queries. Add year qualifiers (2025, 2026) where recency matters."
2. Present the research plan to the user.
3. Ask: "Does this research plan cover the right areas? You can add angles, remove ones that aren't relevant, or flag specific concerns."
4. Wait for approval. Incorporate feedback before proceeding.

### Phase 2: Investigate

1. For EACH research area in the approved plan, spawn a separate Task agent **in parallel**:
   - `subagent_type`: general-purpose
   - Pass the research area, its search queries, AND the codebase context as the prompt
   - Include: "You are a technical investigator. Use WebSearch and WebFetch to research this area for the purpose of informing an implementation plan. Focus on: what approaches exist in practice, what tools/libraries are mature and well-maintained, what problems people actually hit when building this, and what the current best practices are. For each finding, note the source URL and your confidence level (high/medium/low). Prioritize practitioner sources — people who have built this over people who have written about it. Never fabricate sources."
2. Launch all investigators concurrently by including all Task calls in a single response.
3. Collect all findings once all agents complete.

### Phase 3: Architect

1. Spawn an `architect` subagent using the Task tool:
   - `subagent_type`: general-purpose
   - Pass ALL collected findings, the implementation goal, AND the codebase context as the prompt
   - Include: "You are a software architect. Based on these research findings and codebase context, propose 1-3 viable architectural approaches for this implementation. For each approach: (1) describe the high-level architecture, (2) list the key technology choices it implies, (3) explain what it optimizes for and what it sacrifices, (4) note how well it fits the existing codebase (if any), (5) flag risks or unknowns. If one approach is clearly superior, say so and explain why. If there are genuine tradeoffs, present them honestly. Do NOT pad options — if there's really only one good approach, just present that one."
2. Present the architectural options to the user.
3. Ask: "Which direction do you want to go? You can also mix elements from different approaches or add constraints."
4. Wait for the user's decision. This is the critical decision point — everything downstream builds on it.

### Phase 4: Decompose

1. Spawn a `decomposer` subagent using the Task tool:
   - `subagent_type`: general-purpose
   - Pass the chosen architecture, ALL research findings, the implementation goal, AND the codebase context as the prompt
   - Include: "You are an implementation planner. Break down this architecture into ordered implementation phases. These are NOT individual code tasks — they are logical milestones that represent meaningful progress. Each phase should be independently valuable (the system works at the end of each phase, even if incomplete). For each phase, describe: (1) the goal — what's true when this phase is done, (2) what gets built or changed, (3) key technical decisions within this phase, (4) dependencies on prior phases, (5) risks or hard problems likely to surface here, (6) open questions that need answers before or during this phase. Order phases so that foundational work comes first and each phase builds on the last. If a phase is large, note that it could be decomposed further."

### Phase 5: Synthesize & Write

1. Spawn a `plan-synthesizer` subagent using the Task tool:
   - `subagent_type`: general-purpose
   - Pass the implementation goal, codebase context, chosen architecture, research findings, and phase decomposition as the prompt
   - Include: "You are a technical planning synthesizer. Produce a set of markdown documents for an implementation roadmap. You decide the document structure — let the content drive it. Some plans need one detailed document; others need an index with separate deep-dives per phase or per architectural concern.

     **Every plan needs an index document (index.md)** that contains at minimum:
     - The implementation goal and key constraints
     - The architectural decision and why it was chosen (with alternatives considered)
     - A high-level phase overview with links to detail documents (if any)
     - A dependency graph as a Mermaid diagram showing how phases relate
     - A risk register: what could go wrong, likelihood, impact, mitigation
     - Open questions that still need answers
     - A consolidated sources section

     **Detail documents** (if warranted) should cover whatever structure makes sense — per-phase breakdowns, technology evaluations, integration guides, etc. You decide.

     Format your response as a series of clearly labeled document blocks:
     ```
     === DOCUMENT: index.md ===
     (content)
     === DOCUMENT: some-topic.md ===
     (content)
     ```

     Requirements: (1) Every claim about a technology or approach should cite its source with a footnote. (2) Mermaid diagrams where they clarify relationships or flows — keep them under 15 nodes. (3) The index should stand alone as a useful plan — someone who only reads the index should be able to understand the full roadmap. (4) Be specific and actionable — vague plans are useless. Reference actual libraries, actual patterns, actual file paths in the existing codebase where relevant."

2. Parse the synthesizer's response into separate documents.

### Phase 6: Review

1. Spawn a `plan-reviewer` subagent using the Task tool:
   - `subagent_type`: general-purpose
   - Pass ALL synthesized documents, the research findings, AND the original goal as the prompt
   - Include: "You are a technical plan reviewer. Review these planning documents for: (1) Gaps — are there phases or concerns that are missing? Could someone actually follow this plan? (2) Ordering issues — are dependencies correct? Is anything out of sequence? (3) Unsupported claims — are technology recommendations backed by the research findings? (4) Risks — are there risks not captured in the risk register? (5) Feasibility — does anything seem unrealistic given the codebase and constraints? (6) Broken cross-references between documents. Return a list of issues found. If everything checks out, say so."
2. If the reviewer flags issues, fix them in the document content before writing.

### Phase 7: Write

1. Create the output directory (use `mkdir -p` via Bash).
2. Write each document to the output directory.
3. Show the user a manifest: goal, output directory, list of files produced with brief descriptions, and any open questions that surfaced during planning.
4. Suggest next steps — this might be "use auto-build to implement Phase 1" or "resolve these open questions first" depending on the plan's state.

## Important

- Do NOT skip the approval gates after Phase 1 (research plan) and Phase 3 (architecture decision). The user must shape the direction before you invest in decomposition.
- Research is in service of planning, not knowledge. Investigators should focus on "can we build this and how" not "here is everything known about this topic."
- Phases in the decomposition are milestones, not tasks. Each should represent meaningful, demonstrable progress — not a single commit or file change.
- If the implementation goal is small enough that it doesn't need phases (e.g., "add a logout button"), say so. Not everything needs a roadmap. Suggest using `auto-build` instead.
- Use today's date (from system context) for the directory name.
- The synthesizer decides the document structure. Don't prescribe how many detail files or what they're named.

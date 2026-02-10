---
name: deep-researching
description: "Conducts deep multi-phase research on a topic using parallel web search and produces a structured markdown report with Mermaid diagrams and cited sources. Use when asked to deeply research a topic, investigate a subject thoroughly, or produce a research report."
argument-hint: "[research topic]"
allowed-tools:
  - Task
  - Read
  - Write
  - Glob
  - AskUserQuestion
  - WebSearch
  - WebFetch
---

# Deep Research

Conducts structured research on a topic through a plan → search → synthesize pipeline with human approval between phases.

## Workflow

### Phase 0: Setup

1. The research topic comes from `$ARGUMENTS`.
2. Ask the user where to save the output file. Suggest `docs/research/YYYY-MM-DD-<topic-slug>.md` in the current project as a default.

### Phase 1: Plan

1. Spawn a `research-planner` subagent using the Task tool:
   - `subagent_type`: Use a general-purpose agent
   - Pass the full topic as the prompt
   - Include this instruction in the prompt: "You are a research planning specialist. Decompose this topic into 3-5 non-overlapping sub-questions, each with 2-3 web-search-optimized queries. Return a structured research plan. Cover: background/definitions, current state, key debates/tradeoffs, and practical implications. Add year qualifiers (2025, 2026) to queries where recency matters."
2. Present the plan to the user.
3. Ask: "Does this plan look good? You can modify sub-questions, add angles, or remove ones that aren't relevant."
4. Wait for approval. Incorporate any feedback before proceeding.

### Phase 2: Research

1. For EACH sub-question in the approved plan, spawn a separate Task agent **in parallel**:
   - `subagent_type`: Use a general-purpose agent
   - Pass the sub-question AND its search queries as the prompt
   - Include this instruction: "You are a web research specialist. Use WebSearch and WebFetch to investigate this sub-question. Execute each search query, read the 3-5 most relevant sources, and extract structured findings. For each finding, note the source title, URL, and confidence level (high/medium/low). Note any conflicts between sources or gaps in coverage. Never fabricate sources."
2. Launch all researchers concurrently by including all Task calls in a single response.
3. Collect all findings once all agents complete.

### Phase 3: Synthesize

1. Spawn a `research-synthesizer` subagent using the Task tool:
   - `subagent_type`: Use a general-purpose agent
   - Pass ALL collected findings plus the original topic as the prompt
   - Include this instruction: "You are a research synthesis specialist. Produce a cohesive markdown report organized by THEME (not by sub-question). Requirements: (1) Every factual claim MUST have a GitHub-style footnote citation using [^N] inline and [^N]: Author. Title. Source, Date. URL in a Sources section at the end. (2) Include 1-3 Mermaid diagrams where they genuinely clarify relationships or flows — keep them under 12 nodes. (3) Start with a TL;DR, then Background, then thematic sections, then Tradeoffs/Open Questions, then Sources. (4) Weigh high-confidence findings more heavily. Flag where evidence is weak."
2. Receive the synthesized report.

### Phase 4: Write

1. Write the report to the output path agreed on in Phase 0.
2. Show the user a brief summary: topic, number of sources cited, sections produced, and the file path.
3. Mention they can view it with the VS Code markdown preview (Mermaid extension) or push to GitHub for native rendering.

## Important

- Do NOT skip the human approval step after Phase 1. The whole point is to let the user shape the research before spending tokens on search.
- If a researcher agent returns mostly low-confidence findings or significant gaps, note this when presenting results — the user may want to add follow-up queries.
- Use today's date (from system context) for the filename and report header.

---
name: deep-researching
description: "Conducts deep multi-phase research on a topic using parallel web search and produces a set of structured markdown documents — a summary index and detailed thematic deep-dives — with Mermaid diagrams and cited sources. Use when asked to deeply research a topic, investigate a subject thoroughly, or produce a research report."
argument-hint: "[research topic]"
allowed-tools:
  - Task
  - Read
  - Write
  - Glob
  - AskUserQuestion
  - WebSearch
  - WebFetch
  - Bash
---

# Deep Research

Conducts structured research on a topic through a plan → search → synthesize pipeline with human approval between phases. Produces a directory of documents: a summary index and detailed thematic deep-dives.

## Workflow

### Phase 0: Setup

1. The research topic comes from `$ARGUMENTS`.
2. Ask the user what directory to save the research output in. Suggest `docs/research/YYYY-MM-DD-<topic-slug>/` in the current project as a default.

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

### Phase 3: Gap Analysis

1. Spawn a `gap-analyst` subagent using the Task tool:
   - `subagent_type`: Use a general-purpose agent
   - Pass ALL collected findings plus the original topic as the prompt
   - Include this instruction: "You are a research gap analyst. Review these research findings and identify 0-3 critical gaps, contradictions, or weak areas that need follow-up investigation. For each gap, provide a specific sub-question and 1-2 targeted search queries. If the findings are comprehensive and consistent, return an empty gap list. Be selective — only flag gaps that would materially weaken the final report."
2. If the gap analyst identifies gaps, spawn targeted follow-up researchers **in parallel** (same format as Phase 2, but with the gap-specific queries).
3. Merge follow-up findings into the main findings set.

### Phase 4: Synthesize

1. Spawn a `research-synthesizer` subagent using the Task tool:
   - `subagent_type`: Use a general-purpose agent
   - Pass ALL collected findings (including any follow-up findings) plus the original topic as the prompt
   - Include this instruction: "You are a research synthesis specialist. Produce a set of markdown documents for a research report. You will output TWO types of content, clearly separated:

     **INDEX DOCUMENT (index.md):**
     A summary document with: TL;DR, Background, a thematic overview section that summarizes each major theme with a link to its detail document (use relative links like `./theme-slug.md`), Tradeoffs/Open Questions, and a consolidated Sources section. Include 1-2 Mermaid diagrams where they genuinely clarify high-level relationships or flows — keep them under 12 nodes.

     **DETAIL DOCUMENTS:**
     For each major theme you identify, produce a separate detailed document. You decide how many and what they cover based on the research — let the findings drive the structure. Each detail document should have: a clear title, deep-dive content organized logically, GitHub-style footnote citations ([^N] inline, [^N]: Author. Title. Source, Date. URL in a Sources section at the end), and 0-2 Mermaid diagrams where they add clarity. Use descriptive kebab-case filenames (e.g., `performance-tradeoffs.md`, `security-model.md`).

     Format your response as a series of clearly labeled document blocks:
     ```
     === DOCUMENT: index.md ===
     (content)
     === DOCUMENT: some-theme.md ===
     (content)
     ```

     Requirements: (1) Every factual claim MUST have a footnote citation. (2) Weigh high-confidence findings more heavily. Flag where evidence is weak. (3) Organize by THEME, not by sub-question. (4) The index should stand alone as a useful summary — someone who only reads the index should get the key takeaways."
2. Parse the synthesizer's response into separate documents.

### Phase 5: Review

1. Spawn a `research-reviewer` subagent using the Task tool:
   - `subagent_type`: Use a general-purpose agent
   - Pass ALL the synthesized documents AND the original research findings as the prompt
   - Include this instruction: "You are a research review specialist. Cross-check these documents against the source findings. Flag: (1) Claims that aren't supported by any source finding. (2) Citations that don't match what the source actually said. (3) Statistics, dates, or names that appear fabricated or distorted. (4) Logical leaps or conclusions not warranted by the evidence. (5) Broken cross-references between documents. Return a list of issues found, each with the document name, the problematic text, and what's wrong. If everything checks out, say so."
2. If the reviewer flags issues, fix them in the document content before writing. For unsupported claims, either remove them or clearly mark them as unverified.

### Phase 6: Write

1. Create the output directory (use `mkdir -p` via Bash).
2. Write each document to the output directory — `index.md` and all detail documents.
3. Show the user a manifest: topic, output directory, list of files produced with brief descriptions, total number of sources cited.
4. Mention they can view documents with the VS Code markdown preview (Mermaid extension) or push to GitHub for native rendering.

## Important

- Do NOT skip the human approval step after Phase 1. The whole point is to let the user shape the research before spending tokens on search.
- If a researcher agent returns mostly low-confidence findings or significant gaps, note this when presenting results — the user may want to add follow-up queries.
- Use today's date (from system context) for the directory name and report headers.
- The synthesizer decides the document structure — don't prescribe a fixed number of detail docs. Let the research drive it.

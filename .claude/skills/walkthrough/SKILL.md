---
name: walkthrough
description: Explore and visualize codebase architecture. Use when asked to "walk me through", "show how X works", "explain the flow", "diagram the architecture", or understand how components interact.
---

# Walkthrough Skill

Creates interactive walkthrough diagrams for exploring and understanding codebase architecture. Generates HTML visualizations that open in the browser.

## When to Use

- Exploring codebase architecture and structure
- Understanding code flows and execution paths
- Visualizing relationships between components, modules, or services
- Onboarding to unfamiliar codebases
- Documenting complex system interactions

## When NOT to Use

- Simple file reading (use the Read tool instead)
- Single file analysis without relationship context
- Modifying or editing code
- Quick lookups of specific symbols or functions

## Process

### Phase 1: Explore

Investigate the codebase by following references, imports, and call sites.

1. Start from the user's entry point (a file, function, module, or concept).
2. Read the relevant source files.
3. Follow imports, references, and call sites to discover connected components.
4. Track relationships: who calls whom, what depends on what, how data flows.
5. Continue expanding until you have sufficient context.

For each component, record:

- Its role and responsibility
- What it imports / depends on
- What calls it or references it
- Key data structures or interfaces it exposes

### Phase 2: Diagram

Choose the most appropriate Mermaid diagram type:

- **flowchart TD/LR** — call flows, request lifecycles, pipeline stages
- **sequenceDiagram** — interactions between components over time
- **classDiagram** — class/module relationships and interfaces
- **graph** — dependency graphs or architecture overviews

#### Diagram Guidelines

- Label nodes with actual file/module/class names from the codebase.
- Use short, descriptive edge labels (e.g., `calls`, `imports`, `emits`, `returns`).
- Group related components using Mermaid subgraphs where it aids clarity.
- Keep diagrams focused — create multiple diagrams rather than one sprawling graph.

### Phase 3: Visualize

Generate an interactive HTML file using the template at `templates/diagram.html`, then open it in the browser.

1. Read the template from `.claude/skills/walkthrough/templates/diagram.html`.
2. Replace the placeholders with your findings:
   - `TITLE_HERE` — the walkthrough topic (e.g., "Authentication Flow")
   - `SUBTITLE_OVERVIEW_HERE` — 1-2 sentence overview
   - `MERMAID_DIAGRAM_HERE` — the Mermaid diagram definition (no fences)
   - The components grid — replace with actual components you discovered
   - The takeaways list — replace with your actual findings
3. Write the populated HTML to `/tmp/walkthrough_diagram.html`.
4. Run `bash .claude/skills/walkthrough/scripts/render.sh` to open it.

Each Mermaid diagram must be wrapped in a `<div class="diagram-container">` so that svg-pan-zoom attaches correctly:

```html
<div class="card">
  <h2>Section Title</h2>
  <div class="diagram-container">
    <pre class="mermaid">
      ...diagram here...
    </pre>
    <span class="zoom-hint">scroll to zoom · drag to pan</span>
  </div>
</div>
```

If the system is complex enough for multiple diagrams, create multiple `.card` sections each with their own `diagram-container` block.

## Terminal Output

After opening the visualization, print a concise summary:

1. **Overview** — 2-3 sentence summary of what you explored.
2. **Components** — One-liner per key component.
3. **Key Takeaways** — Notable patterns or architectural decisions.
4. A note that the interactive diagram has been opened in the browser.

## Examples

- "Walk me through how authentication works in this codebase"
- "Create a diagram showing the data flow from API request to database"
- "Explore the relationship between the Router and Controller components"
- "Show me how the event system connects publishers and subscribers"

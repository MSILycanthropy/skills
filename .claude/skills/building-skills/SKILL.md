---
name: building-skills
description: "Creates well-structured Agent Skills following best practices. Use when creating any skill, agent skill, or custom skill. Load FIRST before researching existing skills or writing SKILL.md. Provides required structure, naming conventions, and frontmatter format."
---

# Building Skills

Creates well-structured Agent Skills for Claude Code following best practices.

## Skill Structure

Every skill needs a `SKILL.md` file with YAML frontmatter:

```markdown
---
name: my-skill-name
description: Does X when Y happens. Use for Z tasks.
---

# Skill Title

Instructions go here.
```

## Frontmatter Requirements

### `name` (required)

- Max 64 characters
- Lowercase letters (a-z), numbers (0-9), and hyphens ONLY
- Must not start or end with a hyphen
- No consecutive hyphens (`my--skill` is invalid)
- Must match parent directory name exactly
- Use gerund form (verb + -ing): `processing-pdfs`, `analyzing-data`, `managing-deployments`
- Avoid vague names: `helper`, `utils`, `tools`

### `description` (required)

- Max 1024 characters (aim for much shorter)
- Write in third person ("Processes files" not "I process files")
- Include BOTH what the skill does AND when to use it
- Be specific with key terms for discovery
- Quote the value if it contains colons, special YAML characters, or trigger patterns:
  ```yaml
  description: "Fetches tasks from Notion. Triggers on: my tasks, show work."
  ```

Good descriptions:

- `"Extracts text and tables from PDF files, fills forms, merges documents. Use when working with PDF files or asked to read/edit PDFs."`
- `"Queries BigQuery datasets using the bq CLI. Use for data analytics, SQL queries, or Google Cloud data warehouse tasks."`
- `"Reviews pull requests for code quality, security, and test coverage. Use when asked to review a PR or diff."`

Bad descriptions:

- `"Helps with files"` — too vague
- `"I can help you with data"` — wrong POV
- `"PDF tool"` — no trigger context

### Optional Fields

- `license` — License identifier (e.g., `"MIT"`, `"Apache-2.0"`)
- `compatibility` — Max 500 characters describing compatibility requirements
- `metadata` — Arbitrary metadata object
- `allowed-tools` — List of tools the skill can use
- `argument-hint` — Hint for skill arguments
- `model` — Preferred model (e.g., `"claude-opus-4-20250514"` or `"inherit"`)
- `mode` — Agent mode override
- `isolatedContext` — Run skill in an isolated context
- `disable-model-invocation` — Set `true` to prevent auto-invocation; skill can only be triggered manually via `/skill-name`

## Directory Structure

### Simple Skill (instructions only)

```
~/.claude/skills/my-skill/
└── SKILL.md
```

### Skill with Scripts

```
~/.claude/skills/my-skill/
├── SKILL.md
└── scripts/
    └── my-script.sh
```

### Complex Skill (progressive disclosure)

```
~/.claude/skills/my-skill/
├── SKILL.md            # Overview, under 500 lines
├── reference/
│   ├── api.md          # Detailed API docs
│   └── examples.md     # Code examples
└── scripts/
    └── validate.py     # Executable scripts
```

## Progressive Disclosure

Skills load in stages to save context:

1. **Metadata** — Name + description loaded at startup (~100 tokens)
2. **Instructions** — SKILL.md body loaded when triggered (<5k tokens)
3. **Resources** — Additional files loaded only when needed

Keep SKILL.md under 500 lines. Split large content into reference files.

## Writing Effective Instructions

### Do

- Start with a clear one-line summary
- List specific capabilities
- Provide step-by-step workflows
- Include concrete examples
- Reference scripts with execution intent: "Run `scripts/validate.py` to check..."

### Don't

- Explain concepts the model already knows
- Add lengthy introductions or summaries
- Include time-sensitive information in main sections
- Use abstract examples

## Executable Scripts

Place scripts in a `scripts/` subdirectory and reference them in SKILL.md:

```
~/.claude/skills/my-skill/
├── SKILL.md
└── scripts/
    └── run-task.sh
```

Reference with execution intent: "Run `scripts/run-task.sh` to execute the task."

Remember to make scripts executable (`chmod +x`). Write scripts to be cross-platform where possible (handle macOS, Linux, WSL).

## Bundling MCP Servers

Skills can bundle MCP servers with an `mcp.json` file. The MCP server starts when Claude Code loads but tools stay hidden until the skill activates.

```
~/.claude/skills/web-browser/
├── SKILL.md
└── mcp.json
```

Example `mcp.json`:

```json
{
  "chrome-devtools": {
    "command": "npx",
    "args": ["-y", "chrome-devtools-mcp@latest"],
    "includeTools": ["navigate_page", "take_screenshot"]
  }
}
```

### ALWAYS filter MCP tools

**THIS IS CRITICAL.** MCP servers often expose many tools (chrome-devtools has 26 tools = ~17,700 tokens). Always use `includeTools` to expose only what the skill needs.

Ask the user: "Which tools from this MCP do you actually need?"

```json
{
  "includeTools": ["navigate_page", "take_screenshot", "click"]
}
```

This reduces token cost by 90%+ and keeps the skill focused.

### `mcp.json` Fields

- `command` — Command to run (required)
- `args` — Array of arguments
- `env` — Environment variables
- `includeTools` — **ALWAYS SET THIS.** Glob patterns for which tools to expose. Do not guess tool names; use web search to find the correct tool names if in doubt.

## Skill Locations

Skills are discovered from these locations:

| Location                          | Scope                                               |
| --------------------------------- | --------------------------------------------------- |
| `.claude/skills/` in project root | Project-specific, shared with collaborators via git |
| `~/.claude/skills/`               | User-wide, available across all projects            |

Project skills take precedence if there's a name conflict with user-wide skills.

## Workflow for Creating a New Skill

1. Decide on a clear, specific skill name using gerund form
2. Write the description: what it does + when to trigger
3. Create the directory in the appropriate location
4. Write SKILL.md with frontmatter and instructions
5. Add scripts if the skill needs to execute code
6. Add `mcp.json` if the skill needs MCP tools (with filtered `includeTools`)
7. Test by invoking with `/skill-name` or by describing a matching task
8. Iterate on the description if Claude isn't auto-discovering it reliably

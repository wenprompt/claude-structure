# Claude Code Infrastructure

3-layer context system with **web-researched skills**, spec-driven development, and feedback learning.

**Tech Stack Focus:** Python 3.13+ (uv) | TypeScript 5.6+ (pnpm 10) | Go 1.22+

## The 3-Layer Context System

```
┌─────────────────────────────────────────────────────────┐
│ LAYER 1: SKILLS (How you build)                        │
│ .claude/skills/                                        │
│ - Coding standards, patterns, conventions              │
│ - Auto-generated WITH web search for 2025 practices    │
│ - Triggered automatically by Claude + hook             │
└─────────────────────────────────────────────────────────┘
                         ↓
┌─────────────────────────────────────────────────────────┐
│ LAYER 2: PRODUCT (What & Why)                          │
│ .claude/docs/product.md + tech-stack.md                │
│ - Mission, users, goals                                │
│ - Tech stack, conventions                              │
│ - Set ONCE per project                                 │
└─────────────────────────────────────────────────────────┘
                         ↓
┌─────────────────────────────────────────────────────────┐
│ LAYER 3: SPECS (What to build next)                    │
│ .claude/docs/feature.md                                │
│ - PRD + tasks for current feature                      │
│ - Created per feature with /feature:plan               │
└─────────────────────────────────────────────────────────┘
```

## Setup

```bash
# 1. Copy .claude/ folder to your project root
# 2. Make hooks executable
chmod +x .claude/hooks/*.sh
# 3. Done!
```

**Prerequisites:**
- Python projects: [uv](https://docs.astral.sh/uv/) (`uv init`, `uv add`, `uv run`)
- Node.js projects: [pnpm 10.x](https://pnpm.io/) (`pnpm add`, `workspace:*`)

---

## Commands

### Project Setup (Run Once)
```
/project:init          # Create product.md + tech-stack.md
/skill:generate        # Scan project → Web search → Create skills
/skill:improve         # Optimize skill descriptions for triggering
```

### Feature Development (Per Feature)
```
/feature:plan [what]   # Create PRD + tasks → feature.md
/feature:next          # Start next task
/feature:done          # Complete current task
```

---

## Workflow

### First Time Setup
```bash
# 1. Initialize project context (one time)
/project:init
# Creates: product.md, tech-stack.md

# 2. Generate skills from your tech stack (WITH WEB SEARCH)
/skill:generate
# Detects: FastAPI 0.115.0, React 19, etc.
# Searches: "FastAPI best practices 2025", "React 19 patterns modern"
# Creates: Skills with current 2025 best practices

# 3. Optimize skill descriptions
/skill:improve
# Updates: Descriptions for maximum triggering effectiveness
```

### Building Features
```bash
# 1. Plan what you're building
/feature:plan user authentication with OAuth
# Creates: .claude/docs/feature.md

# 2. Work through tasks
/feature:next    # Start TASK-1
# ... work ...
/feature:done    # Complete TASK-1

/feature:next    # Start TASK-2
# ... work ...
/feature:done    # Complete TASK-2

# 3. Repeat until done
# 🎉 Feature complete!
```

---

## Skills System (v2.0)

Skills are auto-triggered coding standards. Claude applies them automatically when relevant.

### What's New in v2.0

| Feature | Description |
|---------|-------------|
| **Web Search** | `/skill:generate` searches for December 2025 best practices |
| **Version Detection** | Extracts versions from pyproject.toml, package.json, go.mod |
| **Progressive Disclosure** | SKILL.md + resources/ folder pattern |
| **Rich Triggers** | Keywords + intent patterns + path patterns |
| **Gerund Naming** | `fastapi-developing` not `fastapi-backend` |
| **Package Managers** | uv (Python) + pnpm 10.x (Node.js) |
| **Type Safety** | mypy --strict + ruff (Python), tsc (TypeScript) |

### How It Works

1. **Detect**: Scans project for technologies + extracts versions
2. **Research**: Web searches for current 2025 best practices
3. **Generate**: Creates SKILL.md + resource files with modern patterns
4. **Configure**: Updates skill-rules.json with rich triggers
5. **Trigger**: Claude + hook apply skills automatically

### Skill Structure (Progressive Disclosure)

```
.claude/skills/
├── fastapi-developing/
│   ├── SKILL.md              # Main file (<500 lines)
│   └── resources/            # Detailed content (loaded on demand)
│       ├── patterns.md
│       ├── anti-patterns.md
│       └── examples.md
├── nextjs-building/
│   └── SKILL.md
└── skill-rules.json          # Rich trigger configuration
```

### skill-rules.json Format (v2.0)

```json
{
  "version": "2.0",
  "skills": {
    "fastapi-developing": {
      "type": "domain",
      "enforcement": "suggest",
      "promptTriggers": {
        "keywords": ["fastapi", "api", "endpoint", "pydantic"],
        "intentPatterns": ["(create|build).*?(endpoint|route|api)"]
      },
      "fileTriggers": {
        "pathPatterns": ["app/**/*.py", "api/**/*.py"],
        "contentPatterns": ["from fastapi import"]
      }
    }
  }
}
```

### SKILL.md Format

```markdown
---
name: fastapi-developing
description: FastAPI 0.115+ async API developing with Pydantic v2 validation,
dependency injection, lifespan managers, and async database patterns.
Use when creating endpoints, models, services, middleware, or debugging backend
errors. Apply for .py files in api/, routes/, services/, or main.py. (project)
---

# FastAPI Development

## When To Apply
- Creating or editing API endpoints
- Building Pydantic models
- Debugging backend errors

## Quick Reference
[Modern patterns - kept brief]

## Resource Files
- [patterns.md](resources/patterns.md)
- [anti-patterns.md](resources/anti-patterns.md)
```

The `description` field is **critical** - Claude uses it to select from potentially 100+ skills.

---

## Agents

Specialized subagents for complex tasks:

```
"Use the refactor-planner agent to plan restructuring auth"
"Use the web-research-specialist to find current best practices"
```

| Agent | Purpose |
|-------|---------|
| **refactor-planner** | Plans refactoring before changes |
| **web-research-specialist** | Finds current best practices |
| **code-architecture-reviewer** | Reviews code quality |
| **documentation-architect** | Creates/updates docs |

---

## Acontext Learning

Learns from your feedback automatically:

| Say This | Claude Learns |
|----------|---------------|
| "Perfect!" "Great!" | WIN: Repeat this behavior |
| "Wrong" "Undo" | LOSS: Avoid this behavior |
| "Actually, always..." | CORRECTION: Explicit rule (highest priority) |

**How it works:**

```
┌─────────────────────────────────────────────────────────┐
│ You type a prompt                                       │
│              ↓                                          │
│ acontext-feedback.sh (hook) scans for triggers          │
│              ↓                                          │
│ Writes to .claude/docs/acontext.json                    │
│              ↓                                          │
│ /feature:plan reads corrections before planning         │
│ /feature:next reads corrections before implementing     │
└─────────────────────────────────────────────────────────┘
```

**acontext.json structure:**
```json
{
  "corrections": [{"rule": "Always use httpx not requests", "at": "..."}],
  "wins": [{"trigger": "perfect", "context": "Used lifespan...", "at": "..."}],
  "losses": [{"trigger": "wrong", "context": "Used @app.on_event...", "at": "..."}]
}
```

**Priority:** corrections > losses > wins

---

## Context Management

**Problem:** Too much context = slow + expensive + confused Claude

**Solution:** Layered loading with progressive disclosure

```
┌─────────────────────────────────────────────────────────┐
│ ALWAYS LOADED (small, ~500 tokens)                      │
│ • acontext.json corrections array                       │
│ • Current task from feature.md                          │
└─────────────────────────────────────────────────────────┘
                    ↓
┌─────────────────────────────────────────────────────────┐
│ LOADED ON DEMAND (via hooks/triggers)                   │
│ • SKILL.md when keywords match (~500 lines max)         │
│ • resources/*.md only if Claude needs deeper info       │
└─────────────────────────────────────────────────────────┘
                    ↓
┌─────────────────────────────────────────────────────────┐
│ LOADED ONCE (during /feature:plan)                      │
│ • product.md → incorporated into feature.md             │
│ • tech-stack.md → incorporated into feature.md          │
│ • NOT re-read during /feature:next                      │
└─────────────────────────────────────────────────────────┘
```

**Key principle:** Plan incorporates product context, so tasks don't need to re-read it.

---

## File Structure

```
.claude/
├── docs/                    # Layer 2 + 3 context
│   ├── product.md           # Mission, users (Layer 2)
│   ├── tech-stack.md        # Stack, conventions (Layer 2)
│   ├── feature.md           # Current feature PRD + tasks (Layer 3)
│   └── acontext.json        # Learned feedback (auto-generated)
│
├── skills/                  # Layer 1: Web-researched skills
│   ├── [tech-name]-[activity]/
│   │   ├── SKILL.md         # Main (<500 lines)
│   │   └── resources/       # Progressive disclosure
│   │       ├── patterns.md
│   │       └── anti-patterns.md
│   └── skill-rules.json     # Rich trigger config
│
├── commands/                # Slash commands
│   ├── project-init.md      # /project:init
│   ├── feature-plan.md      # /feature:plan
│   ├── feature-next.md      # /feature:next
│   ├── feature-done.md      # /feature:done
│   ├── skill-generate.md    # /skill:generate
│   ├── skill-improve.md     # /skill:improve
│   └── validate_cmd.md      # /validate_cmd
│
├── agents/                  # Specialized subagents
│   ├── refactor-planner.md
│   ├── web-research-specialist.md
│   ├── code-architecture-reviewer.md
│   ├── documentation-architect.md
│   ├── code-reviewer.md
│   └── context-writer.md
│
├── hooks/                   # Automation (v2.0)
│   ├── skill-activation-prompt.sh  # Keywords + intent patterns
│   └── acontext-feedback.sh
│
└── settings.json            # Hook configuration
```

---

## Key Improvements from Research

Based on analysis of:
- [diet103/claude-code-infrastructure-showcase](https://github.com/diet103/claude-code-infrastructure-showcase)
- [Agent OS](https://buildermethods.com/agent-os)
- [Official Claude Docs](https://docs.claude.com/en/docs/claude-code/skills)

| Improvement | Why |
|-------------|-----|
| **Web search for practices** | Skills use current 2025 patterns, not outdated training data |
| **Version detection** | Skills are specific to YOUR versions (FastAPI 0.115, not generic) |
| **Progressive disclosure** | SKILL.md stays <500 lines, details in resources/ |
| **Rich triggers** | Keywords + intentPatterns + pathPatterns + contentPatterns |
| **Gerund naming** | `fastapi-developing` clearly describes the activity |
| **Enforcement levels** | suggest / warn / block for guardrails |

---

## Requirements

**Infrastructure (hooks work with these only):**
- Bash + standard Unix tools
- Works on: Linux, macOS, WSL

**For your projects:**
- Python: [uv](https://docs.astral.sh/uv/) (package manager)
- Node.js: [pnpm 10.x](https://pnpm.io/) (package manager)
- Database: Project-specific (PostgreSQL, MongoDB, etc.)

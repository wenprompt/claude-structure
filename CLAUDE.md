# [Project Name]

## Purpose

[1-2 sentences: what this project does and why it exists]

## Tech Stack

- Language: [e.g., Python 3.13+]
- Framework: [e.g., FastAPI, React, NextJs]
- Package manager: [e.g., uv, npm, pnpm]

## Commands

```bash
# Lint & Format
[e.g., uv run ruff check --fix . && uv run ruff format .]

# Type Check
[e.g., uv run mypy --strict src/]

# Test
[e.g., uv run pytest]

# Run
[e.g., uv run python -m src.main]
```

## Project Structure

```
[Fill in key directories, e.g.]
src/           # Main source code
tests/         # Test files
docs/          # Documentation
```

## Boundaries

**Never:**

- Commit secrets or .env files
- Delete files without asking
- Force push to main

**Ask first:**

- Refactors touching >5 files
- Adding new dependencies
- Changing CI/CD configs

## Context

- `.claude/agents/` - Specialized review agents
- `.claude/skills/` - Domain-specific patterns
- `.claude/commands/` - Custom slash commands

Run `/init` to auto-populate this file for your project.

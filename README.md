# Tytos Standards

Claude Code plugin that enforces consistent coding standards across the Tytos team. Three enforcement tiers:

| Tier | What | Adherence |
|------|------|-----------|
| **Soft** | CLAUDE.md + `.claude/rules/` | ~80% — Claude reads as instructions |
| **Hard** | Hooks + permission deny rules | 100% — shell scripts run on every file write, blocked installs |
| **On-Demand** | `/audit-project`, `/init-project`, `/fix-standards` | Manual — run when needed |

## Problems This Solves

1. **Mock data masking errors** — AI tools generate fallback data that hides real bugs
2. **Seed data in migrations** — `INSERT INTO` in migration SQL clutters fresh starts
3. **Custom auth** — Devs use NextAuth/JWT instead of Supabase Auth, making handoffs painful
4. **Custom UI components** — Building Button/Modal/Card from scratch instead of using HeroUI
5. **No Docker** — Projects hard to share, deploy, and manage

---

## Installation

### Option A: Claude Code Plugin (Recommended)

One-time setup per developer. Open Claude Code and run:

```
/plugin marketplace add mosesmrima/tytos-standards
```

Then install the plugin:

```
/plugin install tytos-standards@tytos-standards
```

This gives you **everything automatically**:
- Slash commands: `/audit-project`, `/init-project`, `/fix-standards`
- PostToolUse hooks that warn on every file write
- Stop hook that verifies standards before Claude stops
- Permission deny rules blocking `bun add next-auth`, `npm install passport`, etc.
- Skills: `tytos-standards` (approved stack reference), `heroui-reference` (75+ components)

To update later:
```
/plugin update tytos-standards@tytos-standards
```

### Option B: Manual Installation (fallback)

```bash
git clone git@github.com:mosesmrima/tytos-standards.git ~/tytos/standards
cd ~/tytos/standards
chmod +x install.sh
./install.sh
```

This symlinks the slash commands and skills to `~/.claude/commands/` and `~/.claude/skills/`.

---

## Adding Standards to a Project

The plugin gives you commands and hooks globally. To also add the **CLAUDE.md template** and **path-scoped rules** to a specific project (so they're committed to git and all team members get them):

```bash
cd ~/tytos/your-project

# Copy the master CLAUDE.md and .claude/ config
cp ~/tytos/standards/project-template/CLAUDE.md ./CLAUDE.md
cp -r ~/tytos/standards/project-template/.claude ./.claude
chmod +x .claude/hooks/*.sh

# Edit CLAUDE.md — replace [PROJECT_NAME] with your project name
# Fill in the Project-Specific Notes section at the bottom

# Commit to git
git add CLAUDE.md .claude/
git commit -m "chore: add Tytos team standards enforcement"
git push
```

Once committed, **every team member** who pulls gets the hooks, rules, and CLAUDE.md automatically.

---

## Using the Slash Commands

### `/init-project <name>` — Scaffold a New Project

Creates a complete project with the approved stack:

```
/init-project my-app
```

What it generates:
- Next.js + TypeScript + Tailwind CSS v4 + App Router
- Supabase Auth (client, server, middleware files)
- HeroUI v3 + TanStack Query + Zustand + Zod
- Prisma schema + separate seed script
- Dockerfile (multi-stage) + docker-compose.yml
- CLAUDE.md + `.claude/` with all rules and hooks
- Standard directory structure

### `/audit-project` — Scan for Violations

Run in any project to check compliance:

```
/audit-project
```

Scans 7 categories:

| Category | What It Checks | Severity |
|----------|---------------|----------|
| `CLAUDE_MD` | CLAUDE.md exists with standards section | CRITICAL |
| `AUTH` | No NextAuth, jsonwebtoken, jose, passport imports | CRITICAL |
| `PACKAGES` | No forbidden packages in package.json | CRITICAL |
| `MOCK_DATA` | No hardcoded mock/stub/fake data in source files | HIGH |
| `UI_COMPONENTS` | No custom Button/Modal/Card/etc. without HeroUI/shadcn | HIGH |
| `DOCKER` | Dockerfile + docker-compose.yml exist | HIGH |
| `MIGRATIONS` | No `INSERT INTO` in migration SQL files | MEDIUM |

Generates a structured report with file paths, line numbers, and suggested fixes.

### `/fix-standards` — Auto-Fix Violations

```
/fix-standards
```

**Auto-fixes** (safe):
- Missing CLAUDE.md — copies template
- Missing `.claude/` config — creates rules, hooks, settings.json
- Missing Docker files — generates Dockerfile + docker-compose.yml
- Missing `prisma/seed.ts` — creates empty seed script
- Missing package.json scripts — adds `db:generate`, `db:migrate`, `db:seed`, etc.

**Generates migration plans** (needs manual work):
- Auth migration (NextAuth → Supabase Auth) — lists all files + equivalent Supabase code
- UI component migration — maps custom components to HeroUI equivalents

---

## What's in the Project Template

When you copy `project-template/` into a project, you get:

### `CLAUDE.md` — Master Instructions

Claude reads this at every session start. Contains:

1. **Tytos Team Standards** — mandatory tech stack, anti-patterns, error handling policy
2. **Testing Discipline** — rules for how Claude should test features (interact, don't just screenshot)
3. **Behavioral System Prompt** — XML-based guidance with named behaviors and priorities:
   - `assumption_surfacing` (critical) — state assumptions before implementing
   - `confusion_management` (critical) — stop and ask on ambiguity
   - `no_mock_data` (critical) — never return fake data on errors
   - `use_approved_stack` (critical) — always use HeroUI, Supabase Auth, etc.
   - `push_back_when_warranted` (high) — challenge bad ideas
   - `simplicity_enforcement` (high) — resist overcomplication
   - `scope_discipline` (high) — only touch what's asked
4. **Project-Specific Notes** — fill in your Supabase URL, architecture, etc.

### `.claude/rules/` — Path-Scoped Rules

| File | When It Loads | What It Enforces |
|------|--------------|-----------------|
| `standards.md` | Always | Tech stack, anti-patterns, error envelope |
| `testing.md` | Always | TDD workflow, 80% coverage, testing discipline |
| `frontend.md` | When touching `src/components/**`, `src/app/**/page.tsx` | HeroUI usage, Tailwind, component patterns |
| `backend.md` | When touching `src/app/api/**`, `src/lib/**` | Supabase Auth, API envelope, Prisma patterns |

Path-scoped rules only load when Claude accesses matching files, saving context window space.

### `.claude/settings.json` — Hooks & Permissions

**PostToolUse hooks** (run after every file Write/Edit):

| Hook Script | What It Warns About |
|-------------|-------------------|
| `check-mock-data.sh` | `const mockData = [...]`, stub data in catch blocks |
| `check-custom-auth.sh` | Imports of `next-auth`, `jsonwebtoken`, `jose`, `passport` |
| `check-custom-components.sh` | Custom Button/Modal/Card/Table/etc. without HeroUI/shadcn |
| `check-seed-in-migration.sh` | `INSERT INTO` in migration SQL files |

**Stop hook** — Before Claude stops, an LLM prompt verifies no standards were violated during the session. If violations found, Claude is told to continue and fix them.

**Permission deny rules** — Blocks installation of forbidden packages:
```
bun add next-auth       → BLOCKED
npm install passport    → BLOCKED
bun add jsonwebtoken    → BLOCKED
```

---

## Skills Reference

### `tytos-standards`

Auto-activates when making tech decisions. Contains:
- Approved tech stack table with package names
- Anti-pattern examples with BAD vs GOOD code (mock data, custom auth, custom components, seed in migrations)
- Supabase Auth patterns (browser client, server client, login/signup)
- Docker patterns (multi-stage Dockerfile, docker-compose)
- Error handling patterns (API envelope)

### `heroui-reference`

Auto-activates when building UI. Contains:
- Complete catalog of **75+ HeroUI v3 components** with import paths
- All components import from `@heroui/react`
- Code examples for: Button, Modal, Form, Table, Card, Select, Tabs, Dropdown, Toast
- Theming setup with CSS variables
- Key patterns: compound components, `onPress` (not `onClick`), React Aria foundation

### `audit-project`, `init-project`, `fix-standards`

User-invoked slash commands (see "Using the Slash Commands" above).

---

## Repository Structure

```
mosesmrima/tytos-standards/
├── .claude-plugin/
│   └── plugin.json                    # Plugin metadata for Claude Code marketplace
├── hooks/
│   ├── hooks.json                     # Hook wiring (plugin-level, uses CLAUDE_PLUGIN_ROOT)
│   ├── check-mock-data.sh            # Warn on mock/stub/fake data
│   ├── check-custom-auth.sh          # Warn on NextAuth/JWT/passport
│   ├── check-custom-components.sh    # Warn on custom UI primitives
│   └── check-seed-in-migration.sh    # Warn on INSERT INTO in migrations
├── skills/
│   ├── tytos-standards/SKILL.md      # Approved stack + anti-patterns reference
│   ├── heroui-reference/SKILL.md     # 75+ HeroUI v3 components catalog
│   ├── audit-project/SKILL.md        # /audit-project command
│   ├── init-project/SKILL.md         # /init-project command
│   └── fix-standards/SKILL.md        # /fix-standards command
├── commands/                          # Legacy command format (same content as skills/)
│   ├── audit-project.md
│   ├── init-project.md
│   └── fix-standards.md
├── project-template/                  # Copy into each project root
│   ├── CLAUDE.md                      # Master CLAUDE.md template
│   └── .claude/
│       ├── settings.json              # Hooks + permission deny rules
│       ├── rules/                     # Path-scoped rules
│       │   ├── standards.md
│       │   ├── testing.md
│       │   ├── frontend.md
│       │   └── backend.md
│       └── hooks/                     # Shell scripts for project-level enforcement
│           ├── check-mock-data.sh
│           ├── check-custom-auth.sh
│           ├── check-custom-components.sh
│           └── check-seed-in-migration.sh
├── install.sh                         # Manual installer (fallback)
└── README.md                          # This file
```

---

## Approved Tech Stack

| Layer | Technology | Package |
|-------|-----------|---------|
| Runtime | Bun | `bun` |
| Framework | Next.js (App Router) | `next` |
| Language | TypeScript (strict) | `typescript` |
| Auth | Supabase Auth | `@supabase/ssr`, `@supabase/supabase-js` |
| Database | Supabase PostgreSQL | `@prisma/client` |
| UI | HeroUI v3 (preferred) | `@heroui/react` |
| UI (alt) | shadcn/ui | `shadcn` |
| Styling | Tailwind CSS v4 | `tailwindcss` |
| Server State | TanStack Query | `@tanstack/react-query` |
| Client State | Zustand | `zustand` |
| Validation | Zod v4 | `zod` |
| Containers | Docker | `Dockerfile` + `docker-compose.yml` |

---

## How Updates Work

| What Changed | How Devs Get It |
|-------------|----------------|
| Skills, hooks, commands (this repo) | `/plugin update tytos-standards@tytos-standards` |
| CLAUDE.md or `.claude/rules/` in a project | `git pull` (it's committed to the project repo) |
| New rule or hook added to project-template | Re-copy: `cp -r ~/tytos/standards/project-template/.claude ./.claude` |

## Contributing

1. Clone this repo
2. Edit the relevant files
3. Test by running `/audit-project` on a real project
4. Push to `main` — team members run `/plugin update` to get changes

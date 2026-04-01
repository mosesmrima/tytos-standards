# Tytos Standards

Shared Claude Code enforcement system for the Tytos development team. Ensures consistent coding standards across all projects through a three-tier approach:

| Tier | What | How |
|------|------|-----|
| **Soft** | CLAUDE.md + rules | Advisory guidance Claude reads at session start (~80% adherence) |
| **Hard** | Hooks + permission denies | Shell scripts that warn on every file write + blocked package installs (100%) |
| **On-Demand** | Slash commands | `/audit-project`, `/init-project`, `/fix-standards` |

## Problems This Solves

1. **Mock data masking errors** — Hooks warn when stub/fake data is written to source files
2. **Seed data in migrations** — Hooks warn when `INSERT INTO` appears in migration SQL
3. **Custom auth (NextAuth, JWT)** — Hooks warn on forbidden imports + permissions block installation
4. **Custom UI components** — Hooks warn when Button/Modal/Card etc. are built from scratch
5. **Missing Docker** — Audit catches missing Dockerfile/docker-compose.yml

## Quick Start

### Option A: Install as Claude Code Plugin (Recommended)

This is the easiest way. One-time setup per developer:

**Step 1: Add the marketplace**
```
/plugin marketplace add tytos/standards
```

**Step 2: Install the plugin**
```
/plugin install tytos-standards@tytos-standards
```

Done. You now have all slash commands (`/audit-project`, `/init-project`, `/fix-standards`), enforcement hooks, permission deny rules, and the standards skill.

### Option B: Manual Installation via install.sh

```bash
git clone https://github.com/tytos/standards.git ~/tytos/standards
cd ~/tytos/standards
chmod +x install.sh
./install.sh
```

This symlinks commands and skills to `~/.claude/`.

### Adding Standards to an Existing Project (CLAUDE.md + Rules)

The plugin gives you commands and hooks globally. To also add the CLAUDE.md template and path-scoped rules to a specific project:

```bash
cd ~/tytos/your-project
cp ~/tytos/standards/project-template/CLAUDE.md ./CLAUDE.md
cp -r ~/tytos/standards/project-template/.claude ./.claude
chmod +x .claude/hooks/*.sh
git add CLAUDE.md .claude/
git commit -m "chore: add Tytos team standards enforcement"
```

Once committed, **all team members** get the hooks and rules on `git pull`.

### 3. Create a New Project

```
/init-project my-new-app
```

This scaffolds a complete Next.js project with Supabase, HeroUI, Prisma, Docker, and all enforcement infrastructure.

### 4. Audit an Existing Project

```
/audit-project
```

Scans for violations across 7 categories and generates a structured report.

## What's Inside

```
standards/
├── project-template/              # Copy into every project
│   ├── CLAUDE.md                  # Master template (standards + behaviors + testing)
│   └── .claude/
│       ├── settings.json          # Hook wiring + permission deny rules
│       ├── rules/                 # Path-scoped rules loaded by Claude
│       │   ├── standards.md       # Always loaded: tech stack, anti-patterns
│       │   ├── testing.md         # Always loaded: testing discipline, TDD
│       │   ├── frontend.md        # Loaded for src/components/**, src/app/**/page.tsx
│       │   └── backend.md         # Loaded for src/app/api/**, src/lib/**
│       └── hooks/                 # Shell scripts that run after every file write
│           ├── check-mock-data.sh
│           ├── check-custom-auth.sh
│           ├── check-custom-components.sh
│           └── check-seed-in-migration.sh
│
├── commands/                      # Installed to ~/.claude/commands/
│   ├── audit-project.md           # /audit-project
│   ├── init-project.md            # /init-project
│   └── fix-standards.md           # /fix-standards
│
├── skills/
│   └── tytos-standards/
│       └── SKILL.md               # Reference: approved stack, patterns, examples
│
├── install.sh                     # One-time installer for slash commands
└── README.md                      # This file
```

## Enforcement Details

### PostToolUse Hooks (run after every Write/Edit)

| Hook | What It Checks |
|------|---------------|
| `check-mock-data.sh` | `const mock/stub/dummy/fake = [...]` patterns in source files |
| `check-custom-auth.sh` | Imports of `next-auth`, `jsonwebtoken`, `jose`, `passport` |
| `check-custom-components.sh` | Exported Button/Modal/Card/etc. without HeroUI/Radix imports |
| `check-seed-in-migration.sh` | `INSERT INTO` statements in migration SQL files |

### Permission Deny Rules (block package installation)

Blocks `bun add` / `npm install` / `pnpm add` / `yarn add` for:
- `next-auth`, `@auth/*`
- `jsonwebtoken`, `jose`
- `passport`

### Stop Hook (LLM verification)

Before Claude stops working, a prompt hook verifies that no standards violations occurred during the session.

### Path-Scoped Rules

- `frontend.md` loads only when Claude touches `src/components/**` or `src/app/**/page.tsx`
- `backend.md` loads only when Claude touches `src/app/api/**` or `src/lib/**`
- `standards.md` and `testing.md` are always loaded

## Approved Tech Stack

| Layer | Technology | Package |
|-------|-----------|---------|
| Runtime | Bun | `bun` |
| Framework | Next.js (App Router) | `next` |
| Auth | Supabase Auth | `@supabase/ssr` |
| Database | Supabase PostgreSQL | `@prisma/client` |
| UI | HeroUI v3 (preferred) | `@heroui/react` |
| UI (alt) | shadcn/ui | `shadcn` |
| Styling | Tailwind CSS v4 | `tailwindcss` |
| Server State | TanStack Query | `@tanstack/react-query` |
| Client State | Zustand | `zustand` |
| Validation | Zod v4 | `zod` |

## Contributing

To add a new standard or modify existing ones:

1. Edit files in this repo
2. Run `./install.sh` to update your local symlinks
3. For project-level changes: re-copy `.claude/` to affected projects
4. Team members get updates on `git pull` (project-level) or by re-running `install.sh` (slash commands)

---
name: audit-project
description: Scan the current project for Tytos standards violations and generate a compliance report
argument-hint: 
allowed-tools: [Read, Glob, Grep, Bash]
---

# Audit Project

Scan the current project for Tytos team standards violations across 7 categories. Generate a structured report with severity levels and suggested fixes.

## Workflow

### Step 1: Check CLAUDE.md

- Use Glob to check if `CLAUDE.md` exists in the project root
- If missing: flag as **CRITICAL** — "No CLAUDE.md found"
- If present: use Grep to check for "Tytos Team Standards" section
  - If missing: flag as **HIGH** — "CLAUDE.md exists but missing Tytos standards section"

### Step 2: Check Auth (Category: AUTH)

Search for non-approved auth packages. Use Grep with these patterns in `*.ts`, `*.tsx`, `*.js` files, excluding `node_modules/`:

| Pattern | What It Detects |
|---------|----------------|
| `(import\|require).*next-auth` | NextAuth usage |
| `(import\|require).*@auth/` | Auth.js usage |
| `(import\|require).*jsonwebtoken` | Manual JWT |
| `(import\|require).*jose` | Manual JWT via jose |
| `(import\|require).*passport` | Passport.js |
| `jwt\.sign\|jwt\.verify\|jwt\.decode` | Manual JWT operations |

Also check `package.json` for these packages in dependencies/devDependencies.

Severity: **CRITICAL** for any auth violation found.

### Step 3: Check Mock/Stub Data (Category: MOCK_DATA)

Search for hardcoded mock data patterns. Use Grep in `*.ts`, `*.tsx` files, EXCLUDING test files (`*.test.*`, `*.spec.*`, `__tests__/`, `__mocks__/`, `fixtures/`, `*.stories.*`, `prisma/seed.*`):

| Pattern | What It Detects |
|---------|----------------|
| `(const\|let\|var)\s+(mock\|stub\|dummy\|fake\|placeholder\|sample)\w*\s*[:=]\s*[\[\{]` | Hardcoded mock data |
| Catch blocks containing `return [...` or `return {` with literal data | Fallback data masking errors |

Severity: **HIGH** for mock data in source files.

### Step 4: Check Custom UI Components (Category: UI_COMPONENTS)

Search in `src/**/*.tsx` for exported components that should come from HeroUI/shadcn:

| Pattern | What It Detects |
|---------|----------------|
| `export.*function (Button\|Modal\|Card\|Input\|Select\|Dialog\|Table\|Tabs\|Dropdown)` | Custom UI primitive |
| `export const (Button\|Modal\|Card\|Input\|Select\|Dialog\|Table\|Tabs\|Dropdown)` | Custom UI primitive |

**False positive check**: For each match, read the file and check if it imports from `@heroui/` or `@/components/ui/` (shadcn convention). If it does, it's an acceptable wrapper — not a violation.

Severity: **HIGH** for custom components without HeroUI/shadcn imports.

### Step 5: Check Docker (Category: DOCKER)

- Use Glob for `Dockerfile` in project root
- Use Glob for `docker-compose.yml` or `docker-compose.yaml` in project root
- If Dockerfile missing: **HIGH** violation
- If docker-compose missing: **HIGH** violation
- If both present: check Dockerfile for multi-stage build (`FROM.*AS`) — warn if single-stage

### Step 6: Check Migrations (Category: MIGRATIONS)

- Use Glob for `**/migrations/**/*.sql`
- Use Grep for `INSERT\s+INTO` in each migration file
- Flag any migration containing INSERT INTO
- Note: "INSERT INTO for enum/lookup tables may be intentional — review manually"
- Severity: **MEDIUM**

### Step 7: Check package.json (Category: PACKAGES)

Read `package.json` and check:
- Does it contain `next-auth`, `@auth/core`, `jsonwebtoken`, `jose`, `passport` in dependencies? → **CRITICAL**
- Is `@supabase/supabase-js` missing from dependencies? → **HIGH** warning
- Is `@heroui/react` missing from dependencies? → **MEDIUM** warning
- Is `prisma` missing from devDependencies? → **MEDIUM** warning
- Are standard scripts present (`db:generate`, `db:migrate`, `db:seed`)? → **LOW** if missing

### Step 8: Check .claude/ Configuration (Category: CONFIG)

- Check if `.claude/settings.json` exists with hooks configured
- Check if `.claude/rules/` directory exists with rule files
- Check if `.claude/hooks/` directory exists with hook scripts
- Severity: **MEDIUM** if enforcement infrastructure is missing

### Step 9: Generate Report

Output the report in this format:

```
## Tytos Standards Audit Report

### Summary
- Total violations: N
- CRITICAL: n | HIGH: n | MEDIUM: n | LOW: n

### CRITICAL Violations
- [CATEGORY] file:line — description
  → Fix: suggestion

### HIGH Violations
- [CATEGORY] file:line — description
  → Fix: suggestion

### MEDIUM Violations
...

### LOW Violations
...

### Passing Checks
✓ [list of categories with no violations]

### Next Steps
- Run `/fix-standards` to auto-fix safe violations
- Manual review needed for: [list items requiring human judgment]
```

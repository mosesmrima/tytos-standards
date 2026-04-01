---
name: fix-standards
description: Auto-fix common Tytos standards violations found by /audit-project
allowed-tools: [Read, Write, Edit, Glob, Grep, Bash]
---

# Fix Standards

Auto-fix common standards violations. Fixes what's safe automatically, generates migration plans for what requires manual intervention.

## Step 1: Run Audit

First, perform the same checks as `/audit-project` internally to identify all current violations. Categorize them into auto-fixable vs manual.

## Step 2: Auto-Fix Safe Issues

### Fix: Missing CLAUDE.md

If CLAUDE.md is missing from the project root:
1. Check if the tytos standards repo is available at `~/tytos/standards/` or a sibling directory
2. If available: copy `project-template/CLAUDE.md` and replace `[PROJECT_NAME]` with the actual project name from package.json
3. If not available: generate the standard CLAUDE.md template with all required sections (Tytos Team Standards, Testing Discipline, Behavioral Guidance)

### Fix: Outdated CLAUDE.md

If CLAUDE.md exists but is missing the "Tytos Team Standards" section:
1. Read the existing CLAUDE.md
2. Prepend the Tytos Team Standards section (mandatory stack, anti-patterns, error handling) BEFORE the existing content
3. Preserve all existing project-specific content

### Fix: Missing .claude/ Configuration

If `.claude/settings.json` is missing:
1. Create `.claude/settings.json` with the standard hooks configuration and permission deny rules

If `.claude/rules/` is missing:
1. Create all 4 rule files: standards.md, testing.md, frontend.md, backend.md

If `.claude/hooks/` is missing:
1. Create all 4 hook scripts and make them executable

### Fix: Missing Docker Files

If `Dockerfile` is missing:
1. Generate a multi-stage Dockerfile for Next.js + Bun (deps → builder → runner pattern)
2. Use node:20-alpine base, standalone output mode

If `docker-compose.yml` is missing:
1. Generate standard compose file with app + postgres services

If `.dockerignore` is missing:
1. Generate with: `node_modules`, `.next`, `.git`, `.env.local`

### Fix: Missing Prisma Seed Script

If `prisma/seed.ts` is missing but `prisma/schema.prisma` exists:
1. Create an empty seed script with proper structure
2. Add `prisma.seed` config to package.json if missing
3. Add `db:seed` script to package.json if missing

### Fix: Missing Standard Scripts

Check package.json for missing standard scripts and add them:
- `db:generate`, `db:migrate`, `db:seed`, `db:studio`, `db:push`, `db:migrate:deploy`, `postinstall`

## Step 3: Generate Migration Plans (Manual Fixes)

### Auth Migration Plan

If NextAuth or custom auth packages are detected:
1. List all files importing forbidden auth packages
2. For each file, describe what the Supabase Auth equivalent would be
3. Output as a structured migration plan:

```
## Auth Migration Plan

### Files to Migrate
1. `src/app/api/auth/[...nextauth]/route.ts` → Delete. Replace with Supabase middleware in `src/middleware.ts`
2. `src/lib/auth.ts` → Replace with `src/lib/supabase/server.ts` using createServerClient
3. `src/components/LoginForm.tsx` → Replace NextAuth signIn() with supabase.auth.signInWithPassword()
...

### Migration Steps
1. Install @supabase/ssr and @supabase/supabase-js
2. Set up Supabase environment variables
3. Create Supabase client/server/middleware files
4. Migrate each file listed above
5. Remove next-auth from package.json
6. Run /audit-project to verify
```

### UI Component Migration Plan

If custom UI components are detected (components not importing from HeroUI/Radix):
1. List each custom component found
2. Map it to the equivalent HeroUI component with import path
3. Show a before/after example

```
## UI Component Migration Plan

### Components to Replace
1. `src/components/Button.tsx` → `import { Button } from "@heroui/react"`
   - Review custom props and map to HeroUI's Button props
   - HeroUI Button supports: color, variant, size, isLoading, isDisabled, startContent, endContent

2. `src/components/Modal.tsx` → `import { Modal, ModalContent, ModalHeader, ModalBody, ModalFooter } from "@heroui/react"`
...
```

### Mock Data Cleanup Plan

If mock/stub data is found in source files:
1. List each occurrence with file and line number
2. For each, suggest the proper error handling replacement
3. Flag any that might be intentional (e.g., default values, placeholder text) for manual review

## Step 4: Apply Auto-Fixes

Execute all auto-fixes identified in Step 2. For each fix:
1. Create/modify the file
2. Confirm the change was made

## Step 5: Post-Fix Report

Re-run the audit checks and output:

```
## Fix Standards Report

### Auto-Fixed
✓ [list of issues that were automatically resolved]

### Migration Plans Generated
⚠ [list of issues with migration plans — requires manual work]
  → See generated plans above

### Remaining Issues
✗ [list of issues that could not be auto-fixed and have no plan]

### Verification
Run `/audit-project` to see the updated compliance status.
```

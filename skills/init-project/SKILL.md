---
name: init-project
description: Scaffold a new Tytos project with standard structure, Docker, Supabase, HeroUI, and Prisma
argument-hint: <project-name>
allowed-tools: [Read, Write, Edit, Glob, Grep, Bash]
---

# Init Project

Scaffold a new Tytos project following team standards. Creates a complete Next.js project with Supabase Auth, HeroUI, Prisma, Docker, and all enforcement infrastructure.

## Step 1: Gather Project Info

Ask the user for:
- **Project name** (kebab-case, e.g., `my-app`) — use $ARGUMENTS if provided
- **Brief description** (one line)
- **Supabase project URL** (or "create later")
- **Port number** (default: 3000)

## Step 2: Create Next.js Project

```bash
bunx create-next-app@latest $PROJECT_NAME --typescript --tailwind --eslint --app --src-dir --import-alias "@/*" --use-bun
cd $PROJECT_NAME
```

## Step 3: Install Approved Dependencies

```bash
# Core
bun add @supabase/supabase-js @supabase/ssr @heroui/react @heroui/system @heroui/theme framer-motion @prisma/client zod zustand @tanstack/react-query

# Dev
bun add -d prisma tsx
```

## Step 4: Copy Standards Infrastructure

Copy the following from the tytos/standards repo (or generate them):

### 4a. CLAUDE.md
Copy the master CLAUDE.md template to project root. Replace `[PROJECT_NAME]` with the actual project name.

### 4b. .claude/ directory
Create `.claude/` with:
- `settings.json` — hooks config + permission deny rules (copy from standards/project-template/.claude/settings.json)
- `rules/standards.md` — always-loaded standards
- `rules/testing.md` — testing discipline
- `rules/frontend.md` — path-scoped frontend rules
- `rules/backend.md` — path-scoped backend rules
- `hooks/check-mock-data.sh` — mock data detection
- `hooks/check-custom-auth.sh` — auth violation detection
- `hooks/check-custom-components.sh` — custom UI detection
- `hooks/check-seed-in-migration.sh` — migration seed detection

Make all hook scripts executable: `chmod +x .claude/hooks/*.sh`

### 4c. Prisma Setup

Create `prisma/schema.prisma`:
```prisma
generator client {
  provider = "prisma-client-js"
}

datasource db {
  provider  = "postgresql"
  url       = env("DATABASE_URL")
  directUrl = env("DIRECT_URL")
}
```

Create `prisma/seed.ts`:
```typescript
import { PrismaClient } from "@prisma/client"

const prisma = new PrismaClient()

async function main() {
  console.log("Seeding database...")
  // Add seed data here
}

main()
  .catch((e) => {
    console.error(e)
    process.exit(1)
  })
  .finally(async () => {
    await prisma.$disconnect()
  })
```

### 4d. Supabase Setup

Create `src/lib/supabase/client.ts`:
```typescript
import { createBrowserClient } from "@supabase/ssr"

export function createClient() {
  return createBrowserClient(
    process.env.NEXT_PUBLIC_SUPABASE_URL!,
    process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!
  )
}
```

Create `src/lib/supabase/server.ts`:
```typescript
import { createServerClient } from "@supabase/ssr"
import { cookies } from "next/headers"

export async function createClient() {
  const cookieStore = await cookies()

  return createServerClient(
    process.env.NEXT_PUBLIC_SUPABASE_URL!,
    process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!,
    {
      cookies: {
        getAll() {
          return cookieStore.getAll()
        },
        setAll(cookiesToSet) {
          try {
            cookiesToSet.forEach(({ name, value, options }) =>
              cookieStore.set(name, value, options)
            )
          } catch {
            // The `setAll` method is called from a Server Component
          }
        },
      },
    }
  )
}
```

Create `src/middleware.ts`:
```typescript
import { createServerClient } from "@supabase/ssr"
import { NextResponse, type NextRequest } from "next/server"

export async function middleware(request: NextRequest) {
  let supabaseResponse = NextResponse.next({ request })

  const supabase = createServerClient(
    process.env.NEXT_PUBLIC_SUPABASE_URL!,
    process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!,
    {
      cookies: {
        getAll() {
          return request.cookies.getAll()
        },
        setAll(cookiesToSet) {
          cookiesToSet.forEach(({ name, value }) =>
            request.cookies.set(name, value)
          )
          supabaseResponse = NextResponse.next({ request })
          cookiesToSet.forEach(({ name, value, options }) =>
            supabaseResponse.cookies.set(name, value, options)
          )
        },
      },
    }
  )

  await supabase.auth.getUser()

  return supabaseResponse
}

export const config = {
  matcher: [
    "/((?!_next/static|_next/image|favicon.ico|.*\\.(?:svg|png|jpg|jpeg|gif|webp)$).*)",
  ],
}
```

### 4e. Docker Setup

Create `Dockerfile`:
```dockerfile
FROM node:20-alpine AS base

# Install bun
RUN npm install -g bun

# Dependencies
FROM base AS deps
WORKDIR /app
COPY package.json bun.lock* ./
RUN bun install --frozen-lockfile

# Build
FROM base AS builder
WORKDIR /app
COPY --from=deps /app/node_modules ./node_modules
COPY . .
RUN bun run build

# Runner
FROM base AS runner
WORKDIR /app
ENV NODE_ENV=production
RUN addgroup --system --gid 1001 nodejs
RUN adduser --system --uid 1001 nextjs
COPY --from=builder /app/public ./public
COPY --from=builder --chown=nextjs:nodejs /app/.next/standalone ./
COPY --from=builder --chown=nextjs:nodejs /app/.next/static ./.next/static
USER nextjs
EXPOSE 3000
ENV PORT=3000
CMD ["node", "server.js"]
```

Create `docker-compose.yml`:
```yaml
services:
  app:
    build: .
    ports:
      - "${PORT:-3000}:3000"
    env_file:
      - .env.local
    depends_on:
      - db
    restart: unless-stopped

  db:
    image: postgres:16-alpine
    ports:
      - "5432:5432"
    environment:
      POSTGRES_USER: postgres
      POSTGRES_PASSWORD: postgres
      POSTGRES_DB: app
    volumes:
      - pgdata:/var/lib/postgresql/data
    restart: unless-stopped

volumes:
  pgdata:
```

Create `.dockerignore`:
```
node_modules
.next
.git
.env.local
```

### 4f. Environment

Create `.env.example`:
```
# Supabase
NEXT_PUBLIC_SUPABASE_URL=https://your-project.supabase.co
NEXT_PUBLIC_SUPABASE_ANON_KEY=your-anon-key
SUPABASE_SERVICE_ROLE_KEY=your-service-role-key

# Database (Supabase connection pooler)
DATABASE_URL=postgresql://postgres.[project-ref]:[password]@aws-0-[region].pooler.supabase.com:6543/postgres?pgbouncer=true
DIRECT_URL=postgresql://postgres.[project-ref]:[password]@aws-0-[region].pooler.supabase.com:5432/postgres

# App
PORT=3000
NODE_ENV=development
```

Create `.mcp.json`:
```json
{
  "mcpServers": {
    "supabase": {
      "type": "http",
      "url": "https://mcp.supabase.com/mcp"
    }
  }
}
```

### 4g. Standard Directory Structure

Create these directories:
```
src/
  app/
    (auth)/login/        # Public auth pages
    (dashboard)/         # Protected pages
    api/                 # API routes
  components/
    layouts/             # Layout components
  lib/
    supabase/            # Already created above
    services/            # Business logic
    stores/              # Zustand stores
    utils/               # Utility functions
  hooks/                 # Custom React hooks
  types/                 # TypeScript type definitions
```

### 4h. Update package.json scripts

Add/update these scripts in package.json:
```json
{
  "scripts": {
    "dev": "next dev",
    "build": "next build",
    "start": "next start",
    "lint": "next lint",
    "postinstall": "prisma generate",
    "db:generate": "prisma generate",
    "db:migrate": "prisma migrate dev",
    "db:migrate:deploy": "prisma migrate deploy",
    "db:push": "prisma db push",
    "db:seed": "prisma db seed",
    "db:studio": "prisma studio"
  },
  "prisma": {
    "seed": "tsx prisma/seed.ts"
  }
}
```

### 4i. Update next.config

Ensure `next.config.ts` has standalone output for Docker:
```typescript
const nextConfig = {
  output: "standalone",
}
```

## Step 5: Initialize Git

```bash
git init
git add .
git commit -m "feat: initial project setup with Tytos standards"
```

## Step 6: Print Summary

```
✓ Project scaffolded: $PROJECT_NAME
✓ Standards: CLAUDE.md + .claude/rules/ + .claude/hooks/ + .claude/settings.json
✓ Auth: Supabase client/server/middleware configured
✓ Database: Prisma schema + seed script
✓ Docker: Dockerfile (multi-stage) + docker-compose.yml
✓ UI: HeroUI v3 installed

Next steps:
1. Copy .env.example to .env.local and fill in Supabase credentials
2. Run `bun run db:migrate` after setting DATABASE_URL
3. Run `bun run dev` to verify setup
4. Run `/audit-project` to confirm compliance
```

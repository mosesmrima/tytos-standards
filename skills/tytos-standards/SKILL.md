---
name: tytos-standards
description: "Tytos team development standards reference. Activate when starting features, reviewing code, or making tech decisions in Tytos projects. Covers approved tech stack, anti-patterns, Supabase Auth patterns, HeroUI components, Docker setup, and Prisma conventions."
---

# Tytos Development Standards

## Approved Tech Stack

| Layer | Technology | Package | Notes |
|-------|-----------|---------|-------|
| Runtime | Bun | `bun` | Package manager + runtime |
| Framework | Next.js (App Router) | `next` | Always use App Router, not Pages |
| Language | TypeScript (strict) | `typescript` | `strict: true` in tsconfig |
| Auth | Supabase Auth | `@supabase/ssr`, `@supabase/supabase-js` | ONLY approved auth solution |
| Database | Supabase PostgreSQL | `@prisma/client` | Via Prisma ORM |
| UI | HeroUI v3 | `@heroui/react` | Primary UI library |
| UI (alt) | shadcn/ui | `shadcn` | Secondary option |
| Styling | Tailwind CSS v4 | `tailwindcss` | No CSS modules, no styled-components |
| Server State | TanStack Query | `@tanstack/react-query` | For all API data |
| Client State | Zustand | `zustand` | For UI/client state only |
| Validation | Zod v4 | `zod` | Schema validation everywhere |
| Containers | Docker | `Dockerfile` + `docker-compose.yml` | Required for all projects |

## Anti-Pattern Reference

### 1. Hardcoded Mock/Stub Data

The #1 problem on the team. AI tools often generate fallback data that masks real errors.

```typescript
// BAD — masks the real error, dev thinks everything works
async function getUsers() {
  try {
    const { data, error } = await supabase.from("users").select("*")
    if (error) throw error
    return data
  } catch (error) {
    // This hides the actual problem!
    return [
      { id: 1, name: "John Doe", email: "john@example.com" },
      { id: 2, name: "Jane Doe", email: "jane@example.com" },
    ]
  }
}

// GOOD — error is visible, can be debugged
async function getUsers() {
  const { data, error } = await supabase.from("users").select("*")
  if (error) {
    console.error("Failed to fetch users:", error)
    throw error
  }
  return data
}
```

```typescript
// BAD — API route returns fake data on error
export async function GET() {
  try {
    const users = await prisma.user.findMany()
    return Response.json({ success: true, data: users, error: null })
  } catch (error) {
    return Response.json({
      success: true, // WRONG — this should be false
      data: [{ id: "mock", name: "Mock User" }], // WRONG — fake data
      error: null,
    })
  }
}

// GOOD — proper error response
export async function GET() {
  try {
    const users = await prisma.user.findMany()
    return Response.json({ success: true, data: users, error: null })
  } catch (error) {
    console.error("Failed to fetch users:", error)
    return Response.json(
      { success: false, data: null, error: "Failed to fetch users" },
      { status: 500 }
    )
  }
}
```

### 2. Custom Auth Instead of Supabase

```typescript
// BAD — NextAuth setup (DO NOT USE)
import NextAuth from "next-auth"
import CredentialsProvider from "next-auth/providers/credentials"

export const authOptions = {
  providers: [
    CredentialsProvider({
      // Custom auth logic...
    }),
  ],
}

// GOOD — Supabase Auth (server-side)
import { createClient } from "@/lib/supabase/server"

export async function getUser() {
  const supabase = await createClient()
  const { data: { user }, error } = await supabase.auth.getUser()
  if (error || !user) throw new Error("Not authenticated")
  return user
}
```

```typescript
// BAD — Manual JWT
import jwt from "jsonwebtoken"

function verifyToken(token: string) {
  return jwt.verify(token, process.env.JWT_SECRET!)
}

// GOOD — Supabase handles tokens automatically
import { createClient } from "@/lib/supabase/server"

async function getAuthenticatedUser() {
  const supabase = await createClient()
  const { data: { user } } = await supabase.auth.getUser()
  return user
}
```

### 3. Custom UI Components

```tsx
// BAD — Building Button from scratch
export function Button({ children, onClick, variant = "primary" }) {
  return (
    <button
      onClick={onClick}
      className={`px-4 py-2 rounded ${
        variant === "primary" ? "bg-blue-500 text-white" : "bg-gray-200"
      }`}
    >
      {children}
    </button>
  )
}

// GOOD — Using HeroUI
import { Button } from "@heroui/react"

// Use directly in components:
<Button color="primary" variant="solid" onPress={handleClick}>
  Click me
</Button>
<Button color="danger" variant="flat" isLoading={loading}>
  Delete
</Button>
```

```tsx
// BAD — Custom Modal from scratch
export function Modal({ isOpen, onClose, children }) {
  if (!isOpen) return null
  return (
    <div className="fixed inset-0 bg-black/50 flex items-center justify-center">
      <div className="bg-white rounded-lg p-6">{children}</div>
    </div>
  )
}

// GOOD — HeroUI Modal
import { Modal, ModalContent, ModalHeader, ModalBody, ModalFooter, Button, useDisclosure } from "@heroui/react"

function MyComponent() {
  const { isOpen, onOpen, onOpenChange } = useDisclosure()

  return (
    <>
      <Button onPress={onOpen}>Open Modal</Button>
      <Modal isOpen={isOpen} onOpenChange={onOpenChange}>
        <ModalContent>
          {(onClose) => (
            <>
              <ModalHeader>Title</ModalHeader>
              <ModalBody>Content here</ModalBody>
              <ModalFooter>
                <Button color="danger" variant="light" onPress={onClose}>Close</Button>
                <Button color="primary" onPress={onClose}>Action</Button>
              </ModalFooter>
            </>
          )}
        </ModalContent>
      </Modal>
    </>
  )
}
```

### 4. Seed Data in Migrations

```sql
-- BAD — migration file (20240101_init.sql)
CREATE TABLE users (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL,
  email TEXT UNIQUE NOT NULL
);

-- This does NOT belong in a migration!
INSERT INTO users (name, email) VALUES
  ('Admin', 'admin@example.com'),
  ('Test User', 'test@example.com');
```

```typescript
// GOOD — separate seed file (prisma/seed.ts)
import { PrismaClient } from "@prisma/client"

const prisma = new PrismaClient()

async function main() {
  await prisma.user.upsert({
    where: { email: "admin@example.com" },
    update: {},
    create: { name: "Admin", email: "admin@example.com" },
  })
}

main()
  .catch(console.error)
  .finally(() => prisma.$disconnect())
```

## Supabase Auth Patterns

### Browser Client (`src/lib/supabase/client.ts`)

```typescript
import { createBrowserClient } from "@supabase/ssr"

export function createClient() {
  return createBrowserClient(
    process.env.NEXT_PUBLIC_SUPABASE_URL!,
    process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!
  )
}
```

### Server Client (`src/lib/supabase/server.ts`)

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
        getAll: () => cookieStore.getAll(),
        setAll: (cookiesToSet) => {
          try {
            cookiesToSet.forEach(({ name, value, options }) =>
              cookieStore.set(name, value, options)
            )
          } catch {}
        },
      },
    }
  )
}
```

### Login/Signup

```typescript
// Sign up
const { data, error } = await supabase.auth.signUp({
  email: "user@example.com",
  password: "password123",
})

// Sign in
const { data, error } = await supabase.auth.signInWithPassword({
  email: "user@example.com",
  password: "password123",
})

// Sign out
await supabase.auth.signOut()

// Get current user (server-side)
const { data: { user } } = await supabase.auth.getUser()
```

## Docker Patterns

### Multi-Stage Dockerfile

```dockerfile
FROM node:20-alpine AS base
RUN npm install -g bun

FROM base AS deps
WORKDIR /app
COPY package.json bun.lock* ./
RUN bun install --frozen-lockfile

FROM base AS builder
WORKDIR /app
COPY --from=deps /app/node_modules ./node_modules
COPY . .
RUN bun run build

FROM base AS runner
WORKDIR /app
ENV NODE_ENV=production
COPY --from=builder /app/public ./public
COPY --from=builder /app/.next/standalone ./
COPY --from=builder /app/.next/static ./.next/static
EXPOSE 3000
CMD ["node", "server.js"]
```

### docker-compose.yml

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

  db:
    image: postgres:16-alpine
    environment:
      POSTGRES_USER: postgres
      POSTGRES_PASSWORD: postgres
      POSTGRES_DB: app
    volumes:
      - pgdata:/var/lib/postgresql/data

volumes:
  pgdata:
```

## Error Handling Pattern

```typescript
// Standard API response envelope
interface ApiResponse<T> {
  success: boolean
  data: T | null
  error: string | null
}

// In API routes
export async function GET(): Promise<Response> {
  try {
    const data = await service.getData()
    return Response.json({ success: true, data, error: null } satisfies ApiResponse<typeof data>)
  } catch (error) {
    console.error("GET /api/resource failed:", error)
    return Response.json(
      { success: false, data: null, error: "Failed to fetch resource" } satisfies ApiResponse<null>,
      { status: 500 }
    )
  }
}
```

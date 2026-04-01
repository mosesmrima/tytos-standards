---
paths:
  - "src/app/api/**"
  - "src/lib/services/**"
  - "src/lib/supabase/**"
  - "prisma/**"
---

# Backend Standards

## Authentication

- Use `@supabase/ssr` for server-side auth: `createServerClient` in Server Components and API routes
- Use `@supabase/supabase-js` for client-side: `createBrowserClient` in Client Components
- Auth middleware in `src/middleware.ts` refreshes sessions via `@supabase/ssr`
- NEVER import `next-auth`, `jsonwebtoken`, `jose`, or `passport`
- Use Supabase Row Level Security (RLS) for data access control

## API Routes

- All API routes return the standard envelope: `{ success: boolean, data: T | null, error: string | null }`
- Wrap handler logic in try/catch — never let unhandled exceptions reach the client
- Validate request bodies with Zod schemas before processing
- Return appropriate HTTP status codes (200, 201, 400, 401, 403, 404, 500)

```typescript
// Standard API route pattern
export async function POST(request: Request) {
  try {
    const body = await request.json()
    const validated = mySchema.parse(body)
    const result = await myService.create(validated)
    return Response.json({ success: true, data: result, error: null })
  } catch (error) {
    if (error instanceof z.ZodError) {
      return Response.json({ success: false, data: null, error: error.message }, { status: 400 })
    }
    console.error("API error:", error)
    return Response.json({ success: false, data: null, error: "Internal server error" }, { status: 500 })
  }
}
```

## Database / Prisma

- Schema changes go in Prisma migrations (`bun run db:migrate`)
- Seed data goes in `prisma/seed.ts` (`bun run db:seed`) — NEVER in migration files
- Use Prisma's type-safe queries — no raw SQL unless absolutely necessary
- Always use transactions for multi-step operations
- Never expose database IDs in URLs without RLS or ownership checks

## Service Layer

- Business logic lives in `src/lib/services/` — not in API routes or components
- Services receive validated data and return typed results
- Services throw errors on failure — never return mock/stub data as fallback
- Keep services stateless — no side effects beyond the database operation

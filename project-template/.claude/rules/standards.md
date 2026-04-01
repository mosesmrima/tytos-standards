# Tytos Standards (Always Loaded)

## Approved Stack

- **Auth**: Supabase Auth (`@supabase/ssr`) — no NextAuth, no custom JWT, no passport
- **UI**: HeroUI v3 (`@heroui/react`) preferred, shadcn acceptable — no custom primitives
- **Database**: Supabase PostgreSQL via Prisma (`@prisma/client`)
- **State**: TanStack Query (server), Zustand (client)
- **Validation**: Zod v4
- **Runtime**: Bun
- **Styling**: Tailwind CSS v4

## Anti-Patterns (NEVER)

1. Never return mock/stub/fake data when a real call fails — propagate errors
2. Never put seed data (`INSERT INTO`) in Prisma/Supabase migrations — use `prisma/seed.ts`
3. Never import `next-auth`, `jsonwebtoken`, `jose`, or `passport`
4. Never build custom Button, Card, Modal, Input, Select, Dialog, Table — use HeroUI or shadcn
5. Never ship without `Dockerfile` + `docker-compose.yml`

## Error Response Envelope

All API routes return: `{ success: boolean, data: T | null, error: string | null }`

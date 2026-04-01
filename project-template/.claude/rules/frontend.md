---
paths:
  - "src/components/**"
  - "src/app/**/page.tsx"
  - "src/app/**/layout.tsx"
---

# Frontend Standards

## UI Components

- Import from `@heroui/react` for: Button, Card, Modal, Input, Select, Dialog, Table, Tabs, Dropdown, Navbar, Avatar, Badge, Chip, Tooltip, Popover, Accordion, Divider, Skeleton, Spinner, Progress
- If HeroUI doesn't have a component, use shadcn/ui
- NEVER build these from scratch with raw HTML/Tailwind
- Thin wrappers that extend HeroUI/shadcn with project-specific props are acceptable

## Styling

- Use Tailwind CSS v4 utility classes
- No inline `style={{}}` attributes
- No CSS modules or styled-components
- Use HeroUI's built-in theming for colors and dark mode

## Component Patterns

- Functional components only (no class components)
- One component per file, PascalCase filename matching component name
- Props interface: `interface MyComponentProps { ... }`
- Use `"use client"` directive only when the component needs client-side interactivity
- Default to Server Components — only add `"use client"` when you need hooks, event handlers, or browser APIs

## State Management

- Server state (API data): `@tanstack/react-query` with `useQuery` / `useMutation`
- Client state (UI state): `zustand` stores in `src/lib/stores/`
- Form state: React Hook Form + Zod resolver
- Never use `useState` for data that comes from the server — use TanStack Query

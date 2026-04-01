# Testing Standards (Always Loaded)

## Testing Discipline

- NEVER just look at pages visually — interact with features (click, fill, submit, verify)
- NEVER skip past a bug — STOP, investigate root cause, fix, verify the fix
- Test the full user flow, not just the surface
- Every test has an action ("I did X") and a verification ("Result was Y because Z")

## TDD Workflow (Mandatory for Non-Trivial Features)

1. **RED** — Write the test first. It should fail.
2. **GREEN** — Write minimal implementation to pass the test.
3. **REFACTOR** — Clean up while keeping tests green.
4. Target 80%+ test coverage.

## Test Organization

- Unit tests: `*.test.ts` next to source files or in `__tests__/`
- Integration tests: `tests/integration/`
- E2E tests: `tests/e2e/`
- Test fixtures: `tests/fixtures/` (mock data is ONLY acceptable in test files)

## Never Do

- Never mock the database in integration tests — use a real test database
- Never skip failing tests — fix the underlying issue
- Never write tests that only check if the page renders — test behavior

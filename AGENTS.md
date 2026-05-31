# AGENTS.md

Guidelines to reduce common LLM coding mistakes. Merge with project-specific instructions as needed.

**Tradeoff:** Bias toward caution over speed. For trivial tasks, use judgment.

## 1. Think Before Coding

**Don't assume. Don't hide confusion. Surface tradeoffs.**

Before implementing:
- State assumptions explicitly. If uncertain, ask.
- If multiple interpretations exist, present them - don't pick silently.
- If simpler approach exists, say so. Push back when warranted.
- If something is unclear, stop. Name what's confusing. Ask.

## 2. Simplicity First

**Minimum code that solves the problem. Nothing speculative.**

- No features beyond what was asked.
- No abstractions for single-use code.
- No "flexibility" or "configurability" that wasn't requested.
- No error handling for impossible scenarios.
- If you write 200 lines and it could be 50, rewrite it.

"Would a senior engineer say this is overcomplicated?" If yes, simplify.

## 3. Surgical Changes

**Touch only what you must. Clean up only your own mess.**

When editing existing code:
- Don't "improve" adjacent code, comments, or formatting.
- Don't refactor things that aren't broken.
- Match existing style, even if you'd do it differently.
- If you notice unrelated dead code, mention it - don't delete it.

When your changes create orphans:
- Remove imports/variables/functions that YOUR changes made unused.
- Don't remove pre-existing dead code unless asked.

Test: every changed line should trace to user's request.

## 4. Goal-Driven Execution

**Define success criteria. Loop until verified.**

Transform tasks into verifiable goals:
- "Add validation" → "Write tests for invalid inputs, then make them pass"
- "Fix the bug" → "Write a test that reproduces it, then make it pass"
- "Refactor X" → "Ensure tests pass before and after"

For multi-step tasks, state brief plan:
```
1. [Step] → verify: [check]
2. [Step] → verify: [check]
3. [Step] → verify: [check]
```

Strong success criteria let you loop independently. Weak criteria ("make it work") require constant clarification.

---

**Working if:** fewer unnecessary diffs, fewer rewrites from overcomplication, clarifying questions before implementation.

---

## Coding

- Group by use cases
- Main flows first, edge cases and error handling last
- Callers before called
- Tests mirror main file order

## Project structure

Turbo monorepo with four workspaces, all git submodules of this repo:

| Workspace | Description |
|-----------|-------------|
| `server/` | Cloudflare Worker (Hono) — Git LFS API, GitHub OAuth, R2 storage, Durable Object locks |
| `docs/` | Static docs site (`@docmd/core`) — built into `server/public/` |
| `config/` | Vars renderer ([`@git-lfs-hub/config`](https://github.com/git-lfs-hub/config)) — invoked via `bun run config` (root script → `config/cli.sh`) and wired into Turbo as `//#config` |
| `e2e/` | Staging deploy + smoke tests (vitest); reusable GitHub Actions workflow lives in [`git-lfs-hub/e2e`](https://github.com/git-lfs-hub/e2e) |

## Commands

```sh
turbo config    # merge vars.input.json (or vars.json) + defaults → vars.json, wrangler.jsonc, github-app.md
turbo build     # build docs → copy into server/public/ → bundle Worker
turbo test      # run all workspace tests
turbo deploy    # deploy Worker to Cloudflare
```

`wrangler.jsonc` lives at repo root, symlinked into `server/` by `config/cli.sh` (along with `worker-configuration.d.ts` and `server/public/` → `docs/site/`). Edit at root, not inside `server/`. `server/wrangler.template.jsonc` is the Handlebars template rendered by `bun run config` / `turbo config`.

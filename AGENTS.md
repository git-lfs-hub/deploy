# AGENTS.md

## Project structure

Turbo monorepo with workspaces, all git submodules of this repo:

| Workspace | Description |
|-----------|-------------|
| server/ | Cloudflare Worker (Hono) — Git LFS API, GitHub OAuth, R2 lfs-objects storage, Durable Object locks |
| admin/ | Cloudflare Worker (SvelteKit) — admin UI, LFS GC, reconciliation |
| auth/ | Shared reusable auth library |
| docs/ | Static user guide — built into server/public/ |
| config/ | Renders vars.json and wrangler.jsonc — config/cli.sh invoked via `bun run config`, wired into Turbo as //#config |
| e2e/ | Staging deploy + smoke tests (vitest); `git-lfs-hub/e2e` reusable GitHub Actions |

## Commands

```sh
turbo config        # merge vars[.input].json + defaults → vars.json, wrangler[.admin].jsonc, github-app.md
turbo build         # build docs → copy into server/public/ → bundle server/ and admin/ Workers
turbo test          # run all workspace tests
turbo dev           # run admin/ dev with server/ as "auxilaryWorker" without docs/
turbo dev:server    # run server/ dev including docs/
turbo deploy        # deploy server/ (with docs/) and admin/ Workers to Cloudflare
```

### Bun instead of node/npm/npx/pnpm/yarn

- Use `bun <file>`, not `node <file>` or `ts-node <file>`
- Use `bun install`, not `npm install` or `yarn install` or `pnpm install`
- Use `bun run <script>`, not `npm run <script>` or `yarn run <script>` or `pnpm run <script>`
- Use `bunx <package> <command>`, not `npx <package> <command>`
- Bun automatically loads .env, so don't use dotenv.

## Configs

### vars.json and wrangler.jsonc

Rendered by config/cli.sh from server/, admin/ and docs/ templates and simlinked back into server/, admin/ and docs/. Edit templates, not rendered configs.
- vars.input.json + config/vars.template.json -> vars.json -> docs/vars.json
- server/wrangler.template.jsonc + vars.json -> wrangler.jsonc -> server/wrangler.jsonc
- admin/wrangler.template.jsonc + vars.json -> wrangler.admin.jsonc -> admin/wrangler.jsonc

# worker-configuration.d.ts

Don't edit directly, run `wrangler types` to create/update. Also symlinked:
- worker-configuration.d.ts -> server/worker-configuration.d.ts
- worker-configuration.admin.d.ts -> admin/worker-configuration.d.ts

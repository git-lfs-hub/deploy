# vars

Renders deployment artifacts from Handlebars templates using workspace configuration.

## Files

| File | Purpose |
|------|---------|
| `vars.defaults.json` | Default values; keys are overridden by `vars.json` |
| `vars.schema.json` | JSON Schema; merged vars are validated against this |
| `init.ts` | Build script |
| `lib.ts` | Core functions |
| `lib.test.ts` | Unit tests |

## Inputs (workspace root)

- `vars.json` — user-provided configuration
- `server/wrangler.template.jsonc` — Cloudflare Workers config template
- `server/github-app.template.md` — GitHub App setup guide template

## Outputs (workspace root)

- `vars.resolved.json` — merged + resolved vars (used by `server/` and `docs/` via symlink)
- `wrangler.jsonc` — rendered from `server/wrangler.template.jsonc` (created once, then skipped)
- `github-app.md` — rendered from `server/github-app.template.md`

## Build pipeline

```
vars.json + vars.defaults.json
  → filter defaults (drop keys present in vars.json)
  → render remaining defaults as Handlebars templates (vars.json as context)
  → merge: { ...resolvedDefaults, ...normalizedVars }
  → validate against vars.schema.json
  → write vars.resolved.json
  → render server/wrangler.template.jsonc → wrangler.jsonc
  → render server/github-app.template.md → github-app.md
```

## Run

```sh
bun run init.ts
```

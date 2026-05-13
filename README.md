# {{orgName}} LFS Hub

A Git LFS server for the {{orgName}} organization, deployed as a Cloudflare Worker. Stores objects in Cloudflare R2 and authenticates via GitHub OAuth. Includes an integrated documentation site for onboarding team members to Git LFS.

## Packages

| Path | Description |
|------|-------------|
| `server/` | Cloudflare Worker (Hono) — Git LFS API, GitHub OAuth, R2 storage, Durable Object locks |
| `docs/` | Documentation site (`@docmd/core`) — built into `server/public/` and served as the landing page |

## Install dependencies

```sh
bun install
```

## Test

```sh
turbo test
```

## Build

```sh
turbo build
```

Builds the docs site first, then links it into `server/public/` before bundling the Worker.

## Development

```sh
turbo dev
```

## Deploy

```sh
turbo deploy
```

## Configuration

Worker bindings and non-secret vars live in `wrangler.jsonc`. Secrets are set via Wrangler and never committed:

```sh
wrangler secret put S3_ACCESS_KEY_ID
wrangler secret put S3_SECRET_ACCESS_KEY
wrangler secret put GITHUB_CLIENT_ID
wrangler secret put GITHUB_CLIENT_SECRET
wrangler secret put LOGIN_SECRET        # openssl rand -hex 32
```

See `server/README.md` for full setup instructions (R2 bucket, GitHub OAuth App registration).

Docs site variables (title, org URL, LFS server hostname) live in `docs/vars.json`.

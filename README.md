# Git LFS Hub

A self-hosted Git LFS server deployed as a Cloudflare Worker. Stores objects in Cloudflare R2 and authenticates via GitHub OAuth. Includes an integrated documentation site for onboarding team members to Git LFS.

## Packages

| Path | Description |
|------|-------------|
| `vars/` | Config renderer — merges `vars.json` with defaults, validates, renders `wrangler.jsonc` and `github-app.md` |
| `server/` | Cloudflare Worker (Hono) — Git LFS API, GitHub OAuth, R2 storage, Durable Object locks |
| `docs/` | Documentation site (`@docmd/core`) — built into `server/public/` and served as the landing page |

## Install dependencies

```sh
bun install
```

## Configuration

**1. Fill in `vars.json`** (copy from `vars.example.json`):

For a GitHub organization:

```json
{
  "org": "My Org",
  "github": { "org": "my-org" },
  "cloudflare": { "accountId": "...", "accountSlug": "..." }
}
```

For a personal account:

```json
{
  "org": "My Name",
  "github": { "users": "my-github-login", "owners": "my-github-login" },
  "cloudflare": { "accountId": "...", "accountSlug": "..." }
}
```

| Key | Description |
|-----|-------------|
| `cloudflare.accountSlug` | Sets the Worker URL prefix (`GITHUB_APP_HOME`) |
| `cloudflare.accountId` | Sets the R2 endpoint URL (`S3_ENDPOINT`) |
| `github.org[s]` | Active org members get access; up to 5 orgs total |
| `github.users` | Restricts access to specific logins (on top of org check) |
| `github.owners` | Owner slugs accepted in LFS URLs; overrides `github.org[s]` for routing but not access |

List values (`github.orgs`, `github.users`, `github.owners`) accept a JSON array or a space/comma-separated string.

**2. Render config artifacts:**

```sh
turbo init
```

Writes `vars.resolved.json`, renders `wrangler.jsonc`, and generates `github-app.md` with OAuth setup instructions.

**3. Create an R2 API token:**

Account dashboard → R2 → API tokens → Create API token (Object Read & Write, scoped to your bucket).

```sh
wrangler secret put S3_ACCESS_KEY_ID      # R2 Access Key ID
wrangler secret put S3_SECRET_ACCESS_KEY  # R2 Secret Access Key
```

**4. Register the GitHub OAuth App** — follow the generated `github-app.md`, then:

```sh
wrangler secret put GITHUB_CLIENT_ID
wrangler secret put GITHUB_CLIENT_SECRET
wrangler secret put LOGIN_SECRET          # openssl rand -hex 32
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

### Locally

```sh
turbo deploy
```

### GitHub Actions

Two workflows are included:

| Workflow | Trigger | Jobs |
|----------|---------|------|
| `pr.yml` | Pull requests | `test` + `build` |
| `main.yml` | Push to `main`, manual | `test` + `build` + `deploy` |

Both workflows check out submodules, install dependencies (frozen lockfile, cached), and post a Turbo run summary.

Configure under **Settings → Secrets and variables → Actions**:

| Name | Kind | Description |
|------|------|-------------|
| `CLOUDFLARE_API_TOKEN` | **Secret** | Cloudflare API token with Worker deploy permissions (deploy job only) |
| `VARS_JSON` | Variable | Contents of `vars.json` (optional; omit if `vars.json` is committed) |
| `TURBO_TEAM` | Variable | Turbo team slug (optional) |
| `TURBO_TEAMID` | Variable | Turbo team ID (optional) |
| `TURBO_TOKEN` | **Secret** | Turbo remote cache token (optional) |

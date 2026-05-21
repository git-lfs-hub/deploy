# Git LFS Hub

A self-hosted Git LFS server deployed as a Cloudflare Worker. Stores objects in Cloudflare R2 and authenticates via GitHub OAuth. Includes an integrated documentation site for onboarding team members to Git LFS.

## Packages

| Path      | Description                                                                                     |
| --------- | ----------------------------------------------------------------------------------------------- |
| `server/` | Cloudflare Worker (Hono) — Git LFS API, GitHub OAuth, R2 storage, Durable Object locks          |
| `docs/`   | Documentation site (`@docmd/core`) — built into `server/public/` and served as the landing page |

Config rendering is handled by the external [`@git-lfs-hub/config`](https://github.com/git-lfs-hub/config) package, invoked via `bun run config` / `turbo config` (see below).

## Install dependencies

```sh
bun install
```

## Fork or template

Use this repository as a GitHub template or fork for your own deployment:

1. Create a new repository from the template (or fork).
2. `bun install`
3. Follow [Configuration](#configuration) below.
4. **Commit** `vars.input.json` and the rendered artifacts (`vars.json`, `wrangler.jsonc`, etc.) in your repo. Or set the `GLH_VARS_JSON` actions variable from `vars[.input].json` in CI.

## Configuration

**1. Fill in `vars.input.json`** (copy from `vars.input.example.json` in [`git-lfs-hub/config`](https://github.com/git-lfs-hub/config)):

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
  "github": { "user": "my-github-login" },
  "cloudflare": { "accountId": "...", "accountSlug": "..." }
}
```

| Key                      | Description                                                                           |
| ------------------------ | ------------------------------------------------------------------------------------- |
| `cloudflare.accountSlug` | Sets the Worker URL prefix (`GITHUB_APP_HOME`)                                        |
| `cloudflare.accountId`   | Sets the R2 endpoint URL (`S3_ENDPOINT`)                                              |
| `github.org[s]`          | Org mode — active members of up to 5 orgs get access                                  |
| `github.user`            | User mode — single GitHub login gets access (mutually exclusive with `github.org[s]`) |

`github.orgs` accepts a JSON array or a space/comma-separated string.

**2. Render config artifacts:**

```sh
bun run config       # or: turbo config
```

Invokes `bunx github:git-lfs-hub/config`. Reads `vars.input.json` (or `vars.json` as fallback), merges with package defaults, validates, writes `vars.json`, and renders `wrangler.jsonc` + `github-app.md`.

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

| Workflow   | Trigger                | Jobs                                              |
| ---------- | ---------------------- | ------------------------------------------------- |
| `pr.yml`   | Pull requests          | `test` + `staging` (deploy + e2e against staging Worker) |
| `main.yml` | Push to `main`, manual | `deploy` + `smoke` (e2e against prod Worker)             |

Both workflows check out submodules, install dependencies (frozen lockfile, cached), and post a Turbo run summary.

Configure under **Settings → Secrets and variables → Actions**:

| Name                   | Kind       | Description                                                                         |
| ---------------------- | ---------- | ----------------------------------------------------------------------------------- |
| `CLOUDFLARE_API_TOKEN` | **Secret** | Cloudflare API token with Worker deploy permissions (deploy job only)               |
| `GLH_VARS_JSON`        | Variable   | Contents of `vars[.input].json`. Required unless `vars.json` are already committed. |
| `TURBO_TEAM`           | Variable   | Turbo team slug (optional)                                                          |
| `TURBO_TEAMID`         | Variable   | Turbo team ID (optional)                                                            |
| `TURBO_TOKEN`          | **Secret** | Turbo remote cache token (optional)                                                 |

## Staging

`pr.yml` deploys every same-repo PR to a shared **`lfs-server-staging`** Worker and runs live staging tests (authenticated docs check + real `git lfs push` against [`git-lfs-hub/test`](https://github.com/git-lfs-hub/test)). Production stays on `main` only.

End-to-end test scripts live in the [`git-lfs-hub/e2e`](https://github.com/git-lfs-hub/e2e) repo, included here as a submodule at `e2e/`. The same scripts run against the production Worker as a post-deploy smoke from `main.yml`.

### Configure under **Settings → Secrets and variables → Actions**

| Name                       | Kind       | Description                                                                                                                |
| -------------------------- | ---------- | -------------------------------------------------------------------------------------------------------------------------- |
| `GLH_STAGING_GITHUB_PAT`   | **Secret** | Classic PAT for a bot account that is an active member of `GITHUB_ORG` (`read:org`) with Write on `git-lfs-hub/test` (`repo`). Used by both PR e2e and `main.yml` smoke. |
| `GLH_STAGING_LOGIN_SECRET` | **Secret** | Same hex value as `LOGIN_SECRET` uploaded to the staging Worker via `wrangler secret put`.                                  |
| `GLH_LOGIN_SECRET`         | **Secret** | Same hex value as `LOGIN_SECRET` uploaded to the production Worker. Used by `main.yml` smoke job only.                       |

Staging reuses the production `GLH_VARS_JSON` — the reusable workflow appends `-staging` to `cloudflare.workerName` and `s3.bucket` internally.

### One-time staging setup

1. `bunx wrangler r2 bucket create lfs-objects-staging`
2. Trigger `pr.yml` once (e.g. via **Actions → PR → Run workflow**) to create the `lfs-server-staging` Worker.
3. Upload Worker secrets to the new script (laptop, once):
   ```sh
   for name in S3_ACCESS_KEY_ID S3_SECRET_ACCESS_KEY GITHUB_CLIENT_ID GITHUB_CLIENT_SECRET LOGIN_SECRET; do
     printf '%s' "$value" | bunx wrangler secret put "$name" --name lfs-server-staging
   done
   ```
4. Store the same `LOGIN_SECRET` value as `GLH_STAGING_LOGIN_SECRET`.

### Updating e2e scripts

```sh
git submodule update --remote e2e
git add e2e && git commit -m "chore(e2e): bump e2e submodule"
```

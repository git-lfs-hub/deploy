# Git LFS Hub — deploy

The monorepo that gets a Git LFS Hub instance running on your own Cloudflare account. This is the **entry point** of the stack — for the bigger picture (what Git LFS Hub does, who it's for, how the repos fit together) see the [org overview](https://github.com/git-lfs-hub).

## The flow

1. Clone or use this repo as a GitHub template.
2. Edit `vars.input.json` with your Cloudflare account, R2 bucket name, GitHub org or user, and OAuth app details.
3. `bun run config` renders `wrangler.jsonc` and `github-app.md` guide.
4. Create the R2 bucket and follow `github-app.md` to register the OAuth App, then `wrangler secret put` the secrets.
5. `bun run deploy` ships to Cloudflare.

Your team can now point their `.lfsconfig` at the deployed endpoint.

## Packages

This repo composes four other repos in the stack:

- **[config/](https://github.com/git-lfs-hub/config)** — renders configs; invoked via `bun run config` or `turbo config`.
- **[server/](https://github.com/git-lfs-hub/server)** — Cloudflare Worker (Hono): Git LFS API, GitHub OAuth, R2 storage, Durable Object locks.
- **[docs/](https://github.com/git-lfs-hub/docs)** — built with [docmd](https://github.com/docmd-io/docmd) into `server/public/` and served as the landing page.
- **[e2e/](https://github.com/git-lfs-hub/e2e)** — staging deploy + smoke test harness used by CI.

## Install dependencies

```sh
bun install
```

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
bun run config  # or:   turbo config
```

* **Commit** `vars.input.json` and the rendered artifacts in your repo:
  * `vars.json`,
  * `wrangler.jsonc` and
  * `github-app.md` (optional).
* **Or** set the `GLH_VARS_JSON` actions variable from `vars[.input].json` in CI.

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
bun run test    # or:   turbo test
```

## Build

```sh
bun run build   # or:   turbo build
```

Builds the docs site first, then links it into `server/public/` before bundling the Worker.

## Development

```sh
bun run dev     # or:   turbo dev
```

## Deploy

### Locally

```sh
bun run deploy  # or:   turbo deploy
```

### GitHub Actions

Two workflows are included:

- **`pr.yml`** — pull requests: `test` + `staging` (deploy + e2e against staging Worker)
- **`main.yml`** — push to `main` or manual: `deploy` + `smoke` (e2e against prod Worker)

Both workflows check out submodules, install dependencies (frozen lockfile, cached), and post a Turbo run summary.

Configure under **Settings → Secrets and variables → Actions**:

| Name | Description |
| ---- | ----------- |
| `CLOUDFLARE_API_TOKEN` (**secret**) | Cloudflare API token with Worker deploy permissions (deploy job only) |
| `GLH_VARS_JSON` (variable) | Contents of `vars[.input].json` (if not committed) |
| `TURBO_TEAM` (variable) | Turbo team slug (optional) |
| `TURBO_TEAMID` (variable) | Turbo team ID (optional) |
| `TURBO_TOKEN` (**secret**) | Turbo remote cache token (optional) |

## Staging

`pr.yml` deploys every same-repo PR to a shared **`lfs-server-staging`** Worker and runs live staging tests (authenticated docs check + real `git lfs push` against [`git-lfs-hub/test`](https://github.com/git-lfs-hub/test)). Production stays on `main` only.

End-to-end test scripts live in the [`git-lfs-hub/e2e`](https://github.com/git-lfs-hub/e2e) repo, included here as a submodule at `e2e/`. The same scripts run against the production Worker as a post-deploy smoke from `main.yml`.

### Configure under **Settings → Secrets and variables → Actions**

| Name | Description |
| ---- | ----------- |
| `GLH_STAGING_GITHUB_PAT` (**secret**) | Classic PAT for a bot account that is an active member of `GITHUB_ORG` (`read:org`) with Write on `git-lfs-hub/test` (`repo`). Used by both PR e2e and `main.yml` smoke. |
| `GLH_STAGING_LOGIN_SECRET` (**secret**) | Same hex value as `LOGIN_SECRET` uploaded to the staging Worker via `wrangler secret put`. |
| `GLH_LOGIN_SECRET` (**secret**) | Same hex value as `LOGIN_SECRET` uploaded to the production Worker. Used by `main.yml` smoke job only. |

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

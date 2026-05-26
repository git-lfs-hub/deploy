# Contributing

Thanks for your interest in Git LFS Hub. This repository is a Turbo monorepo (`server/` Worker, `docs/` site) used both as the upstream [`git-lfs-hub/deploy`](https://github.com/git-lfs-hub/deploy) project and as a **GitHub template** for self-hosted deployments.

## Upstream vs fork

|                                                    | **Upstream** (`git-lfs-hub/deploy`)                    | **Fork / template instance**                |
| -------------------------------------------------- | ------------------------------------------------------ | ------------------------------------------- |
| Instance config (`vars.json`, `wrangler[.admin].jsonc`, …) | Not committed — CI uses `GLH_VARS_JSON`                | Committed in your repo                      |
| Local ignore for config                            | `.gitignore-upstream` via `scripts/upstream.sh setup`  | Use normal `.gitignore` (no upstream setup) |
| Pre-commit / CI guard                              | `GLH_UPSTREAM=true` + `scripts/upstream.sh pre-commit` | Skipped (no repo variable)                  |

Fork and template setup: [README.md § Fork or template](README.md#fork-or-template). Install, configuration, build, test, and deploy are also documented there.

## Upstream maintainers

Run once per clone:

```sh
bun install
scripts/upstream.sh setup
```

`setup` configures:

- `core.excludesFile` → `.gitignore-upstream` (keeps generated config out of `git status` / accidental `git add`)
- `core.hooksPath` → `.git-hooks-upstream` (runs `scripts/upstream.sh pre-commit` before each commit)

Do **not** commit paths listed in [`.gitignore-upstream`](.gitignore-upstream). If CI fails with “Do not commit these”, remove them from the index (`git rm --cached <path>`) and rely on `GLH_VARS_JSON` in Actions instead.

On the upstream repo, set **Settings → Secrets and variables → Actions → Variables**:

| Variable       | Value  |
| -------------- | ------ |
| `GLH_UPSTREAM` | `true` |

PR and `main` workflows run `scripts/upstream.sh pre-commit` when this variable is set.

## Development

Use [Bun](https://bun.sh) (not Node) from the repo root:

```sh
bun install
bun run config          # after editing vars.input.json
turbo test              # tests + build pipeline
turbo dev               # local dev
turbo build
```

`wrangler[.admin].jsonc` are generated at the repo root and symlinked into `{server,admin}/` by `config/cli.sh` (the `bun run config` script). Edit templates under `{server,admin}/` (`wrangler.template.jsonc`, etc.) and `vars.input.json` — not the generated root files on upstream.

Regenerate Cloudflare types after binding changes:

```sh
turbo types
```

## Pull requests

1. Branch from `main`.
2. Keep changes focused; match existing style in touched files.
3. Run `turbo test` (or at least the tasks your change affects) before opening a PR.
4. Describe what changed and how you tested it.

CI runs on pull requests: checkout, init (Bun install, optional upstream gitignore check, optional `GLH_VARS_JSON` → `vars.input.json`), then `turbo run test build`.

## Questions

Open a [discussion](https://github.com/git-lfs-hub/deploy/discussions) or issue on GitHub if something is unclear or docs should be improved.

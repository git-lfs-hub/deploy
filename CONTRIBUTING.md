# Contributing

Thanks for your interest in Git LFS Hub. This repository is a Turbo monorepo (`server/` Worker, `docs/` site) used both as the upstream [`git-lfs-hub/deploy`](https://github.com/git-lfs-hub/deploy) project and as a **GitHub template** for self-hosted deployments.

## Upstream vs fork

|                                                    | **Upstream** (`git-lfs-hub/deploy`)                   | **Fork / template instance**                |
| -------------------------------------------------- | ----------------------------------------------------- | ------------------------------------------- |
| Instance config (`vars.json`, `wrangler.jsonc`, …) | Not committed — CI uses `GLH_VARS_JSON`               | Committed in your repo                      |
| Local ignore for config                            | `.gitignore-upstream` via `config/upstream.sh setup`  | Use normal `.gitignore` (no upstream setup) |
| Pre-commit / CI guard                              | `GLH_UPSTREAM=true` + `config/upstream.sh pre-commit` | Skipped (no repo variable)                  |

Fork and template setup: [README.md § Fork or template](README.md#fork-or-template). Install, configuration, build, test, and deploy are also documented there.

## Upstream maintainers

Run once per clone:

```sh
bun install
config/upstream.sh setup
```

`setup` configures:

- `core.excludesFile` → `.gitignore-upstream` (keeps generated config out of `git status` / accidental `git add`)
- a `.git/hooks/pre-commit` hook (runs `config/upstream.sh pre-commit` before each commit)

Do **not** commit paths listed in [`.gitignore-upstream`](.gitignore-upstream). If CI fails with “Do not commit these”, remove them from the index (`git rm --cached <path>`) and rely on `GLH_VARS_JSON` in Actions instead.

On the upstream repo, set **Settings → Secrets and variables → Actions → Variables**:

| Variable       | Value  |
| -------------- | ------ |
| `GLH_UPSTREAM` | `true` |

The `Can merge` check enforces the same `.gitignore-upstream` guard in CI when this variable is set.

## Development

Use [Bun](https://bun.sh) (not Node) from the repo root:

```sh
bun install
turbo run config        # after editing vars.input.json (`config` is a reserved Turbo subcommand → use `run`)
turbo test              # tests + build pipeline
turbo dev               # local dev
turbo build
```

`turbo run config` renders `vars.json` at the root (`//#config`) and each worker's `wrangler.jsonc` from it (`server#config`). Edit templates under `server/` (`wrangler.template.jsonc`, etc.) and `vars.input.json` — not the generated files on upstream.

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

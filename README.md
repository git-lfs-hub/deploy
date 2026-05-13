# {{orgName}} LFS Docs

Documentation site for onboarding {{orgName}} team members to Git, GitHub, and the internal Git LFS server at `{{lfsServer}}`.

Built with [`@docmd/core`](https://github.com/nicholasgasior/docmd).

## Development

```sh
bun install
bun run dev
```

## Build

```sh
bun run build
```

## Configuration

Site variables (title, GitHub org URL, LFS server hostname) live in `vars.json` and are injected into Markdown files via the Handlebars plugin.

Docs source is in `docs/`. Assets (logo, favicon, custom CSS) are in `assets/`.

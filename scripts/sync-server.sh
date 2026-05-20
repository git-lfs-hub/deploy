#!/bin/bash
set -Eeo pipefail
cd "$(dirname "$0")/.."

# Update turbo.json whenever changing theese

pushd server > /dev/null
if [ -z "$CI" ]; then
    # Symlink locally for live updates
    ln -sf ../wrangler.jsonc ./
    ln -sf ../worker-configuration.d.ts ./
    ln -sf ../vars.json vars.json
    ln -sfn ../docs/site public
else
    # copy in CI because turbo doesn't restore symlinks from cache
    rsync -avh ../wrangler.jsonc ./
    # rsync -avh ../worker-configuration.d.ts ./
    rsync -avh ../vars.json vars.json
    rsync -avh ../docs/site/ public
fi
popd > /dev/null

#!/bin/bash
set -Eeo pipefail
cd "$(dirname "$0")/.."

# Update turbo.json whenever changing theese

pushd docs > /dev/null
if [ -z "$CI" ]; then
    # Symlink locally for live updates
    ln -sf ../vars.resolved.json vars.json
else
    # copy in CI because turbo doesn't restore symlinks from cache
    rsync -avh ../vars.resolved.json vars.json
fi
popd > /dev/null

rsync -avh assets/ docs/assets

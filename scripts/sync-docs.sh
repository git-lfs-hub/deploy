#!/bin/bash
set -Eeo pipefail
cd "$(dirname "$0")/.."

# Update turbo.json whenever changing theese

pushd docs > /dev/null
ln -sf ../vars.resolved.json vars.json
popd > /dev/null

rsync -avh assets/ docs/assets

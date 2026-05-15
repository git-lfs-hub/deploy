#!/bin/bash
set -Eeo pipefail
cd "$(dirname "$0")/.."

# Update turbo.json whenever changing theese

pushd server > /dev/null
ln -sf ../wrangler.jsonc ./
ln -sf ../worker-configuration.d.ts ./
popd > /dev/null

rsync -avh docs/site/ server/public

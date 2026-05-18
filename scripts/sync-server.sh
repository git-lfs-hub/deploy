#!/bin/bash
set -Eeo pipefail
cd "$(dirname "$0")/.."

# Update turbo.json whenever changing theese

pushd server > /dev/null
ln -sf ../wrangler.jsonc ./
ln -sf ../worker-configuration.d.ts ./
ln -sf ../vars.resolved.json vars.json
ln -sfn ../docs/site public
popd > /dev/null

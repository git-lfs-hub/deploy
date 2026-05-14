#!/bin/bash
set -Eeo pipefail
cd "$(dirname "$0")/.."

pushd docs > /dev/null
ln -sf ../vars.json ./
popd > /dev/null

pushd docs/assets > /dev/null
ln -sf ../../assets/*.png ./
popd > /dev/null

pushd server > /dev/null
ln -sf ../wrangler.jsonc ./
ln -sf ../worker-configuration.d.ts ./
popd > /dev/null

pushd server/public > /dev/null
ln -sf ../../docs/site/* ./
popd > /dev/null

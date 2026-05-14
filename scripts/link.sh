#!/bin/bash
set -Eeo pipefail
cd "$(dirname "$0")/.."

pushd server > /dev/null
ln -sf ../wrangler.jsonc ./
ln -sf ../worker-configuration.d.ts ./
popd > /dev/null

pushd server/public > /dev/null
ln -sf ../../docs/site/* ./
popd > /dev/null

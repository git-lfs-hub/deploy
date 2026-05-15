#!/bin/bash
set -Eeo pipefail
cd "$(dirname "$0")/.."

# Update turbo.json whenever changing theese

rsync -avh wrangler.jsonc worker-configuration.d.ts server/
rsync -avh docs/site/ server/public

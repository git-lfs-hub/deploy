#!/bin/bash
set -Eeo pipefail
cd "$(dirname "$0")/.."

# Update turbo.json whenever changing theese

rsync -avh vars.json docs/
rsync -avh assets/ docs/assets

#!/bin/bash
set -Eeo pipefail
cd "$(dirname "$0")/.."

case " $* " in
  *" --force "*) ;;
  *)
    if [[ -f wrangler.jsonc && -f vars.json ]]; then
      echo "Both vars.json and wrangler.jsonc; pass --force to re-render"
      exit 0
    fi
    ;;
esac

echo bunx github:git-lfs-hub/config "$@"
exec bunx github:git-lfs-hub/config "$@"

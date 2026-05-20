#!/usr/bin/env bash
set -Eeo pipefail
cd "$(dirname "$0")/.."

usage() {
  echo 'Usage: scripts/upstream.sh setup|pre-commit' >&2
  exit 1
}

cmd_setup() {
  echo 'core.excludesFile = .gitignore-upstream'
  git config --local core.excludesFile '.gitignore-upstream'

  echo 'core.hooksPath = .git-hooks-upstream'
  git config --local core.hooksPath '.git-hooks-upstream'
}

cmd_pre_commit() {
  tracked=$(git ls-files -ci --exclude-from='.gitignore-upstream')
  if [[ -n "$tracked" ]]; then
    printf '::error::Do not commit these (see .gitignore-upstream):\n%s\n' "$tracked"
    exit 1
  fi
}

case "${1:-}" in
setup) cmd_setup ;;
pre-commit) cmd_pre_commit ;;
*) usage ;;
esac

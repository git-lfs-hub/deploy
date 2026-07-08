#!/usr/bin/env bash
store=node_modules/.bun
[[ -d $store ]] || exit 0
find "$store" -type d -name .git -exec rm -rf {} +

#!/usr/bin/env bash
store=node_modules/.bun
[[ -d $store ]] || exit 0
find "$store" -depth -name .git -exec rm -rf {} +

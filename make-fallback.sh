#!/usr/bin/env bash
# make-fallback.sh - capture the current demo result as a fallback branch.
#
# Commits whatever is in the working tree and labels that commit with a branch
# name, so you can `git checkout <name>` live if a demo stalls. You stay on your
# current branch (the label does not switch you).
#
# Usage:
#   ./make-fallback.sh demo-m3-1-done "demo 3.1 result: Asset API"
#   ./make-fallback.sh -f demo-m4-good "demo 4.1 result: report (good spec)"   # -f overwrites
#
# Chained demo (e.g. 3.3 builds on 3.1): check out the parent first, then run:
#   git checkout demo-m3-1-done && git checkout -B demo-m3-3-done
#   # run the demo
#   ./make-fallback.sh demo-m3-3-done "demo 3.3 result: tests"

set -euo pipefail

force=0
if [ "${1:-}" = "-f" ]; then force=1; shift; fi

name="${1:-}"; message="${2:-}"
if [ -z "$name" ] || [ -z "$message" ]; then
  echo "Usage: ./make-fallback.sh [-f] <branch-name> <commit-message>" >&2
  exit 1
fi

if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  echo "Not inside a git repository. Run this from the repo root." >&2
  exit 1
fi

if git show-ref --verify --quiet "refs/heads/$name" && [ "$force" -eq 0 ]; then
  echo "Branch '$name' already exists. Re-run with -f to move it, or pick another name." >&2
  exit 1
fi

if [ -z "$(git status --porcelain)" ]; then
  echo "Working tree is clean: nothing to capture. Generate the demo result first." >&2
  exit 1
fi

current="$(git rev-parse --abbrev-ref HEAD)"
echo "Capturing current result on branch '$current':"
git add -A
git commit -m "$message" >/dev/null

if [ "$force" -eq 1 ]; then git branch -f "$name"; else git branch "$name"; fi

echo
echo "Done."
echo "  Committed on : $current"
echo "  Fallback br. : $name"
echo "  Recover live : git checkout $name"

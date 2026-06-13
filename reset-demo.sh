#!/usr/bin/env bash
# reset-demo.sh - return the working tree to a clean demo baseline.
#
# main is the pristine skeleton; this recreates a throwaway live-demo branch
# from it, previews what will be deleted, pauses for confirmation, then removes
# generated files and build output. Tracked files (including the Maven wrapper)
# are never touched. The dependency cache in ~/.m2 is outside the repo and is
# never affected.
#
# Usage:  ./reset-demo.sh         (interactive: shows preview, asks before delete)
#         ./reset-demo.sh -y      (skip the prompt; delete without asking)

set -euo pipefail

skip_confirm=0
[ "${1:-}" = "-y" ] && skip_confirm=1

# Safety: must be inside a git work tree.
if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  echo "Not inside a git repository. Run this from the repo root." >&2
  exit 1
fi

echo "Switching to a fresh live-demo branch off main..."
git checkout main
git checkout -B live-demo

echo
echo "The following untracked files and build output would be removed:"
echo "------------------------------------------------------------------"
# Dry run: list what -xfd would delete. If nothing, git prints nothing.
preview="$(git clean -xfdn)"
if [ -z "$preview" ]; then
  echo "(nothing to clean; working tree is already pristine)"
  echo "------------------------------------------------------------------"
  echo "Ready on branch live-demo."
  exit 0
fi
echo "$preview"
echo "------------------------------------------------------------------"
echo "Tracked files (including mvnw and .mvn/) are NOT affected."
echo "The Maven cache in ~/.m2 is NOT affected."
echo

if [ "$skip_confirm" -eq 0 ]; then
  printf "Delete the files listed above? [y/N] "
  read -r answer
  case "$answer" in
    [yY]|[yY][eE][sS]) ;;
    *) echo "Aborted. Nothing was deleted."; exit 0 ;;
  esac
fi

git clean -xfd
echo
echo "Reset complete. Clean baseline on branch live-demo."

#!/usr/bin/env bash
# prep-demo-folders.sh - build the three Module 4 demo folders from this repo.
#
# Run from INSIDE the repo root. Creates three sibling folders, each a
# self-contained non-git copy with exactly the context that demo run should see:
#   ../portal-good     full repo: GOOD spec + conventions present     -> 4.1
#   ../portal-poor     specs removed, conventions present             -> 4.2
#   ../portal-noconv   specs removed, .github (conventions) removed   -> 4.3
#
# Why folders, not branches: the poor runs must not find the GOOD spec in the
# workspace (Copilot uses it if it can see it, defeating the demo). Removing the
# specs from those folders guarantees it. Each folder's .git is removed: plain
# folder, no branch to switch, nothing to clean mid-demo. Re-run to reset.
#
# Usage:  ./prep-demo-folders.sh          (prompts before overwrite)
#         ./prep-demo-folders.sh -f       (overwrite without asking)

set -euo pipefail

force=0
[ "${1:-}" = "-f" ] && force=1

if [ ! -f "./pom.xml" ] || [ ! -f "./.github/copilot-instructions.md" ]; then
  echo "Run this from the repo root (folder with pom.xml and .github/copilot-instructions.md)." >&2
  exit 1
fi

parent="$(cd .. && pwd)"
src="$(pwd)"

build() {
  local name="$1" strip_specs="$2" strip_github="$3"
  local dest="$parent/$name"
  if [ -d "$dest" ]; then
    if [ "$force" -eq 0 ]; then
      printf "%s already exists. Overwrite? [y/N] " "$name"
      read -r ans
      case "$ans" in [yY]|[yY][eE][sS]) ;; *) echo "  skipped $name"; return ;; esac
    fi
    rm -rf "$dest"
  fi
  echo "Building $name..."
  cp -r "$src" "$dest"
  rm -rf "$dest/.git" "$dest/target"
  # POOR files are prompt + answer key, never real specs: remove from every folder.
  find "$dest" -name "spec-*-POOR.md" -delete 2>/dev/null || true
  if [ "$strip_specs" -eq 1 ]; then
    rm -f "$dest"/docs/specs/*.md 2>/dev/null || true
    find "$dest" -name "spec-maintenance-report-POOR.md" -delete 2>/dev/null || true
  fi
  if [ "$strip_github" -eq 1 ]; then
    rm -rf "$dest/.github"
  fi
  echo "  done: $dest"
}

build portal-good   0 0
build portal-poor   1 0
build portal-noconv 1 1

echo
echo "Three demo folders ready next to the repo:"
echo "  portal-good     (GOOD spec + conventions)   -> demo 4.1"
echo "  portal-poor     (no specs, conventions)     -> demo 4.2"
echo "  portal-noconv   (no specs, no conventions)  -> demo 4.3"
echo
echo "Open each in its own editor window. To reset any folder, re-run this script."

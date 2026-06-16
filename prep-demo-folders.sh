#!/usr/bin/env bash
# prep-demo-folders.sh - build the three Module 4 demo folders from this repo.
#
# Run from INSIDE the repo root. Creates three sibling folders, each a
# self-contained non-git copy with exactly the context that demo run should see:
#   ../portal-good     full repo: GOOD spec + conventions present     -> 4.1  (port 8081)
#   ../portal-poor     specs removed, conventions present             -> 4.2  (port 8082)
#   ../portal-noconv   specs removed, .github (conventions) removed   -> 4.3  (port 8083)
#
# Why folders, not branches: the poor runs must not find the GOOD spec in the
# workspace (Copilot uses it if it can see it, defeating the demo). Removing the
# specs from those folders guarantees it. Each folder's .git is removed: plain
# folder, no branch to switch, nothing to clean mid-demo. Re-run to reset.
#
# Why a port per folder: each folder gets its own server.port baked into
# application.properties, so all three apps run at once and the three results
# (good, poor, noconv) sit side by side in three browser tabs instead of being
# compared from memory one window at a time. The pristine skeleton on main is
# left on the default 8080, so the empty "before" staging tab never collides.
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
  local name="$1" strip_specs="$2" strip_github="$3" port="$4"
  local dest="$parent/$name"
  if [ -d "$dest" ]; then
    if [ "$force" -eq 0 ]; then
      printf "%s already exists. Overwrite? [y/N] " "$name"
      read -r ans
      case "$ans" in [yY]|[yY][eE][sS]) ;; *) echo "  skipped $name"; return ;; esac
    fi
    rm -rf "$dest"
  fi
  echo "Building $name (port $port)..."
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
  # Dedicated port so all three runs can be served at once for side-by-side
  # comparison. Replace only the server.port line; preserve any other props.
  local props="$dest/src/main/resources/application.properties"
  mkdir -p "$(dirname "$props")"
  if [ -f "$props" ]; then
    grep -v '^[[:space:]]*server\.port=' "$props" > "$props.tmp" 2>/dev/null && mv "$props.tmp" "$props"
  fi
  {
    echo "# Dedicated port for this demo folder so all three Module 4 runs can be"
    echo "# served at once for side-by-side comparison (skeleton default is 8080)."
    echo "server.port=$port"
  } >> "$props"
  echo "  done: $dest  (http://localhost:$port)"
}

build portal-good   0 0 8081
build portal-poor   1 0 8082
build portal-noconv 1 1 8083

echo
echo "Three demo folders ready next to the repo:"
echo "  portal-good     (GOOD spec + conventions)   -> demo 4.1  http://localhost:8081"
echo "  portal-poor     (no specs, conventions)     -> demo 4.2  http://localhost:8082"
echo "  portal-noconv   (no specs, no conventions)  -> demo 4.3  http://localhost:8083"
echo
echo "Open each in its own editor window. Each runs on its own port, so you can"
echo "start all three and view the results side by side in three browser tabs."
echo "To reset any folder, re-run this script."

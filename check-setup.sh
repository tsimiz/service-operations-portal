#!/usr/bin/env bash
# check-setup.sh - verifies a machine is ready for the Day 2 labs.
# Run from the repository root:  ./check-setup.sh
# Prints OK / WARN / FIX per check and a one-line verdict at the end.
# Exit code 0 if no FIX-level problems, 1 otherwise.

set -u

GREEN=$'\033[32m'; YELLOW=$'\033[33m'; RED=$'\033[31m'; BOLD=$'\033[1m'; RESET=$'\033[0m'
fixes=0
warns=0

ok()   { printf "  ${GREEN}OK${RESET}   %s\n" "$1"; }
warn() { printf "  ${YELLOW}WARN${RESET} %s\n" "$1"; warns=$((warns+1)); }
fix()  { printf "  ${RED}FIX${RESET}  %s\n" "$1"; fixes=$((fixes+1)); }

have() { command -v "$1" >/dev/null 2>&1; }

printf "${BOLD}Service Operations Portal - setup check${RESET}\n\n"

# --- Java 25 ---
printf "Java\n"
if have java; then
  raw="$(java -version 2>&1 | head -n1)"
  # extract major version (handles "25" and "25.0.1" and old "1.8")
  ver="$(printf '%s' "$raw" | sed -nE 's/.*version "([0-9]+)([.\"]).*/\1/p')"
  if [ "${ver:-0}" = "1" ]; then
    ver="$(printf '%s' "$raw" | sed -nE 's/.*version "1\.([0-9]+).*/\1/p')"
  fi
  if [ "${ver:-0}" -ge 25 ] 2>/dev/null; then
    ok "java $ver detected ($raw)"
  elif [ "${ver:-0}" -ge 21 ] 2>/dev/null; then
    warn "java $ver detected; labs target Java 25. It may build, but install JDK 25 to match."
  else
    fix "java $ver detected; install JDK 25 (Microsoft Build of OpenJDK or Temurin)."
  fi
else
  fix "java not found; install JDK 25 (Microsoft Build of OpenJDK or Temurin)."
fi

# --- Maven or wrapper ---
printf "\nMaven\n"
if [ -f "./mvnw" ]; then
  ok "Maven wrapper (./mvnw) present; no separate Maven install needed."
elif have mvn; then
  mver="$(mvn -v 2>/dev/null | sed -nE 's/Apache Maven ([0-9.]+).*/\1/p' | head -n1)"
  ok "mvn $mver detected."
else
  fix "Neither ./mvnw nor mvn found; install Maven 3.9+ or use the repo's wrapper."
fi

# --- Git ---
printf "\nGit\n"
if have git; then
  ok "$(git --version)"
else
  fix "git not found; install Git."
fi

# --- VS Code ---
printf "\nVS Code\n"
if have code; then
  ok "VS Code CLI (code) detected."
  exts="$(code --list-extensions 2>/dev/null)"
  if printf '%s\n' "$exts" | grep -qi '^github.copilot$'; then
    ok "GitHub Copilot extension installed."
  else
    fix "GitHub Copilot extension not found; install 'GitHub Copilot' in VS Code."
  fi
  if printf '%s\n' "$exts" | grep -qi '^github.copilot-chat$'; then
    ok "GitHub Copilot Chat extension installed."
  else
    warn "GitHub Copilot Chat extension not found; install it for the chat and agent demos."
  fi
  if printf '%s\n' "$exts" | grep -qi '^vscjava.vscode-java-pack$'; then
    ok "Java Extension Pack installed."
  else
    warn "Java Extension Pack not found; install 'Extension Pack for Java' for the test runner."
  fi
else
  warn "VS Code CLI (code) not on PATH. If VS Code is installed, enable the 'code' command (Command Palette: Shell Command: Install 'code' command in PATH). Extensions not checked."
fi

# --- Build smoke test (optional, slow) ---
printf "\nBuild\n"
if [ "${1:-}" = "--build" ]; then
  if [ -f "./mvnw" ]; then BUILD="./mvnw -q verify"; elif have mvn; then BUILD="mvn -q verify"; else BUILD=""; fi
  if [ -n "$BUILD" ]; then
    printf "  running %s (first run downloads dependencies, please wait)...\n" "$BUILD"
    if $BUILD >/tmp/portal-build.log 2>&1; then
      ok "build is green."
    else
      fix "build failed; see /tmp/portal-build.log (run the build yourself to read the error)."
    fi
  else
    warn "no Maven available to run the build."
  fi
else
  warn "build not run. Re-run once with './check-setup.sh --build' to verify a green build (downloads dependencies)."
fi

# --- Verdict ---
printf "\n${BOLD}Verdict:${RESET} "
if [ "$fixes" -eq 0 ] && [ "$warns" -eq 0 ]; then
  printf "${GREEN}ready.${RESET}\n"; exit 0
elif [ "$fixes" -eq 0 ]; then
  printf "${YELLOW}ready, with %d warning(s) above.${RESET}\n" "$warns"; exit 0
else
  printf "${RED}%d item(s) need fixing above before the labs.${RESET}\n" "$fixes"; exit 1
fi

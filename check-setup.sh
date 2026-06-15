#!/usr/bin/env bash
# check-setup.sh - verifies a machine is ready for the Day 2 labs.
# Run from the repository root:  ./check-setup.sh
# Add --build to also run a green-build smoke test (downloads dependencies).
# Prints OK / WARN / FIX per check and a one-line verdict.
# Exit 0 if no FIX-level problems, 1 otherwise.

set -u

GREEN=$'\033[32m'; YELLOW=$'\033[33m'; RED=$'\033[31m'; BOLD=$'\033[1m'; RESET=$'\033[0m'
fixes=0; warns=0

ok()   { printf "  ${GREEN}OK${RESET}   %s\n" "$1"; }
warn() { printf "  ${YELLOW}WARN${RESET} %s\n" "$1"; warns=$((warns+1)); }
fix()  { printf "  ${RED}FIX${RESET}  %s\n" "$1"; fixes=$((fixes+1)); }
have() { command -v "$1" >/dev/null 2>&1; }
sdkman_tip(){ [ -f ".sdkmanrc" ] && printf "       Tip: this repo has .sdkmanrc; with SDKMAN run 'sdk env install' to get JDK 25 (your default Java stays untouched).\n"; }

printf "${BOLD}Service Operations Portal - setup check${RESET}\n\n"

# --- Java 25 ---
printf "Java\n"
if have java; then
  raw="$(java -version 2>&1 | head -n1)"
  ver="$(printf '%s' "$raw" | sed -nE 's/.*version "([0-9]+)([."]).*/\1/p')"
  [ "${ver:-0}" = "1" ] && ver="$(printf '%s' "$raw" | sed -nE 's/.*version "1\.([0-9]+).*/\1/p')"
  if   [ "${ver:-0}" -ge 25 ] 2>/dev/null; then ok "java $ver detected ($raw)"
  elif [ "${ver:-0}" -ge 21 ] 2>/dev/null; then warn "java $ver detected; labs target Java 25. It may build, but install JDK 25 to match."; sdkman_tip
  else fix "java $ver detected; install JDK 25 (Microsoft Build of OpenJDK or Temurin)."; sdkman_tip; fi
else
  # Java may be installed but not on PATH. Look in common locations before failing.
  found=""
  for base in /usr/lib/jvm /Library/Java/JavaVirtualMachines "$HOME/.sdkman/candidates/java" /opt/java; do
    [ -d "$base" ] || continue
    cand="$(ls -d "$base"/*25*/ "$base"/*25*/Contents/Home/ 2>/dev/null | head -n1)"
    [ -n "$cand" ] && [ -x "${cand}bin/java" ] && { found="$cand"; break; }
  done
  if [ -n "$found" ]; then
    fix "java not on PATH, but a JDK 25 looks present at: ${found}"
    printf "       Set it for this shell, then re-run:\n"
    printf "         export JAVA_HOME=\"%s\"\n" "${found%/}"
    printf "         export PATH=\"\$JAVA_HOME/bin:\$PATH\"\n"
  else
    fix "java not found; install JDK 25 (Microsoft Build of OpenJDK or Temurin), then ensure it is on PATH."; sdkman_tip
  fi
fi

# --- Maven or wrapper ---
printf "\nMaven\n"
if [ -f "./mvnw" ]; then ok "Maven wrapper (./mvnw) present; no separate Maven install needed."
elif have mvn; then ok "mvn $(mvn -v 2>/dev/null | sed -nE 's/Apache Maven ([0-9.]+).*/\1/p' | head -n1) detected."
else fix "Neither ./mvnw nor mvn found; install Maven 3.9+ or use the repo's wrapper once it is committed."; fi

# --- Git ---
printf "\nGit\n"
if have git; then ok "$(git --version)"; else fix "git not found; install Git."; fi

# --- VS Code + Copilot ---
# Note: extension ids and bundling change between VS Code versions. Copilot Chat is
# now often a built-in and may not appear in --list-extensions, and github.copilot
# can resolve to chat behaviour. So we treat Copilot as WARN-with-manual-verify, never
# a hard FIX, to avoid a confident false negative.
printf "\nVS Code\n"
if have code; then
  ok "VS Code CLI (code) detected."
  exts="$(code --list-extensions 2>/dev/null || true)"
  # Newer VS Code builds ship Copilot Chat as built-in, which may not appear in --list-extensions.
  cp_path="$(code --locate-extension github.copilot 2>/dev/null | head -n1 || true)"
  cpchat_path="$(code --locate-extension github.copilot-chat 2>/dev/null | head -n1 || true)"
  has_cp=0; printf '%s\n' "$exts" | grep -qi '^github\.copilot$' && has_cp=1; [ -n "$cp_path" ] && has_cp=1
  has_cpchat=0; printf '%s\n' "$exts" | grep -qi '^github\.copilot-chat$' && has_cpchat=1; [ -n "$cpchat_path" ] && has_cpchat=1
  if [ "$has_cp" -eq 1 ] || [ "$has_cpchat" -eq 1 ]; then
    ok "GitHub Copilot available."
  else
    warn "Copilot not seen via --list-extensions or --locate-extension. It may be a built-in this version. Verify in VS Code: Extensions panel shows GitHub Copilot, and the Chat view opens."
  fi
  if printf '%s\n' "$exts" | grep -qi '^vscjava\.vscode-java-pack$'; then
    ok "Java Extension Pack installed."
  else
    warn "Java Extension Pack not seen; install 'Extension Pack for Java' for the in-IDE test runner."
  fi
else
  warn "VS Code CLI (code) not on PATH. If VS Code is installed, run the Command Palette action 'Shell Command: Install code command in PATH'. Extensions not checked."
fi

# --- Build smoke test (optional) ---
printf "\nBuild\n"
if [ "${1:-}" = "--build" ]; then
  if [ -f "./mvnw" ]; then BUILD="./mvnw -q verify"; elif have mvn; then BUILD="mvn -q verify"; else BUILD=""; fi
  if [ -n "$BUILD" ]; then
    printf "  running %s (first run downloads dependencies, please wait)...\n" "$BUILD"
    if $BUILD >/tmp/portal-build.log 2>&1; then ok "build is green."
    else fix "build failed; see /tmp/portal-build.log."; fi
  else warn "no Maven available to run the build."; fi
else
  warn "build not run. Re-run once with './check-setup.sh --build' to verify a green build (downloads dependencies)."
fi

# --- Verdict ---
printf "\n${BOLD}Verdict:${RESET} "
if   [ "$fixes" -eq 0 ] && [ "$warns" -eq 0 ]; then printf "${GREEN}ready.${RESET}\n"; exit 0
elif [ "$fixes" -eq 0 ]; then printf "${YELLOW}ready, with %d warning(s) above.${RESET}\n" "$warns"; exit 0
else printf "${RED}%d item(s) need fixing above before the labs.${RESET}\n" "$fixes"; exit 1; fi

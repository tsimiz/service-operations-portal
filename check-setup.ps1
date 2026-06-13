<#
  check-setup.ps1 - verifies a machine is ready for the Day 2 labs.
  Run from the repository root:  .\check-setup.ps1
  Add -Build to also run a green-build smoke test (downloads dependencies):
                                 .\check-setup.ps1 -Build
  Prints OK / WARN / FIX per check and a one-line verdict.
#>

param([switch]$Build)

$script:fixes = 0
$script:warns = 0

function Ok($m)   { Write-Host "  OK   " -ForegroundColor Green -NoNewline; Write-Host $m }
function Warn($m) { Write-Host "  WARN " -ForegroundColor Yellow -NoNewline; Write-Host $m; $script:warns++ }
function Fix($m)  { Write-Host "  FIX  " -ForegroundColor Red -NoNewline; Write-Host $m; $script:fixes++ }
function Have($c) { return [bool](Get-Command $c -ErrorAction SilentlyContinue) }

Write-Host "Service Operations Portal - setup check" -ForegroundColor White
Write-Host ""

# --- Java 25 ---
Write-Host "Java"
if (Have java) {
  $raw = (& java -version 2>&1 | Select-Object -First 1).ToString()
  $ver = 0
  if ($raw -match 'version "(\d+)') {
    $ver = [int]$Matches[1]
    if ($ver -eq 1 -and $raw -match 'version "1\.(\d+)') { $ver = [int]$Matches[1] }
  }
  if ($ver -ge 25)     { Ok "java $ver detected ($raw)" }
  elseif ($ver -ge 21) { Warn "java $ver detected; labs target Java 25. It may build, but install JDK 25 to match." }
  else                 { Fix "java $ver detected; install JDK 25 (Microsoft Build of OpenJDK or Temurin)." }
} else {
  Fix "java not found; install JDK 25 (Microsoft Build of OpenJDK or Temurin)."
}

# --- Maven or wrapper ---
Write-Host "`nMaven"
if (Test-Path ".\mvnw.cmd") {
  Ok "Maven wrapper (.\mvnw.cmd) present; no separate Maven install needed."
} elseif (Have mvn) {
  $mver = ((& mvn -v 2>$null | Select-String 'Apache Maven ([0-9.]+)').Matches.Groups[1].Value)
  Ok "mvn $mver detected."
} else {
  Fix "Neither .\mvnw.cmd nor mvn found; install Maven 3.9+ or use the repo's wrapper."
}

# --- Git ---
Write-Host "`nGit"
if (Have git) { Ok ((& git --version)) } else { Fix "git not found; install Git." }

# --- VS Code ---
Write-Host "`nVS Code"
if (Have code) {
  Ok "VS Code CLI (code) detected."
  $exts = (& code --list-extensions 2>$null)
  if ($exts -match '^github\.copilot$')       { Ok "GitHub Copilot extension installed." }      else { Fix "GitHub Copilot extension not found; install 'GitHub Copilot' in VS Code." }
  if ($exts -match '^github\.copilot-chat$')   { Ok "GitHub Copilot Chat extension installed." } else { Warn "GitHub Copilot Chat extension not found; install it for the chat and agent demos." }
  if ($exts -match '^vscjava\.vscode-java-pack$') { Ok "Java Extension Pack installed." }        else { Warn "Java Extension Pack not found; install 'Extension Pack for Java' for the test runner." }
} else {
  Warn "VS Code CLI (code) not on PATH. If VS Code is installed, enable the 'code' command (Command Palette: Shell Command: Install 'code' command in PATH). Extensions not checked."
}

# --- Build smoke test (optional, slow) ---
Write-Host "`nBuild"
if ($Build) {
  $cmd = $null
  if (Test-Path ".\mvnw.cmd") { $cmd = ".\mvnw.cmd -q verify" }
  elseif (Have mvn)           { $cmd = "mvn -q verify" }
  if ($cmd) {
    Write-Host "  running $cmd (first run downloads dependencies, please wait)..."
    cmd /c "$cmd > $env:TEMP\portal-build.log 2>&1"
    if ($LASTEXITCODE -eq 0) { Ok "build is green." }
    else { Fix "build failed; see $env:TEMP\portal-build.log (run the build yourself to read the error)." }
  } else {
    Warn "no Maven available to run the build."
  }
} else {
  Warn "build not run. Re-run once with '.\check-setup.ps1 -Build' to verify a green build (downloads dependencies)."
}

# --- Verdict ---
Write-Host ""
Write-Host "Verdict: " -ForegroundColor White -NoNewline
if ($script:fixes -eq 0 -and $script:warns -eq 0) {
  Write-Host "ready." -ForegroundColor Green; exit 0
} elseif ($script:fixes -eq 0) {
  Write-Host "ready, with $($script:warns) warning(s) above." -ForegroundColor Yellow; exit 0
} else {
  Write-Host "$($script:fixes) item(s) need fixing above before the labs." -ForegroundColor Red; exit 1
}

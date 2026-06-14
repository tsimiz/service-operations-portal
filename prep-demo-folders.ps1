<#
  prep-demo-folders.ps1 - build the three Module 4 demo folders from this repo.

  Run from INSIDE the repo root (service-operations-portal). Creates three
  sibling folders next to the repo, each a self-contained, non-git copy with
  exactly the context that demo run should see:

    ..\portal-good     full repo: GOOD spec present, conventions present   (port 8081)
    ..\portal-poor     specs removed, conventions present                  (port 8082)
    ..\portal-noconv   specs removed, .github (conventions) removed         (port 8083)

  Why folders, not branches: the poor runs must not be able to find the GOOD
  spec in the workspace (Copilot will use it if it can see it, which defeats the
  demo). Physically removing the specs from those folders guarantees it.

  Why a port per folder: each folder gets its own server.port in
  application.properties, so all three apps run at once and the results (good,
  poor, noconv) sit side by side in three browser tabs instead of being compared
  from memory one window at a time. The pristine skeleton on main stays on the
  default 8080, so the empty "before" staging tab never collides.

  Each folder has its .git removed, so it is a plain folder: no branch to switch,
  no history, nothing to commit or clean during the demo. To reset a folder,
  just re-run this script.

  Usage:
    .\prep-demo-folders.ps1            (rebuilds all three; prompts before overwrite)
    .\prep-demo-folders.ps1 -Force     (overwrite existing folders without asking)

  If a strict execution policy blocks this:
    powershell -ExecutionPolicy Bypass -File .\prep-demo-folders.ps1
#>

param([switch]$Force)

$ErrorActionPreference = 'Stop'

# Must be at the repo root (look for a marker file).
if (-not (Test-Path ".\pom.xml") -or -not (Test-Path ".\.github\copilot-instructions.md")) {
  Write-Error "Run this from the repo root (the folder containing pom.xml and .github\copilot-instructions.md)."
  exit 1
}

$repoName = Split-Path -Leaf (Get-Location)
$parent   = Split-Path -Parent (Get-Location)

$targets = @(
  @{ Name = "portal-good";   StripSpecs = $false; StripGithub = $false; Port = 8081 },
  @{ Name = "portal-poor";   StripSpecs = $true;  StripGithub = $false; Port = 8082 },
  @{ Name = "portal-noconv"; StripSpecs = $true;  StripGithub = $true;  Port = 8083 }
)

foreach ($t in $targets) {
  $dest = Join-Path $parent $t.Name

  if (Test-Path $dest) {
    if (-not $Force) {
      $ans = Read-Host "$($t.Name) already exists. Overwrite? [y/N]"
      if ($ans -notmatch '^(y|yes)$') { Write-Host "  skipped $($t.Name)"; continue }
    }
    Remove-Item -Recurse -Force $dest
  }

  Write-Host "Building $($t.Name) (port $($t.Port))..."
  # Copy the repo, excluding target\ and .git is handled after copy.
  Copy-Item -Recurse -Path (Get-Location).Path -Destination $dest

  # Sever git: plain folder, no branches/history.
  $gitDir = Join-Path $dest ".git"
  if (Test-Path $gitDir) { Remove-Item -Recurse -Force $gitDir }

  # Remove build output if it was copied.
  $targetDir = Join-Path $dest "target"
  if (Test-Path $targetDir) { Remove-Item -Recurse -Force $targetDir }

  # The POOR file is prompt + answer key, never a real spec: remove from every folder.
  Get-ChildItem -Path $dest -Recurse -Filter "spec-*-POOR.md" -ErrorAction SilentlyContinue | Remove-Item -Force

  # Strip specs so the poor/noconv runs cannot find the GOOD spec.
  if ($t.StripSpecs) {
    $specsDir = Join-Path $dest "docs\specs"
    if (Test-Path $specsDir) {
      Get-ChildItem -Path $specsDir -Filter *.md | Remove-Item -Force
    }
    # Also drop the poor "spec" file anywhere it might sit (it is prompt+answer key).
    Get-ChildItem -Path $dest -Recurse -Filter "spec-maintenance-report-POOR.md" -ErrorAction SilentlyContinue | Remove-Item -Force
  }

  # Strip conventions for the no-conventions run.
  if ($t.StripGithub) {
    $ghDir = Join-Path $dest ".github"
    if (Test-Path $ghDir) { Remove-Item -Recurse -Force $ghDir }
  }

  # Dedicated port so all three runs can be served at once for side-by-side
  # comparison. Replace only the server.port line; preserve any other props.
  $resDir = Join-Path $dest "src\main\resources"
  if (-not (Test-Path $resDir)) { New-Item -ItemType Directory -Path $resDir | Out-Null }
  $props = Join-Path $resDir "application.properties"
  if (Test-Path $props) {
    $kept = Get-Content $props | Where-Object { $_ -notmatch '^\s*server\.port=' }
    Set-Content -Path $props -Value $kept
  }
  Add-Content -Path $props -Value "# Dedicated port for this demo folder so all three Module 4 runs can be"
  Add-Content -Path $props -Value "# served at once for side-by-side comparison (skeleton default is 8080)."
  Add-Content -Path $props -Value "server.port=$($t.Port)"

  Write-Host "  done: $dest  (http://localhost:$($t.Port))"
}

Write-Host ""
Write-Host "Three demo folders ready next to the repo:" -ForegroundColor Green
Write-Host "  portal-good     (GOOD spec + conventions)      -> demo 4.1  http://localhost:8081"
Write-Host "  portal-poor     (no specs, conventions)        -> demo 4.2  http://localhost:8082"
Write-Host "  portal-noconv   (no specs, no conventions)     -> demo 4.3  http://localhost:8083"
Write-Host ""
Write-Host "Open each in its own VS Code window with:  code <folder>"
Write-Host "Each runs on its own port, so you can start all three and view the"
Write-Host "results side by side in three browser tabs."
Write-Host "To reset any folder, re-run this script."

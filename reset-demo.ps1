<#
  reset-demo.ps1 - return the working tree to a clean demo baseline.

  main is the pristine skeleton; this recreates a throwaway live-demo branch
  from it, previews what will be deleted, pauses for confirmation, then removes
  generated files and build output. Tracked files (including the Maven wrapper)
  are never touched. The dependency cache in ~/.m2 is outside the repo and is
  never affected.

  Usage:  .\reset-demo.ps1          (interactive: shows preview, asks before delete)
          .\reset-demo.ps1 -Yes     (skip the prompt; delete without asking)

  If a strict execution policy blocks this, run it unblocked for one session:
    powershell -ExecutionPolicy Bypass -File .\reset-demo.ps1
#>

param([switch]$Yes)

$ErrorActionPreference = 'Stop'

# Safety: must be inside a git work tree.
git rev-parse --is-inside-work-tree *> $null
if ($LASTEXITCODE -ne 0) {
  Write-Error "Not inside a git repository. Run this from the repo root."
  exit 1
}

Write-Host "Switching to a fresh live-demo branch off main..."
git checkout main
git checkout -B live-demo

Write-Host ""
Write-Host "The following untracked files and build output would be removed:"
Write-Host "------------------------------------------------------------------"
# Dry run: list what -xfd would delete.
$preview = (git clean -xfdn)
if (-not $preview) {
  Write-Host "(nothing to clean; working tree is already pristine)"
  Write-Host "------------------------------------------------------------------"
  Write-Host "Ready on branch live-demo."
  exit 0
}
$preview | ForEach-Object { Write-Host $_ }
Write-Host "------------------------------------------------------------------"
Write-Host "Tracked files (including mvnw and .mvn/) are NOT affected."
Write-Host "The Maven cache in ~/.m2 is NOT affected."
Write-Host ""

if (-not $Yes) {
  $answer = Read-Host "Delete the files listed above? [y/N]"
  if ($answer -notmatch '^(y|yes)$') {
    Write-Host "Aborted. Nothing was deleted."
    exit 0
  }
}

git clean -xfd
Write-Host ""
Write-Host "Reset complete. Clean baseline on branch live-demo."

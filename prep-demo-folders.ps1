<#
  prep-demo-folders.ps1 - build the three Module 4 demo folders from this repo.

  Run from INSIDE the repo root (service-operations-portal). Creates three
  sibling folders next to the repo, each a self-contained, non-git copy with
  exactly the context that demo run should see:

    ..\portal-good     full repo: GOOD spec present, conventions present
    ..\portal-poor     specs removed, conventions present
    ..\portal-noconv   specs removed, .github (conventions) removed

  Why folders, not branches: the poor runs must not be able to find the GOOD
  spec in the workspace (Copilot will use it if it can see it, which defeats the
  demo). Physically removing the specs from those folders guarantees it.

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
  @{ Name = "portal-good";   StripSpecs = $false; StripGithub = $false },
  @{ Name = "portal-poor";   StripSpecs = $true;  StripGithub = $false },
  @{ Name = "portal-noconv"; StripSpecs = $true;  StripGithub = $true  }
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

  Write-Host "Building $($t.Name)..."
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

  Write-Host "  done: $dest"
}

Write-Host ""
Write-Host "Three demo folders ready next to the repo:" -ForegroundColor Green
Write-Host "  portal-good     (GOOD spec + conventions)      -> demo 4.1"
Write-Host "  portal-poor     (no specs, conventions)        -> demo 4.2"
Write-Host "  portal-noconv   (no specs, no conventions)     -> demo 4.3"
Write-Host ""
Write-Host "Open each in its own VS Code window with:  code <folder>"
Write-Host "To reset any folder, re-run this script."

<#
  make-fallback.ps1 - capture the current demo result as a fallback branch.

  Commits whatever is in the working tree and labels that commit with a branch
  name, so you can `git checkout <name>` live if a demo stalls. You stay on your
  current branch (the label does not switch you).

  Usage:
    .\make-fallback.ps1 -Name demo-m3-1-done -Message "demo 3.1 result: Asset API"
    .\make-fallback.ps1 demo-m4-good "demo 4.1 result: maintenance report (good spec)"

  For a CHAINED demo (e.g. 3.3 builds on 3.1), check out the parent first, then
  run this:
    git checkout demo-m3-1-done
    git checkout -B demo-m3-3-done
    # run the demo
    .\make-fallback.ps1 -Name demo-m3-3-done -Message "demo 3.3 result: tests"

  If a strict execution policy blocks this:
    powershell -ExecutionPolicy Bypass -File .\make-fallback.ps1 -Name ... -Message ...
#>

param(
  [Parameter(Mandatory = $true, Position = 0)][string]$Name,
  [Parameter(Mandatory = $true, Position = 1)][string]$Message,
  [switch]$Force   # overwrite an existing branch of the same name
)

$ErrorActionPreference = 'Stop'

# Must be inside a git work tree.
git rev-parse --is-inside-work-tree *> $null
if ($LASTEXITCODE -ne 0) {
  Write-Error "Not inside a git repository. Run this from the repo root."
  exit 1
}

# Refuse to clobber an existing branch unless -Force.
git show-ref --verify --quiet "refs/heads/$Name"
if ($LASTEXITCODE -eq 0 -and -not $Force) {
  Write-Host "Branch '$Name' already exists." -ForegroundColor Yellow
  Write-Host "Re-run with -Force to move it to the current result, or pick another name."
  exit 1
}

# Is there anything to commit?
$status = (git status --porcelain)
if (-not $status) {
  Write-Host "Working tree is clean: nothing to capture." -ForegroundColor Yellow
  Write-Host "Generate the demo result first, then run this."
  exit 1
}

$current = (git rev-parse --abbrev-ref HEAD)

Write-Host "Capturing current result on branch '$current':"
git add -A
git commit -m $Message | Out-Null

if ($Force) {
  git branch -f $Name
} else {
  git branch $Name
}

Write-Host ""
Write-Host "Done." -ForegroundColor Green
Write-Host "  Committed on : $current"
Write-Host "  Fallback br. : $Name"
Write-Host "  Recover live : git checkout $Name"

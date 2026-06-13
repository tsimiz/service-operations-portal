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

# SIG # Begin signature block
# MIIFvAYJKoZIhvcNAQcCoIIFrTCCBakCAQExDzANBglghkgBZQMEAgEFADB5Bgor
# BgEEAYI3AgEEoGswaTA0BgorBgEEAYI3AgEeMCYCAwEAAAQQH8w7YFlLCE63JNLG
# KX7zUQIBAAIBAAIBAAIBAAIBADAxMA0GCWCGSAFlAwQCAQUABCAAijumAVgBsYBP
# r5KGJ9Mb0MYscLFbbUdLJk2Eb/2nsaCCAyQwggMgMIICCKADAgECAhAcNvaf0Mhf
# oU/1mdju2UeKMA0GCSqGSIb3DQEBCwUAMCgxJjAkBgNVBAMMHUxvY2FsIFBvd2Vy
# U2hlbGwgQ29kZSBTaWduaW5nMB4XDTI2MDYxMzA4MzAzMVoXDTI5MDYxMzA4NDAz
# MVowKDEmMCQGA1UEAwwdTG9jYWwgUG93ZXJTaGVsbCBDb2RlIFNpZ25pbmcwggEi
# MA0GCSqGSIb3DQEBAQUAA4IBDwAwggEKAoIBAQC7UQpuOtOO222DInzuUM4lVnbO
# U3DAMcILQI56O3ZZe+G1R/T949q2wOAR6yzChIb52vVCOGS9wKrLnxM3WqyDuBYP
# /Nh8or/K9CmvbxtcFaGD2ev5j1A2RfZaMFNqLMdyzEzfTBFkGVChiAniTrQHCq32
# +0aivRkor9K36vgmMQmU1czkOgb5Qu+4TBXffSWSLq7PdGDhBVkUWBErGzWkj9Pb
# xphns48br+4dWtoZa1QCnAXqWy31AB+EeqUAlipf2rwUucnw8wDB3l398qiVK6m+
# W/eIMGG1bhi7Auevl49nrPjhEjn9FooaVbrXP2FQQEX46jV+tAuwebQTk9SJAgMB
# AAGjRjBEMA4GA1UdDwEB/wQEAwIHgDATBgNVHSUEDDAKBggrBgEFBQcDAzAdBgNV
# HQ4EFgQUrA8Y0GYIjKeyDFMLssu7a5qLzs0wDQYJKoZIhvcNAQELBQADggEBAAdd
# OJmfwXbpyzb22vel/UZ/I6Nh4QakN5KOUl1I/QrIp8lwHALWxGxQrkQYyGXEu1OT
# 6lIiOHxd8DqzBC4Rx1ZgEmg3h9bgABqkwBUkJuFhEWN8uZ5FM33LnP/bQLeCEoNd
# JXeAvCwHCWD06P1YEf1ek+GVZhqPpBWMGPdVZRLxUjorCA2wBY9lFt1K6FHmDUnN
# tvGOChdhU0Ly0hVg93Rqn/7WBnuD/TJWo6NPxq8VuVeGbNzIxlnxVJgofTkKyhEv
# Iu7fwVlbE+P1wKf4y/pHv34wbZkmzvJL66O6TIKX7Nl9RBhXDz/dASCpImBOjA72
# REF3AGz4JI2hsUY5dS0xggHuMIIB6gIBATA8MCgxJjAkBgNVBAMMHUxvY2FsIFBv
# d2VyU2hlbGwgQ29kZSBTaWduaW5nAhAcNvaf0MhfoU/1mdju2UeKMA0GCWCGSAFl
# AwQCAQUAoIGEMBgGCisGAQQBgjcCAQwxCjAIoAKAAKECgAAwGQYJKoZIhvcNAQkD
# MQwGCisGAQQBgjcCAQQwHAYKKwYBBAGCNwIBCzEOMAwGCisGAQQBgjcCARUwLwYJ
# KoZIhvcNAQkEMSIEILHVP6yCHoge9qsWTKYfA9cpY1aT/7grNiMVE1LrOvcGMA0G
# CSqGSIb3DQEBAQUABIIBAHWemCRJuJkw248OkEZ5GdNxs7cKfQKh2legg+s6Zf/s
# rFkQbbTtQDiBdBS70KfHB9HqLT5a53Kj6uyNZpiV7TOYljECzcO0kU96oU3/NBcY
# wMcvAIr/LYbgpYGdITCiLTwEC2GwPaS4bU+oSd0AV0NzS5vm9n8I6VgeM20/T7qr
# MALAfED0bdYKia+FOYFvxB54kS2BvecJTs/GD2HazQ9J/k+nX/v4LMkx2iAQg2Mj
# pe7u5/KEtVFip5dqTKNSyTYKdS4HoAtXacGxaH6iSZFEOS3Dvu9kcrnDlc+Frz5b
# a2CYVSa81DUnjYaLg7BoaOJWHUkV+rRYtxJdq383B8w=
# SIG # End signature block

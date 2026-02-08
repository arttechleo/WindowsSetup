#Requires -Version 5.1
<#
.SYNOPSIS
  Installs the pre-commit hook that scans for forbidden patterns before each commit.
.DESCRIPTION
  Copies docs\pre-commit to .git\hooks\pre-commit and makes it executable (on Git Bash).
  Run once per clone.
.EXAMPLE
  .\docs\install-pre-commit.ps1
.NOTES
  The hook runs docs\pre-commit-scan.ps1. To run the scan manually: .\docs\pre-commit-scan.ps1
#>

$ErrorActionPreference = 'Stop'
$RepoRoot = Split-Path -Parent (Split-Path -Parent $PSCommandPath)
$HookSrc = Join-Path $RepoRoot 'docs' 'pre-commit'
$HookDst = Join-Path $RepoRoot '.git' 'hooks' 'pre-commit'

if (-not (Test-Path (Join-Path $RepoRoot '.git'))) {
    Write-Error "Not a git repo: $RepoRoot"
    exit 1
}

Copy-Item -LiteralPath $HookSrc -Destination $HookDst -Force
Write-Host "Installed pre-commit hook at $HookDst"
Write-Host "Run the scan manually anytime: .\docs\pre-commit-scan.ps1"

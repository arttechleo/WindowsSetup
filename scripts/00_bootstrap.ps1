#Requires -Version 5.1
<#
.SYNOPSIS
  Bootstrap: admin check, winget presence, and log folder under local/logs.
.DESCRIPTION
  Idempotent. Run as Administrator. Creates local\logs if missing.
  Does not modify system beyond ensuring log directory exists.
.EXAMPLE
  .\00_bootstrap.ps1
.NOTES
  Logs to local\logs\bootstrap_YYYYMMDD-HHmmss.log (relative to repo root).
#>

$ErrorActionPreference = 'Stop'
$RepoRoot = Split-Path -Parent (Split-Path -Parent $PSCommandPath)
$LogDir  = Join-Path $RepoRoot 'local' 'logs'
$LogFile = Join-Path $LogDir "bootstrap_$(Get-Date -Format 'yyyyMMdd-HHmmss').log"

function Write-Log { param([string]$Message) $m = "[$(Get-Date -Format 'o')] $Message"; Write-Host $m; Add-Content -LiteralPath $LogFile -Value $m -ErrorAction SilentlyContinue }

# Admin check
$isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $isAdmin) {
    Write-Log "ERROR: This script must be run as Administrator."
    exit 1
}

# Ensure local\logs exists
if (-not (Test-Path $LogDir)) {
    New-Item -ItemType Directory -Path $LogDir -Force | Out-Null
    Write-Log "Created log directory: $LogDir"
} else {
    Write-Log "Log directory exists: $LogDir"
}

# Winget presence
$wingetPath = Get-Command winget -ErrorAction SilentlyContinue
if (-not $wingetPath) {
    Write-Log "WARNING: winget not found. Install App Installer / enable Windows Package Manager."
} else {
    Write-Log "winget found: $($wingetPath.Source)"
}

Write-Log "Bootstrap completed successfully."

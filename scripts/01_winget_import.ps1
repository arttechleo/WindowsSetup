#Requires -Version 5.1
<#
.SYNOPSIS
  Idempotent winget import from local/winget-apps.json if present; otherwise prints export instructions.
.DESCRIPTION
  Imports apps from local\winget-apps.json when the file exists. Safe to re-run.
  Logs to local\logs\.
.EXAMPLE
  .\01_winget_import.ps1
.NOTES
  Do not commit local\winget-apps.json (gitignored). Use config\templates\winget-export.example.txt for the export command.
#>

$ErrorActionPreference = 'Stop'
$RepoRoot = Split-Path -Parent (Split-Path -Parent $PSCommandPath)
$WingetJson = Join-Path $RepoRoot 'local' 'winget-apps.json'
$LogDir     = Join-Path $RepoRoot 'local' 'logs'
$LogFile    = Join-Path $LogDir "winget_import_$(Get-Date -Format 'yyyyMMdd-HHmmss').log"

function Write-Log { param([string]$Message) $m = "[$(Get-Date -Format 'o')] $Message"; Write-Host $m; if (Test-Path $LogDir) { Add-Content -LiteralPath $LogFile -Value $m -ErrorAction SilentlyContinue } }

if (-not (Test-Path $LogDir)) { New-Item -ItemType Directory -Path $LogDir -Force | Out-Null }

if (-not (Test-Path $WingetJson)) {
    Write-Log "File not found: $WingetJson"
    Write-Log "Export instructions:"
    Write-Log "  1. On a reference machine run: winget export -o local\winget-apps.json"
    Write-Log "  2. Copy local\winget-apps.json into this repo's local\ folder (do not commit it)."
    Write-Log "  3. Re-run this script."
    Write-Log "See config\templates\winget-export.example.txt for the command."
    exit 0
}

$winget = Get-Command winget -ErrorAction SilentlyContinue
if (-not $winget) {
    Write-Log "ERROR: winget not found. Run 00_bootstrap.ps1 first."
    exit 1
}

Write-Log "Importing from $WingetJson ..."
try {
    & winget import --import-file $WingetJson --accept-package-agreements --accept-source-agreements 2>&1 | ForEach-Object { Write-Log $_ }
    Write-Log "Winget import completed."
} catch {
    Write-Log "ERROR: $($_.Exception.Message)"
    exit 1
}

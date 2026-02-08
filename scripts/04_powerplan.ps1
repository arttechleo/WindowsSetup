#Requires -Version 5.1
<#
.SYNOPSIS
  Imports power plan from local/powerplan.pow if present; otherwise prints export instructions.
.DESCRIPTION
  Idempotent. Requires elevation. Logs to local\logs\.
.EXAMPLE
  .\04_powerplan.ps1
.NOTES
  Do not commit local\powerplan.pow. See config\templates\powercfg-export.example.txt for export command.
#>

$ErrorActionPreference = 'Stop'
$RepoRoot    = Split-Path -Parent (Split-Path -Parent $PSCommandPath)
$PowerPlanFile = Join-Path $RepoRoot 'local' 'powerplan.pow'
$LogDir      = Join-Path $RepoRoot 'local' 'logs'
$LogFile     = Join-Path $LogDir "powerplan_$(Get-Date -Format 'yyyyMMdd-HHmmss').log"

function Write-Log { param([string]$Message) $m = "[$(Get-Date -Format 'o')] $Message"; Write-Host $m; if (Test-Path $LogDir) { Add-Content -LiteralPath $LogFile -Value $m -ErrorAction SilentlyContinue } }

if (-not (Test-Path $LogDir)) { New-Item -ItemType Directory -Path $LogDir -Force | Out-Null }

$isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $isAdmin) {
    Write-Log "ERROR: This script must be run as Administrator to import a power plan."
    exit 1
}

if (-not (Test-Path $PowerPlanFile)) {
    Write-Log "File not found: $PowerPlanFile"
    Write-Log "Export instructions:"
    Write-Log "  1. On a reference machine run: powercfg -export ""local\powerplan.pow"" <GUID>"
    Write-Log "     To get current plan GUID: powercfg -getactivescheme"
    Write-Log "  2. Copy local\powerplan.pow into this repo's local\ folder (do not commit it)."
    Write-Log "  3. Re-run this script."
    Write-Log "See config\templates\powercfg-export.example.txt for the commands."
    exit 0
}

try {
    Write-Log "Importing power plan from $PowerPlanFile"
    & powercfg -import $PowerPlanFile 2>&1 | ForEach-Object { Write-Log $_ }
    Write-Log "Power plan import completed."
} catch {
    Write-Log "ERROR: $($_.Exception.Message)"
    exit 1
}

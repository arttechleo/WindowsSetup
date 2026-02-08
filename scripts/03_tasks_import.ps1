#Requires -Version 5.1
<#
.SYNOPSIS
  Imports sanitized scheduled task templates from config/tasks. Idempotent; logs actions.
.DESCRIPTION
  Reads .xml and .template.xml files from config\tasks\ and imports them via schtasks.
  Skips non-XML files. Safe to re-run (schtasks /Change can update; or delete then import).
.EXAMPLE
  .\03_tasks_import.ps1
.NOTES
  Templates must not contain real user paths; use placeholders (e.g. %USERPROFILE%, TA_ROOT).
  Logs to local\logs\.
#>

$ErrorActionPreference = 'Stop'
$RepoRoot = Split-Path -Parent (Split-Path -Parent $PSCommandPath)
$TasksDir = Join-Path $RepoRoot 'config' 'tasks'
$LogDir   = Join-Path $RepoRoot 'local' 'logs'
$LogFile  = Join-Path $LogDir "tasks_import_$(Get-Date -Format 'yyyyMMdd-HHmmss').log"

function Write-Log { param([string]$Message) $m = "[$(Get-Date -Format 'o')] $Message"; Write-Host $m; if (Test-Path $LogDir) { Add-Content -LiteralPath $LogFile -Value $m -ErrorAction SilentlyContinue } }

if (-not (Test-Path $LogDir)) { New-Item -ItemType Directory -Path $LogDir -Force | Out-Null }

$isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $isAdmin) {
    Write-Log "ERROR: This script must be run as Administrator to import scheduled tasks."
    exit 1
}

if (-not (Test-Path $TasksDir)) {
    Write-Log "Tasks directory not found: $TasksDir. Nothing to import."
    exit 0
}

$xmlFiles = Get-ChildItem -Path $TasksDir -Filter '*.xml' -ErrorAction SilentlyContinue
if (-not $xmlFiles) {
    Write-Log "No .xml files in $TasksDir. Nothing to import."
    exit 0
}

foreach ($f in $xmlFiles) {
    try {
        Write-Log "Importing task from: $($f.Name)"
        & schtasks /Create /TN $f.BaseName /XML $f.FullName /F 2>&1 | ForEach-Object { Write-Log $_ }
        Write-Log "Imported: $($f.BaseName)"
    } catch {
        Write-Log "ERROR importing $($f.Name): $($_.Exception.Message)"
    }
}

Write-Log "Tasks import completed."

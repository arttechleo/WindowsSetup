#Requires -Version 5.1
<#
.SYNOPSIS
  Starts the Alienware M16 R1 fan control GUI minimized at logon. No hardcoded user paths.
.DESCRIPTION
  Resolves root via $env:TA_ROOT or repo-relative local/. Looks for a known fan-control
  executable name (see $ExeName). Idempotent for "start once". Logs to local\logs\.
.EXAMPLE
  .\start-fan-control.ps1
.NOTES
  Set TA_ROOT to the folder containing the fan control .exe, or place the .exe under repo local/.
  Do not commit any .exe. See features\alienware-m16r1-fans\README.md.
#>

$ErrorActionPreference = 'Stop'
$ScriptDir = Split-Path -Parent $PSCommandPath
$FeatureRoot = Split-Path -Parent $ScriptDir
$RepoRoot   = Split-Path -Parent (Split-Path -Parent $FeatureRoot)
$LocalDir   = Join-Path $RepoRoot 'local'
$LogDir     = Join-Path $LocalDir 'logs'

# Default executable name (change if your tool uses another name)
$ExeName = 'FanControl.exe'

function Write-Log { param([string]$Message) $m = "[$(Get-Date -Format 'o')] $Message"; Write-Host $m; if (Test-Path $LogDir) { Add-Content -LiteralPath (Join-Path $LogDir "fan-control_$(Get-Date -Format 'yyyyMMdd').log") -Value $m -ErrorAction SilentlyContinue } }

# Resolve TA_ROOT or fallback to local
$Root = $env:TA_ROOT
if (-not $Root -or -not (Test-Path $Root)) {
    $Root = $LocalDir
}
if (-not (Test-Path $Root)) {
    Write-Host "ERROR: Fan control root not found."
    Write-Host "  Option A: Set TA_ROOT to the folder containing the fan control .exe:"
    Write-Host "    [Environment]::SetEnvironmentVariable('TA_ROOT', 'C:\Path\To\FanControl', 'User')"
    Write-Host "  Option B: Create repo local\ folder and place the .exe there (e.g. local\FanControl.exe)."
    Write-Host "See features\alienware-m16r1-fans\README.md for where to obtain the binary (not included in repo)."
    exit 1
}

$ExePath = Join-Path $Root $ExeName
if (-not (Test-Path $ExePath)) {
    Write-Host "ERROR: Executable not found: $ExePath"
    Write-Host "  Set TA_ROOT to the folder that contains $ExeName, or place $ExeName in: $LocalDir"
    Write-Host "  Do not commit the .exe. See features\alienware-m16r1-fans\README.md."
    exit 1
}

if (-not (Test-Path $LogDir)) { New-Item -ItemType Directory -Path $LogDir -Force | Out-Null }

Write-Log "Starting fan control: $ExePath (minimized)"
$psi = New-Object System.Diagnostics.ProcessStartInfo
$psi.FileName = $ExePath
$psi.WorkingDirectory = $Root
$psi.WindowStyle = [System.Diagnostics.ProcessWindowStyle]::Minimized
$psi.UseShellExecute = $true
[System.Diagnostics.Process]::Start($psi) | Out-Null
Write-Log "Launched."

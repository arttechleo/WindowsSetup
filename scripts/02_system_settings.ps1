#Requires -Version 5.1
<#
.SYNOPSIS
  Applies safe, optional system toggles; no irreversible tweaks. Idempotent.
.DESCRIPTION
  Uses flags to enable/disable specific changes. Default is to do nothing unless you set flags.
  Logs to local\logs\. No hardcoded user paths.
.PARAMETER DisableTelemetry
  If set, disables optional telemetry (where available via policies/settings).
.PARAMETER EnableDeveloperMode
  If set, enables Developer Mode (Windows 10/11).
.EXAMPLE
  .\02_system_settings.ps1
  .\02_system_settings.ps1 -DisableTelemetry -EnableDeveloperMode
.NOTES
  Run as Administrator for settings that require elevation. Add more flags as needed.
#>

[CmdletBinding()]
param(
    [switch]$DisableTelemetry,
    [switch]$EnableDeveloperMode
)

$ErrorActionPreference = 'Stop'
$RepoRoot = Split-Path -Parent (Split-Path -Parent $PSCommandPath)
$LogDir   = Join-Path $RepoRoot 'local' 'logs'
$LogFile  = Join-Path $LogDir "system_settings_$(Get-Date -Format 'yyyyMMdd-HHmmss').log"

function Write-Log { param([string]$Message) $m = "[$(Get-Date -Format 'o')] $Message"; Write-Host $m; if (Test-Path $LogDir) { Add-Content -LiteralPath $LogFile -Value $m -ErrorAction SilentlyContinue } }

if (-not (Test-Path $LogDir)) { New-Item -ItemType Directory -Path $LogDir -Force | Out-Null }

$isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $isAdmin) { Write-Log "WARNING: Not running as Administrator; some settings may not apply." }

if (-not $DisableTelemetry -and -not $EnableDeveloperMode) {
    Write-Log "No flags set. Use -DisableTelemetry and/or -EnableDeveloperMode to apply changes. Exiting."
    exit 0
}

if ($DisableTelemetry) {
    try {
        # Disable optional diagnostic data (machine-wide where supported)
        $path = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection'
        if (-not (Test-Path $path)) { New-Item -Path $path -Force | Out-Null }
        Set-ItemProperty -Path $path -Name 'AllowTelemetry' -Value 0 -Type DWord -ErrorAction SilentlyContinue
        Write-Log "Set AllowTelemetry = 0 (disable)."
    } catch {
        Write-Log "DisableTelemetry: $($_.Exception.Message)"
    }
}

if ($EnableDeveloperMode) {
    try {
        $path = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\AppModelUnlock'
        if (-not (Test-Path $path)) { New-Item -Path $path -Force | Out-Null }
        Set-ItemProperty -Path $path -Name 'AllowDevelopmentWithoutDevLicense' -Value 1 -Type DWord -ErrorAction SilentlyContinue
        Write-Log "Enabled Developer Mode (AllowDevelopmentWithoutDevLicense = 1)."
    } catch {
        Write-Log "EnableDeveloperMode: $($_.Exception.Message)"
    }
}

Write-Log "System settings script completed."

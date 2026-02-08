#Requires -Version 5.1
<#
.SYNOPSIS
  Creates scheduled task TA-Fans-OnLogon to run start-fan-control.ps1 at user logon with highest privileges.
.DESCRIPTION
  Task runs the PowerShell script that starts the fan control GUI minimized. Uses full path to
  script derived from repo location (no hardcoded S:\ or C:\Users\...). Idempotent (/F overwrites).
.EXAMPLE
  Run as Administrator: .\register-fans-onlogon.ps1
.NOTES
  Requires elevation. Script path is resolved from this script's location; TA_ROOT is not required for the task (only for start-fan-control.ps1).
#>

$ErrorActionPreference = 'Stop'
$ScriptDir = Split-Path -Parent $PSCommandPath
$FeatureRoot = Split-Path -Parent $ScriptDir
$RepoRoot   = Split-Path -Parent (Split-Path -Parent $FeatureRoot)
$StartScript = Join-Path $FeatureRoot 'scripts' 'start-fan-control.ps1'

if (-not (Test-Path $StartScript)) {
    Write-Host "ERROR: start-fan-control.ps1 not found at: $StartScript"
    exit 1
}

$isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $isAdmin) {
    Write-Host "ERROR: Run this script as Administrator to create the scheduled task."
    exit 1
}

$psExe = (Get-Command powershell.exe).Source
$taskName = 'TA-Fans-OnLogon'
$action = "& `"$psExe`" -NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -File `"$StartScript`""
$trigger = New-ScheduledTaskTrigger -AtLogOn -User $env:USERNAME
$principal = New-ScheduledTaskPrincipal -UserId $env:USERNAME -LogonType Interactive -RunLevel Highest
$settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -StartWhenAvailable

Register-ScheduledTask -TaskName $taskName -Action (New-ScheduledTaskAction -Execute $psExe -Argument "-NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -File `"$StartScript`"" -WorkingDirectory $RepoRoot) -Trigger $trigger -Principal $principal -Settings $settings -Force | Out-Null
Write-Host "Scheduled task '$taskName' created. It runs at logon and starts the fan control GUI minimized."
Write-Host "To test: Run the task once from Task Scheduler, or log off and log on."

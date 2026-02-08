# Alienware M16 R1 — Fan control automation

Automation to start a third-party fan control GUI minimized at logon via a scheduled task. **No binaries are included in this repo;** you must obtain the required software and place it in `local/` or a folder pointed to by `TA_ROOT`.

## Approach

- **start-fan-control.ps1** — Launches the fan control GUI minimized. Uses `$env:TA_ROOT` or repo-relative `local/` to find the executable; no hardcoded `S:\` or user paths.
- **register-fans-onlogon.ps1** — Creates a scheduled task `TA-Fans-OnLogon` (run at logon, highest privileges) that runs `start-fan-control.ps1`.
- **profiles/TA-Quiet-25-Baseline-Steps.md** — Human steps to set the fan curve in the GUI (no automation of the curve itself).
- **config/tasks/TA-Fans-OnLogon.template.xml** — Sanitized task template (no user paths) for reference or import.

## Risks

- **Third-party software:** Fan control tools run with high privileges and can affect thermal behavior. Use only from trusted sources.
- **Warranty / safety:** Modifying fan behavior may affect temperatures. Use at your own risk; follow the tool’s documentation.
- **Updates:** After Windows or driver updates, re-test fan behavior.

## Prerequisites

1. **Obtain the fan control binary** from the official or trusted source (e.g. Alienware Command Center, or a community tool you trust). Do **not** commit any `.exe` into this repo.
2. Place the executable (and any required DLLs) in one of:
   - **Option A:** A folder of your choice and set `TA_ROOT` to that folder (e.g. `[Environment]::SetEnvironmentVariable('TA_ROOT', 'C:\Tools\FanControl', 'User')`).
   - **Option B:** Repo’s `local/` folder (e.g. `local\fancontrol\`). If `TA_ROOT` is not set, the script looks for a known executable name under `local\` relative to the repo.

## Setup (after placing binaries)

1. Open PowerShell **as Administrator**.
2. From the repo root (or from `features\alienware-m16r1-fans`):
   ```powershell
   .\scripts\register-fans-onlogon.ps1
   ```
3. Log off and log on (or run the task once manually) to start the fan control GUI minimized.
4. Configure the curve in the GUI; see **profiles/TA-Quiet-25-Baseline-Steps.md** for a baseline.

## If TA_ROOT is not set

The scripts will look for the fan control binary under the repo’s `local/` directory. If nothing is found, they exit with a clear error and instructions to either set `TA_ROOT` or place the binaries in `local/`. No paths like `S:\` or `C:\Users\...` are hardcoded.

# Restore checklist — Fresh Windows to Blueprint

Use this checklist after a clean Windows install to bring the machine in line with the WindowsSetup blueprint.

## Prerequisites

- Windows 10/11 (admin account).
- PowerShell execution policy allowing scripts:  
  `Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser` (or run as Admin for LocalMachine).

## 1. Get the repo

- Clone (or pull) the repo. Prefer a path that does **not** include your Windows username if the repo might be shared.
- Ensure `local/` exists (e.g. `mkdir local` if not). All your exports and logs will go here.

## 2. Bootstrap

- Open PowerShell **as Administrator**.
- From the repo root:
  ```powershell
  .\scripts\00_bootstrap.ps1
  ```
- This checks admin, winget presence, and creates `local\logs` for script logs. Fix any reported issues before continuing.

## 3. Winget apps

- If you have a saved export: place it at `local\winget-apps.json`.
- Run:
  ```powershell
  .\scripts\01_winget_import.ps1
  ```
- If the file is missing, the script prints **export instructions**; export on a reference machine to `local\winget-apps.json`, then re-run.

## 4. System settings

- Run:
  ```powershell
  .\scripts\02_system_settings.ps1
  ```
- Script uses flags for optional toggles; no irreversible changes. Review parameters in the script header if needed.

## 5. Scheduled tasks

- Place any **sanitized** task XML templates in `config\tasks\` (or use the ones from the repo).
- Run:
  ```powershell
  .\scripts\03_tasks_import.ps1
  ```
- Script imports templates from `config\tasks\`, idempotent; actions are logged to `local\logs`.

## 6. Power plan

- If you have a saved power plan: place it at `local\powerplan.pow`.
- Run:
  ```powershell
  .\scripts\04_powerplan.ps1
  ```
- If the file is missing, the script prints **export instructions**; export on a reference machine to `local\powerplan.pow`, then re-run.

## 7. Optional — Alienware M16 R1 fan control

- If you use that hardware, switch to the `alienware-m16r1-fans` branch and follow **features/alienware-m16r1-fans/README.md** (obtain binaries, set `TA_ROOT` or paths, run `register-fans-onlogon.ps1`).

## Order summary

| Step | Script / action |
|------|------------------|
| 1 | Clone repo; ensure `local/` exists |
| 2 | `.\scripts\00_bootstrap.ps1` (Admin) |
| 3 | `.\scripts\01_winget_import.ps1` |
| 4 | `.\scripts\02_system_settings.ps1` |
| 5 | `.\scripts\03_tasks_import.ps1` |
| 6 | `.\scripts\04_powerplan.ps1` |
| 7 | (Optional) Alienware fan feature on its branch |

All scripts are idempotent and log to `local\logs\`. Do not commit anything under `local/`.

# WindowsSetup Blueprint

A **reproducible Windows reinstall blueprint** with strict security hygiene. Use this repo to restore a clean Windows install to a consistent, hardened configuration via scripts and documented steps—without committing personal data.

## Overview

- **Scripts** run in order (`00_bootstrap.ps1` → `04_powerplan.ps1`) and are idempotent.
- **Config** holds templates and task definitions; real exports (winget, power plans, etc.) go in `local/` (gitignored).
- **Docs** cover security rules, restore checklist, and optional tooling (pre-commit, GitHub settings).

## Branches

| Branch | Purpose |
|--------|--------|
| `main` | Core blueprint: bootstrap, winget, system settings, tasks, power plan. |
| `alienware-m16r1-fans` | Alienware M16 R1 fan-control automation (scheduled task + GUI launcher). See [features/alienware-m16r1-fans/](features/alienware-m16r1-fans/) on that branch. |

## Quick start (fresh Windows)

1. Clone this repo (do **not** clone into a path that contains your username if you plan to share it).
2. Run PowerShell **as Administrator** from the repo root:
   ```powershell
   Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
   .\scripts\00_bootstrap.ps1
   .\scripts\01_winget_import.ps1
   .\scripts\02_system_settings.ps1
   .\scripts\03_tasks_import.ps1
   .\scripts\04_powerplan.ps1
   ```
3. Follow any printed instructions when a script expects a file in `local/` (e.g. `local/winget-apps.json`, `local/powerplan.pow`).

See **[docs/RESTORE_CHECKLIST.md](docs/RESTORE_CHECKLIST.md)** for the full restore flow.

## Repository layout

```
WindowsSetup/
├── scripts/           # Run in order: 00–04
├── config/
│   ├── templates/     # Example export commands and placeholders (no real data)
│   └── tasks/         # Sanitized scheduled task templates
├── docs/              # Security, checklist, pre-commit
├── local/             # Gitignored: your exports, logs, machine-specific files
└── README.md
```

## Security

- **Never commit:** usernames, emails, machine names, `C:\Users\...` paths, serials, license keys, tokens, cookies, SSH keys, or raw registry/power-plan exports.
- Put all machine-specific files and exports in `local/`.
- See **[docs/SECURITY.md](docs/SECURITY.md)** for what must not be committed and how to sanitize exports.

## License

See repository license file.

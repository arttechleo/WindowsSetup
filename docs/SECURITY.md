# Security — What Must Never Be Committed

This document defines what must **never** be committed to the WindowsSetup repo (public) and how to keep exports safe.

## Never commit

- **Personal identifiers:** usernames, email addresses, machine/host names, real names.
- **Paths:** `C:\Users\<username>\...`, or any path that reveals your username or machine.
- **Secrets:** license keys, API keys, tokens, passwords, cookies, connection strings.
- **Keys:** SSH private keys (e.g. `id_rsa`), certificates, `.pem` files.
- **Raw exports** that haven’t been reviewed:
  - Registry (`.reg`) — often contain user paths, SIDs, machine IDs.
  - Power plan (`.pow`) — can contain machine-specific GUIDs; use templates or document export into `local/`.
  - Scheduled task XML — usually contains `C:\Users\...` in actions; must be sanitized to templates.

## Where private data goes

- **`local/`** — All machine-specific files: your winget export, power plan export, logs, and any paths that point to your user profile. The entire `local/` directory is in `.gitignore`.

## How to sanitize exports

### Registry (`.reg`)

- Do **not** commit raw `.reg` dumps.
- Prefer: document manual steps or provide a **template** with placeholders (e.g. `%USERPROFILE%`, `%LOCALAPPDATA%`) and instructions to export into `local/`.
- If you must keep a snippet in the repo: replace usernames, SIDs, and real paths with placeholders; strip any keys that contain tokens or machine IDs.

### Scheduled tasks (XML)

- Export from Task Scheduler, then:
  - Replace `C:\Users\*` and any username with a placeholder (e.g. `%USERPROFILE%` or a documented variable like `TA_ROOT`).
  - Remove or generalize `Author`, `UserId` if they expose identity.
- Store the sanitized XML in `config/tasks/` as a `.template.xml`; document that users copy/import and adjust paths.

### Winget export

- `winget export -o local/winget-apps.json` is fine **only** if the path is in `local/` (gitignored). Do not commit that file.
- In the repo we only provide `config/templates/winget-export.example.txt` with the **command** to run, not the actual export.

### Power plan (`.pow`)

- Export to `local/powerplan.pow` (gitignored). Repo contains only `config/templates/powercfg-export.example.txt` with the export **command**.

## Pre-commit check

Use the script in `docs/install-pre-commit.ps1` (or the hook in `docs/pre-commit`) to scan for forbidden patterns before each commit. The scan looks for:

- `C:\Users\`
- `@` (likely email)
- `BEGIN RSA PRIVATE KEY`
- `token`, `api_key`, `password`

See **docs/install-pre-commit.ps1** for how to install the hook. Run the same scan manually before pushing if you don’t use the hook.

## GitHub

- Enable **secret scanning** and **push protection** in the repo settings so that accidental pushes of secrets are blocked or flagged.
- No API calls are required; configure under **Settings → Code security and analysis**.

## Pre-commit hook

- Install: run `.\docs\install-pre-commit.ps1` from the repo root.
- The hook runs `docs\pre-commit-scan.ps1` and greps staged files for: `C:\Users\`, `@`, `BEGIN RSA PRIVATE KEY`, `token`, `api_key`, `password`. Files under `docs/` are exempt from the `token`/`api_key`/`password` checks so that SECURITY.md and similar docs can mention them.

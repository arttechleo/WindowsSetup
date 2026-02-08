# Git operations — blueprint and Alienware branch

Run these from the repo root in a shell where `git` is in PATH. **Before committing, run the forbidden-pattern scan** and fix any reported files.

## 1. Scan before commit (required)

With nothing staged (e.g. before first commit), scan all tracked files:

```powershell
.\docs\pre-commit-scan.ps1 -ScanAll
```

After staging, you can run without `-ScanAll` to scan only staged files. If any file is listed, remove or sanitize the forbidden content (see docs/SECURITY.md), then re-run. Exit code 0 = OK to commit.

## 2. Commit and push main (blueprint only)

**Do not** add `features/` or `config/tasks/TA-Fans-OnLogon.template.xml` to this commit; they belong on the Alienware branch.

```powershell
git add .gitignore README.md docs/ scripts/ config/templates/ config/tasks/README.md
git status
.\docs\pre-commit-scan.ps1
git commit -m "Bootstrap WindowsSetup blueprint (secure scaffolding)"
git push origin main
```

If your default branch is `master`, use `master` instead of `main` and push to `origin master`.

## 3. Create Alienware branch and add fan feature

```powershell
git checkout -b alienware-m16r1-fans
git add features/ config/tasks/TA-Fans-OnLogon.template.xml
git status
.\docs\pre-commit-scan.ps1
git commit -m "Add Alienware M16R1 fan-control automation"
git push origin alienware-m16r1-fans
```

## 4. Update README on main (mention feature branch)

```powershell
git checkout main
```

The README.md already includes a **Branches** section that mentions `alienware-m16r1-fans`. If you need to edit it:

```powershell
# edit README.md if desired, then:
git add README.md
git commit -m "Docs: mention Alienware feature branch"
git push origin main
```

## Optional: install pre-commit hook

So every future commit is scanned automatically:

```powershell
.\docs\install-pre-commit.ps1
```

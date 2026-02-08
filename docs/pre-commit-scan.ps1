#Requires -Version 5.1
<#
.SYNOPSIS
  Scans staged (or given) files for forbidden patterns. Use as pre-commit hook or run manually.
.DESCRIPTION
  Forbidden patterns: C:\Users\, @ (email), BEGIN RSA PRIVATE KEY, token, api_key, password.
  Run from repo root. Exits 1 if any match found (do not commit); 0 otherwise.
.EXAMPLE
  .\docs\pre-commit-scan.ps1
  git diff --cached --name-only | .\docs\pre-commit-scan.ps1
.NOTES
  Install hook via docs\install-pre-commit.ps1.
#>

param(
    # If not provided, uses: git diff --cached --name-only. Use -ScanAll to scan all tracked files (e.g. before first commit).
    [string[]]$Files = @(),
    [switch]$ScanAll
)

$ErrorActionPreference = 'Stop'
$RepoRoot = if ($PSScriptRoot) { Split-Path -Parent $PSScriptRoot } else { $null }
if (-not $RepoRoot) { $RepoRoot = (Get-Location).Path }
Set-Location $RepoRoot

$patterns = @(
    'C:\\Users\\'
    '@'           # likely email; may have false positives in docs; we allow in example.txt if it's "your@email" placeholder
    'BEGIN RSA PRIVATE KEY'
    'BEGIN OPENSSH PRIVATE KEY'
    'token'
    'api_key'
    'password'
)

# Get staged files (or all tracked) if none passed
if ($Files.Count -eq 0) {
    $git = Get-Command git -ErrorAction SilentlyContinue
    if (-not $git) { Write-Host "git not in PATH; skipping pre-commit scan."; exit 0 }
    if ($ScanAll) {
        $out = & git ls-files 2>$null
    } else {
        $out = & git diff --cached --name-only 2>$null
    }
    $Files = @($out)
}

$violations = @()
$docPatterns = @('token', 'api_key', 'password')  # Skip these in docs/ and README to allow documentation.
foreach ($f in $Files) {
    if (-not $f -or -not (Test-Path $f)) { continue }
    $content = Get-Content -LiteralPath $f -Raw -ErrorAction SilentlyContinue
    if (-not $content) { continue }
    $inDocs = $f -replace '\\', '/' -match '^docs/'
    foreach ($p in $patterns) {
        if ($content -match [regex]::Escape($p)) {
            if ($inDocs) { continue }  # docs/ may document forbidden patterns
            if ($p -eq '@' -and (($f -match '\.example\.' -or $f -match '\.md$') -and $content -match 'your@email|user@host|example@')) { continue }
            if ($p -eq '@' -and $f -match '\.xml$' -and $content -match 'xmlns') { continue }
            if ($p -eq 'token' -and $f -match '\.xml$' -and $content -match 'InteractiveToken') { continue }
            if (($f -replace '\\', '/' -match 'README\.md$') -or ($f -match '\.gitignore$')) { if ($docPatterns -contains $p) { continue } }
            $violations += "$f : forbidden pattern '$p'"
        }
    }
}

if ($violations.Count -gt 0) {
    Write-Host "PRE-COMMIT SCAN FAILED - do not commit:"
    $violations | ForEach-Object { Write-Host "  $_" }
    exit 1
}
Write-Host "Pre-commit scan passed (no forbidden patterns)."
exit 0

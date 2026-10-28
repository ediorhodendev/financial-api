param([Parameter(Mandatory=$true)][string]$Repository)
$ErrorActionPreference = 'Stop'
Set-Location (Split-Path $PSScriptRoot -Parent)
# Run only after reviewing the source and passing Test-All.ps1.
if ($Repository -notmatch '^[A-Za-z0-9_.-]+/[A-Za-z0-9_.-]+$') { throw 'Use owner/repository.' }
& gh auth status
if ($LASTEXITCODE -ne 0) { throw 'Authenticate GitHub CLI with gh auth login.' }
if (-not (Test-Path .git)) {
    git init -b main
    if ($LASTEXITCODE -ne 0) { throw 'git init failed.' }
}
$forbidden=git ls-files --cached --others --exclude-standard | Where-Object { $_ -match '(^|/)\.env$|(^|/)secrets\.json$|\.pfx$|\.pem$|\.key$' }
if ($forbidden) { throw "Remove sensitive files before publishing: $($forbidden -join ', ')" }
Write-Host 'Review git status and the diff before publishing. This command creates a PUBLIC repository.'
git status --short
$answer=Read-Host 'Type PUBLICAR to commit and publish the public repository'
if ($answer -cne 'PUBLICAR') { throw 'Publication cancelled.' }
git add .
if ($LASTEXITCODE -ne 0) { throw 'git add failed.' }
git commit -m 'Implement financial ledger API with PostgreSQL and automated tests'
if ($LASTEXITCODE -ne 0) { throw 'Commit failed; check your Git identity or existing commits.' }
gh repo create $Repository --public --source . --remote origin --push
if ($LASTEXITCODE -ne 0) { throw 'Publication failed; inspect the GitHub CLI result.' }

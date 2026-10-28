param([string]$DatabasePassword)
$ErrorActionPreference = 'Stop'
Set-Location (Split-Path $PSScriptRoot -Parent)
function Run([string]$Program, [string[]]$Arguments) {
    & $Program @Arguments
    if ($LASTEXITCODE -ne 0) { throw "$Program failed with exit code $LASTEXITCODE" }
}
if (-not (Test-Path .env)) { Copy-Item .env.example .env; throw 'Edit .env and set POSTGRES_PASSWORD, then run again.' }
if (-not $DatabasePassword) {
    $entry = Get-Content .env | Where-Object { $_ -match '^POSTGRES_PASSWORD=' } | Select-Object -First 1
    if (-not $entry) { throw 'POSTGRES_PASSWORD missing in .env' }
    $DatabasePassword = $entry.Substring('POSTGRES_PASSWORD='.Length).Trim()
}
if ($DatabasePassword -eq 'replace-with-local-password') { throw 'Replace the example password in .env.' }
# The generic builder escapes delimiters for the PostgreSQL connection string.
$env:POSTGRES_PASSWORD=$DatabasePassword
$cs = [System.Data.Common.DbConnectionStringBuilder]::new()
$cs['Host']='localhost'; $cs['Port']=5432; $cs['Database']='financial'; $cs['Username']='financial_local'; $cs['Password']=$DatabasePassword
$env:ConnectionStrings__Financial=$cs.ConnectionString
$env:ASPNETCORE_ENVIRONMENT='Development'
Run 'docker' @('compose','up','-d','--wait','postgres')
Run 'dotnet' @('restore','Financial.slnx')
Run 'dotnet' @('build','Financial.slnx','-c','Release','--no-restore')
Run 'dotnet' @('tool','restore')
Run 'dotnet' @('ef','database','update','--project','src/Financial.Infrastructure','--startup-project','src/Financial.Api')
Run 'dotnet' @('run','--project','src/Financial.Api','--','--seed-demo')
Write-Host 'Swagger: http://localhost:5080/swagger'
Run 'dotnet' @('run','--project','src/Financial.Api','--urls','http://localhost:5080')

param([string]$DatabasePassword)
$ErrorActionPreference = 'Stop'
Set-Location (Split-Path $PSScriptRoot -Parent)
function Run([string]$Program, [string[]]$Arguments) {
    & $Program @Arguments
    if ($LASTEXITCODE -ne 0) { throw "$Program failed with exit code $LASTEXITCODE" }
}
if (-not $DatabasePassword) {
    if (-not (Test-Path .env)) { throw 'Create .env from .env.example and set POSTGRES_PASSWORD.' }
    $entry=Get-Content .env | Where-Object { $_ -match '^POSTGRES_PASSWORD=' } | Select-Object -First 1
    if (-not $entry) { throw 'POSTGRES_PASSWORD missing.' }
    $DatabasePassword=$entry.Substring('POSTGRES_PASSWORD='.Length).Trim()
}
if ($DatabasePassword -eq 'replace-with-local-password') { throw 'Replace the example password.' }
$env:POSTGRES_PASSWORD=$DatabasePassword
$cs=[System.Data.Common.DbConnectionStringBuilder]::new()
$cs['Host']='localhost'; $cs['Port']=5433; $cs['Database']='financial_test'; $cs['Username']='financial_test'; $cs['Password']=$DatabasePassword
$env:FINANCIAL_TEST_CONNECTION=$cs.ConnectionString
Run 'docker' @('compose','--profile','tests','up','-d','--wait','postgres-test')
Run 'dotnet' @('restore','Financial.slnx')
Run 'dotnet' @('build','Financial.slnx','-c','Release','--no-restore')
Run 'dotnet' @('test','Financial.slnx','-c','Release','--no-build','--logger','trx','--results-directory','TestResults')

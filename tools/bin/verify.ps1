#!/usr/bin/env pwsh
# Wrapper de Windows: ejecuta el mismo verify (Node) con los argumentos dados.
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
& node (Join-Path $scriptDir 'verify') @args
exit $LASTEXITCODE

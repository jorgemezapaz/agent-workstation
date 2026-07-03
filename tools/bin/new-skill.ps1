#!/usr/bin/env pwsh
# Crea el esqueleto de una nueva skill en el repo.
# Uso: new-skill <nombre-de-la-skill>
param([Parameter(Mandatory = $true)][string]$Name)
$ErrorActionPreference = 'Stop'

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$repoDir = (Resolve-Path (Join-Path $scriptDir '..\..')).Path
$skillDir = Join-Path $repoDir "skills\$Name"

if (Test-Path $skillDir) {
  Write-Error "Ya existe una skill llamada '$Name'."
  exit 1
}

New-Item -ItemType Directory -Force -Path $skillDir | Out-Null
$content = @"
---
name: $Name
description: TODO describe cuando debe usarse esta skill (que la dispara).
---

# $Name

TODO: contenido de la skill.

## Cuando usar esta skill

TODO.

## Pasos

1. TODO
"@
Set-Content -Path (Join-Path $skillDir 'SKILL.md') -Value $content -Encoding UTF8

Write-Host "Creada: skills/$Name/SKILL.md"
Write-Host "Recuerda ejecutar el instalador (o ya esta enlazado si usas symlinks)."

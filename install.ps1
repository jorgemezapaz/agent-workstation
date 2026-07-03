#!/usr/bin/env pwsh
# Instalador para Windows (PowerShell).
# Enlaza skills, mcp.json, reglas y hooks del harness a ~/.cursor y agrega tools/bin al PATH de usuario.
# Usa junctions para carpetas (no requiere admin). Para archivos intenta symlink,
# luego hardlink, y si no, copia.
$ErrorActionPreference = 'Stop'

$RepoDir   = Split-Path -Parent $MyInvocation.MyCommand.Path
$CursorDir = Join-Path $HOME '.cursor'
$SkillsDir = Join-Path $CursorDir 'skills'
$ToolsBin  = Join-Path $RepoDir 'tools\bin'

function Write-Info($m) { Write-Host "[install] $m" -ForegroundColor Cyan }
function Write-Warn($m) { Write-Host "[warn] $m"  -ForegroundColor Yellow }

function Remove-LinkOrItem($Path) {
  if (-not (Test-Path $Path)) { return }
  $item = Get-Item $Path -Force
  if ($item.LinkType) { $item.Delete() }       # borra solo el enlace, no el destino
  else { Remove-Item $Path -Recurse -Force }
}

function New-Link($Target, $Link) {
  Remove-LinkOrItem $Link
  $item = Get-Item $Target
  if ($item.PSIsContainer) {
    New-Item -ItemType Junction -Path $Link -Target $Target | Out-Null
  } else {
    try {
      New-Item -ItemType SymbolicLink -Path $Link -Target $Target -ErrorAction Stop | Out-Null
    } catch {
      try {
        New-Item -ItemType HardLink -Path $Link -Target $Target -ErrorAction Stop | Out-Null
      } catch {
        Copy-Item $Target $Link -Force
        Write-Warn "No se pudo enlazar; se copio $Link (re-ejecuta install tras cambios)"
      }
    }
  }
}

New-Item -ItemType Directory -Force -Path $SkillsDir | Out-Null

# 1) Skills
Write-Info "Enlazando skills en $SkillsDir"
Get-ChildItem -Directory (Join-Path $RepoDir 'skills') | ForEach-Object {
  New-Link $_.FullName (Join-Path $SkillsDir $_.Name)
  Write-Info "  skill: $($_.Name)"
}

# 2) MCP
$mcpSrc = Join-Path $RepoDir 'mcps\mcp.json'
if (Test-Path $mcpSrc) {
  $mcpDst = Join-Path $CursorDir 'mcp.json'
  if ((Test-Path $mcpDst) -and -not ((Get-Item $mcpDst -Force).LinkType)) {
    $backup = "$mcpDst.backup.$(Get-Date -Format yyyyMMddHHmmss)"
    Move-Item $mcpDst $backup
    Write-Warn "mcp.json existente respaldado en: $backup"
  }
  New-Link $mcpSrc $mcpDst
  Write-Info "MCP enlazado -> $mcpDst"
}

# 3) Rules (harness) -> symlink de cada .mdc en ~/.cursor/rules
$rulesSrc = Join-Path $RepoDir 'harness\rules'
if (Test-Path $rulesSrc) {
  $rulesDir = Join-Path $CursorDir 'rules'
  New-Item -ItemType Directory -Force -Path $rulesDir | Out-Null
  Get-ChildItem -File (Join-Path $rulesSrc '*.mdc') | ForEach-Object {
    New-Link $_.FullName (Join-Path $rulesDir $_.Name)
    Write-Info "  regla: $($_.Name)"
  }
}

# 4) Hooks (harness) -> symlink de hooks.json y de la carpeta hooks
$hooksJson = Join-Path $RepoDir 'harness\hooks.json'
if (Test-Path $hooksJson) {
  $hooksDst = Join-Path $CursorDir 'hooks.json'
  if ((Test-Path $hooksDst) -and -not ((Get-Item $hooksDst -Force).LinkType)) {
    Move-Item $hooksDst "$hooksDst.backup.$(Get-Date -Format yyyyMMddHHmmss)"
    Write-Warn "hooks.json existente respaldado"
  }
  New-Link $hooksJson $hooksDst
  $hooksDir = Join-Path $CursorDir 'hooks'
  if ((Test-Path $hooksDir) -and -not ((Get-Item $hooksDir -Force).LinkType)) {
    Move-Item $hooksDir "$hooksDir.backup.$(Get-Date -Format yyyyMMddHHmmss)"
    Write-Warn "carpeta hooks existente respaldada"
  }
  New-Link (Join-Path $RepoDir 'harness\hooks') $hooksDir
  Write-Info "hooks del harness enlazados -> $hooksDst"
}

# 5) Tools -> PATH de usuario
if (Test-Path $ToolsBin) {
  $userPath = [Environment]::GetEnvironmentVariable('Path', 'User')
  if (($userPath -split ';') -notcontains $ToolsBin) {
    $newPath = if ($userPath) { "$ToolsBin;$userPath" } else { $ToolsBin }
    [Environment]::SetEnvironmentVariable('Path', $newPath, 'User')
    Write-Info "tools/bin agregado al PATH de usuario (reinicia la terminal)"
  } else {
    Write-Info "tools/bin ya estaba en el PATH de usuario"
  }
  $env:Path = "$ToolsBin;$env:Path"
}

Write-Info "Listo. Reinicia Cursor y tu terminal para aplicar los cambios."

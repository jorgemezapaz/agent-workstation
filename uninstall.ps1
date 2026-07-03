#!/usr/bin/env pwsh
# Desinstalador para Windows (PowerShell).
# Quita los enlaces de skills, el de mcp.json y la entrada de PATH de usuario.
# No borra tus backups de mcp.json.
$ErrorActionPreference = 'Stop'

$RepoDir   = Split-Path -Parent $MyInvocation.MyCommand.Path
$CursorDir = Join-Path $HOME '.cursor'
$SkillsDir = Join-Path $CursorDir 'skills'
$ToolsBin  = Join-Path $RepoDir 'tools\bin'

function Write-Info($m) { Write-Host "[uninstall] $m" -ForegroundColor Cyan }

# 1) Skills: borra solo enlaces (junction/symlink) que apunten al repo
if (Test-Path $SkillsDir) {
  Get-ChildItem -Directory (Join-Path $RepoDir 'skills') | ForEach-Object {
    $link = Join-Path $SkillsDir $_.Name
    if (Test-Path $link) {
      $item = Get-Item $link -Force
      if ($item.LinkType -and $item.Target -and ($item.Target -like "$RepoDir*")) {
        $item.Delete()
        Write-Info "skill desenlazada: $($_.Name)"
      }
    }
  }
}

# 2) MCP: borra el enlace si apunta al repo
$mcpDst = Join-Path $CursorDir 'mcp.json'
if (Test-Path $mcpDst) {
  $item = Get-Item $mcpDst -Force
  if ($item.LinkType -and $item.Target -and ($item.Target -like "$RepoDir*")) {
    $item.Delete()
    Write-Info "mcp.json desenlazado"
  }
}

# 3) Rules (harness): borra enlaces que apunten al repo
$rulesDir = Join-Path $CursorDir 'rules'
$rulesSrc = Join-Path $RepoDir 'harness\rules'
if ((Test-Path $rulesDir) -and (Test-Path $rulesSrc)) {
  Get-ChildItem -File (Join-Path $rulesSrc '*.mdc') | ForEach-Object {
    $link = Join-Path $rulesDir $_.Name
    if (Test-Path $link) {
      $item = Get-Item $link -Force
      if ($item.LinkType -and $item.Target -and ($item.Target -like "$RepoDir*")) {
        $item.Delete(); Write-Info "regla desenlazada: $($_.Name)"
      }
    }
  }
}

# 4) Hooks (harness): borra los enlaces si apuntan al repo
foreach ($h in @((Join-Path $CursorDir 'hooks.json'), (Join-Path $CursorDir 'hooks'))) {
  if (Test-Path $h) {
    $item = Get-Item $h -Force
    if ($item.LinkType -and $item.Target -and ($item.Target -like "$RepoDir*")) {
      $item.Delete(); Write-Info "hook desenlazado: $(Split-Path $h -Leaf)"
    }
  }
}

# 5) PATH de usuario: quita tools/bin
$userPath = [Environment]::GetEnvironmentVariable('Path', 'User')
if ($userPath) {
  $parts = $userPath -split ';' | Where-Object { $_ -and ($_ -ne $ToolsBin) }
  [Environment]::SetEnvironmentVariable('Path', ($parts -join ';'), 'User')
  Write-Info "tools/bin removido del PATH de usuario"
}

Write-Info "Listo. Reinicia Cursor y tu terminal."

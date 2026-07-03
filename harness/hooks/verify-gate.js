#!/usr/bin/env node
'use strict';
// Hook subagentStop: corre los gates rapidos en el proyecto y, si fallan,
// devuelve un followup_message para que el subagente corrija. Fail-open.
const fs = require('fs');
const path = require('path');
const { spawnSync } = require('child_process');

function readInput() {
  try {
    const raw = fs.readFileSync(0, 'utf8');
    return raw ? JSON.parse(raw) : {};
  } catch {
    return {};
  }
}

function findProjectDir(data) {
  const cands = [];
  if (Array.isArray(data.workspace_roots)) cands.push(...data.workspace_roots);
  for (const k of ['workspace_root', 'project_root', 'cwd', 'worktree_path', 'workspaceRoot']) {
    if (typeof data[k] === 'string') cands.push(data[k]);
  }
  cands.push(process.cwd());
  for (const c of cands) {
    try {
      if (c && fs.existsSync(path.join(c, 'package.json'))) return c;
    } catch {}
  }
  return null; // en v1 solo verificamos proyectos Node
}

function main() {
  const data = readInput();
  const dir = findProjectDir(data);
  if (!dir) return {};

  const verify = path.join(__dirname, '..', '..', 'tools', 'bin', 'verify');
  let res;
  try {
    res = spawnSync(process.execPath, [verify, '--quick'], {
      cwd: dir,
      encoding: 'utf8',
      timeout: 120000,
    });
  } catch {
    return {};
  }
  if (!res || res.status === 0) return {};

  const output = ((res.stdout || '') + (res.stderr || '')).trim().slice(-1500);
  return {
    followup_message:
      'Los gates de verificacion (verify --quick) fallaron en ' + dir +
      '. Corrige los errores y vuelve a correr `verify` antes de terminar.\n\n' + output,
  };
}

let result = {};
try { result = main(); } catch { result = {}; }
try { process.stdout.write(JSON.stringify(result)); } catch {}
process.exit(0);

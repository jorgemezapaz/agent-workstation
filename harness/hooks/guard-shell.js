#!/usr/bin/env node
'use strict';
// Hook beforeShellExecution: bloquea comandos catastroficos y pide revision
// para los riesgosos. Fail-open: ante cualquier error, permite.
const fs = require('fs');

function readInput() {
  try {
    const raw = fs.readFileSync(0, 'utf8');
    return raw ? JSON.parse(raw) : {};
  } catch {
    return {};
  }
}

function decide(cmd) {
  const c = String(cmd || '').toLowerCase();
  if (!c) return { permission: 'allow' };

  const block = [
    /rm\s+-[a-z]*r[a-z]*f?\s+(\/|~|\/\*|\$home)(\s|$)/,
    /rm\s+-[a-z]*f[a-z]*r\s+(\/|~)(\s|$)/,
    /\bmkfs(\.\w+)?\b/,
    /\bdd\b[^\n]*\bof=\/dev\//,
    />\s*\/dev\/sd[a-z]/,
    /\bformat\b\s+[a-z]:/,
    /\b(rmdir|rd|del)\b[^\n]*\/s[^\n]*[a-z]:\\/,
    /:\(\)\s*\{\s*:\s*\|\s*:\s*&\s*\}\s*;\s*:/,
    /chmod\s+-r\s+777\s+\//,
  ];
  const warn = [
    /git\s+push\s+[^\n]*(--force|-f)\b/,
    /git\s+reset\s+--hard\b/,
    /\b(curl|wget)\b[^\n]*\|\s*(sh|bash|zsh)\b/,
    /rm\s+-[a-z]*r[a-z]*f/,
    /\bsudo\b/,
  ];

  if (block.some((re) => re.test(c))) {
    return {
      permission: 'deny',
      user_message: 'Comando potencialmente destructivo bloqueado por el harness: ' + cmd,
      agent_message: 'Blocked by harness guard (destructive command). Confirma manualmente si es intencional.',
      __block: true,
    };
  }
  if (warn.some((re) => re.test(c))) {
    return {
      permission: 'ask',
      user_message: 'Comando riesgoso, revisa antes de continuar: ' + cmd,
      agent_message: 'Harness guard flagged a risky command; awaiting user review.',
    };
  }
  return { permission: 'allow' };
}

function main() {
  const data = readInput();
  const cmd = data.command || data.shell_command || data.commandLine || '';
  let out;
  try { out = decide(cmd); } catch { out = { permission: 'allow' }; }
  const block = out.__block === true;
  delete out.__block;
  try { process.stdout.write(JSON.stringify(out)); } catch {}
  process.exit(block ? 2 : 0);
}

main();

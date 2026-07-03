#!/usr/bin/env node
'use strict';
// Hook beforeSubmitPrompt: avisa si el prompt parece contener un secreto.
// Escanea el stdin crudo (robusto ante el nombre del campo). Fail-open.
const fs = require('fs');

const PATTERNS = [
  /sk-[A-Za-z0-9]{20,}/,
  /AKIA[0-9A-Z]{16}/,
  /AIza[0-9A-Za-z_\-]{20,}/,
  /xox[baprs]-[0-9A-Za-z-]{10,}/,
  /ghp_[0-9A-Za-z]{20,}/,
  /-----BEGIN [A-Z ]*PRIVATE KEY-----/,
];

function main() {
  let raw = '';
  try { raw = fs.readFileSync(0, 'utf8'); } catch { raw = ''; }
  let out = { permission: 'allow' };
  try {
    if (raw && PATTERNS.some((re) => re.test(raw))) {
      out = {
        permission: 'ask',
        user_message: 'Posible secreto/credencial detectado en el prompt. Revisa antes de enviarlo.',
        agent_message: 'Harness guard detected a possible secret in the prompt.',
      };
    }
  } catch {}
  try { process.stdout.write(JSON.stringify(out)); } catch {}
  process.exit(0);
}

main();

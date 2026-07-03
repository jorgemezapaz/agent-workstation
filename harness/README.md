# Harness

Entorno de trabajo agentico: convenciones (reglas), gates de verificacion y hooks
que aplican el flujo automaticamente en cualquier proyecto.

El instalador enlaza estas piezas a `~/.cursor`, asi que aplican a nivel usuario
en todas tus estaciones (se actualizan con `git pull`).

## Piezas

```
harness/
├── rules/
│   └── harness.mdc      # convenciones (Definition of Done, subagentes, seguridad) — alwaysApply
├── hooks.json           # config de hooks (se enlaza a ~/.cursor/hooks.json)
└── hooks/               # scripts Node de los hooks (se enlaza a ~/.cursor/hooks)
    ├── guard-shell.js   # beforeShellExecution: bloquea/avisa comandos peligrosos
    ├── guard-secrets.js # beforeSubmitPrompt: avisa si el prompt tiene secretos
    └── verify-gate.js   # subagentStop: corre gates y reenvia a corregir si fallan
```

Skills relacionadas (en `../skills/`): `agent-orchestrator`, `verification-gates`,
`adversarial-reviewer`, `prompt-library`.

Gate CLI (en `../tools/bin/`): `verify` (Node), con wrapper `verify.ps1` para Windows.

## Como funciona el loop

1. La regla `harness.mdc` le dice al agente: descomponer tareas grandes en
   subagentes y correr `verify` antes de dar algo por hecho.
2. Al terminar un subagente, el hook `subagentStop` corre `verify --quick` en el
   proyecto. Si falla, devuelve un `followup_message` y el subagente corrige
   (hasta `loop_limit` veces).
3. `guard-shell` bloquea comandos catastroficos (borrados en raiz, format, force
   push) y pide confirmacion para los riesgosos.
4. `guard-secrets` avisa si un prompt parece traer una API key o clave privada.

## Requisitos

- **Node.js** en el PATH (los hooks y `verify` son scripts Node). Verifica con `node --version`.
- Los hooks son **fail-open**: si algo falla en el hook, la accion se permite (no te bloquean el trabajo).

## Gates de `verify`

`verify` detecta `package.json` en el directorio actual y corre, si existen, los
scripts `lint`, `typecheck`/`type-check`, `test` y `build`. Con `--quick` corre
solo `lint` + `typecheck`. Si no hay `package.json` o no hay scripts de gate, no
hace nada y sale con exito (no rompe proyectos sin esa config).

Para otros stacks (Python, Go, etc.), extiende `tools/bin/verify` agregando la
deteccion y comandos correspondientes.

## Probar los hooks manualmente

```bash
echo '{"command":"rm -rf /"}' | node hooks/guard-shell.js     # -> deny (exit 2)
echo '{"command":"ls -la"}'   | node hooks/guard-shell.js     # -> allow
echo '{"prompt":"sk-xxxxxxxxxxxxxxxxxxxxxxxx"}' | node hooks/guard-secrets.js  # -> ask
```

Tras instalar, revisa la pestana **Hooks** de Cursor (o el canal de salida
**Hooks**) para confirmar que cargan y disparan.

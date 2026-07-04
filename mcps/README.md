# MCPs

Este `mcp.json` es la configuracion global de servidores MCP de Cursor.

El instalador enlaza este archivo a `~/.cursor/mcp.json`, de modo que al hacer
`git pull` en cualquier estacion tus MCPs quedan disponibles.

## Como funciona

- Si ya existe un `~/.cursor/mcp.json`, el instalador hace un **backup**
  (`mcp.json.backup.<fecha>`) antes de enlazar.
- Al estar enlazado, si agregas o editas servidores desde la UI de Cursor los
  cambios se guardan aqui y puedes commitearlos.
- Tras editar este archivo, **reinicia Cursor** para recargar los servidores.

## Servidores incluidos

| Servidor | Que hace | Requiere |
|---|---|---|
| `context7` | Docs actualizadas de librerias | nada |
| `playwright` | Automatizacion de navegador (testing web) | nada |
| `sequential-thinking` | Razonamiento paso a paso | nada |
| `memory` | Memoria persistente entre sesiones | nada |
| `filesystem` | Acceso a archivos (scope: `${userHome}`) | ver nota |
| `github` | Issues / PRs / repos (servidor remoto) | `GITHUB_TOKEN` |

Los que usan `npx` descargan el paquete la primera vez (necesitas **Node.js**).

## Secretos: nunca en el repo

`mcp.json` esta versionado, asi que **no** pongas tokens en texto plano. Cursor
resuelve `${env:VAR}` al arrancar, por eso el token de GitHub se referencia asi:

```json
"headers": { "Authorization": "Bearer ${env:GITHUB_TOKEN}" }
```

### Configurar el token de GitHub

1. Crea un Personal Access Token (fine-grained recomendado):
   https://github.com/settings/personal-access-tokens/new
2. Guardalo como variable de entorno de usuario (PowerShell):

   ```powershell
   [Environment]::SetEnvironmentVariable('GITHUB_TOKEN', 'TU_TOKEN', 'User')
   ```

   En macOS/Linux, exportalo en tu `~/.zshrc` o `~/.bashrc`:

   ```bash
   export GITHUB_TOKEN="TU_TOKEN"
   ```
3. **Reinicia Cursor** para que tome la variable.

> Nota: `${env:...}` se resuelve en el IDE. En la CLI de `cursor-agent` usa
> `${GITHUB_TOKEN}` (sin el prefijo `env:`).

## Notas

- **filesystem** usa `${env:USERPROFILE}` (tu carpeta de usuario en Windows).
  Asi es portable entre PCs Windows sin hardcodear rutas: cada maquina resuelve
  su propio usuario. Evita `${userHome}`: en Windows resuelve con la unidad en
  minuscula (`c:\...`) y el server la concatena mal (`C:\c:\Users\...`).
  - En macOS/Linux cambia ese arg por `${env:HOME}`.
  - Para acotar el acceso, pon una ruta concreta o define tu propia variable
    (p. ej. `${env:MCP_FS_ROOT}` y setea esa var en cada maquina).
- **Windows + npx**: si algun servidor `npx` no conecta en Cursor, envuelve el
  comando con `cmd`: `"command": "cmd"`, `"args": ["/c", "npx", "-y", "..."]`.
  (Rompe la portabilidad a macOS/Linux, usalo solo si hace falta.)
- El `.gitignore` ya ignora `.env`, `*.local.json` y `secrets/`.

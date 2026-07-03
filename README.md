# agent-workstation

Repo portable de **skills**, **MCPs**, **tools** y un **harness agentico** para
Cursor, instalable en cualquier estacion de trabajo (Windows, macOS o Linux) con
un solo comando.

La instalacion usa **enlaces simbolicos** hacia `~/.cursor`, asi que para
actualizar todas tus maquinas basta con `git pull`.

## Estructura

```
agent-workstation/
├── skills/              # Cursor Agent Skills (una carpeta con SKILL.md por skill)
│   └── example-skill/
├── mcps/                # Configuracion de servidores MCP (mcp.json)
├── tools/               # Utilidades CLI reutilizables
│   └── bin/             # <- esta carpeta se agrega al PATH (incluye `verify`)
├── harness/             # Entorno agentico: reglas + hooks (ver harness/README.md)
│   ├── rules/           # convenciones (Definition of Done, subagentes, seguridad)
│   └── hooks/           # hooks Node (guard-shell, guard-secrets, verify-gate)
├── install.sh / .ps1    # Instalador (crea enlaces + PATH)
└── uninstall.sh / .ps1  # Desinstalador
```

## Instalacion

Clona el repo donde quieras que viva de forma permanente (no lo borres despues,
porque los enlaces apuntan aqui):

```bash
git clone git@github.com:jorgemezapaz/agent-workstation.git
cd agent-workstation
```

### macOS / Linux

```bash
bash install.sh
```

### Windows (PowerShell)

```powershell
# Si es la primera vez, permite ejecutar scripts en esta sesion:
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
./install.ps1
```

Reinicia Cursor y la terminal al terminar.

## Que hace el instalador

| Componente | Accion |
|------------|--------|
| Skills | Enlaza cada carpeta de `skills/` en `~/.cursor/skills/` |
| MCP | Enlaza `mcps/mcp.json` a `~/.cursor/mcp.json` (respalda el existente) |
| Rules | Enlaza `harness/rules/*.mdc` en `~/.cursor/rules/` |
| Hooks | Enlaza `harness/hooks.json` y `harness/hooks/` a `~/.cursor/` (respalda lo existente) |
| Tools | Agrega `tools/bin/` a tu `PATH` |

> El harness (reglas + hooks) requiere **Node.js** en el PATH. Ver `harness/README.md`.

## Uso diario

- **Actualizar una maquina:** `git pull` (los enlaces ya apuntan al repo, no hay
  que reinstalar salvo que agregues una skill nueva en Windows).
- **Agregar una skill:** `new-skill mi-skill` (o copia `skills/example-skill/`).
- **Agregar una tool:** crea el script en `tools/bin/` (version Unix sin
  extension + version `.ps1` para Windows). Ver `tools/README.md`.
- **Agregar un MCP:** edita `mcps/mcp.json`. Ver `mcps/README.md`.

## Notas por plataforma

- **Windows:** las carpetas (skills) se enlazan con *junctions*, que **no**
  requieren permisos de administrador. Para `mcp.json` se intenta symlink,
  luego hardlink y, si nada funciona, se copia.
- **macOS / Linux:** todo se enlaza con `ln -s`.
- Si agregas skills nuevas, vuelve a ejecutar el instalador en Windows para
  crear el nuevo enlace (en Unix el `git pull` suele bastar, pero re-ejecutar
  no hace dano).

## Seguridad

No subas credenciales. El `.gitignore` ya ignora `.env`, `*.local.json` y
`secrets/`. Revisa `mcps/README.md` para el manejo de API keys.

## Desinstalar

```bash
bash uninstall.sh        # macOS / Linux
./uninstall.ps1          # Windows
```

Solo elimina enlaces y la entrada de PATH; tus archivos del repo y los backups
de `mcp.json` quedan intactos.

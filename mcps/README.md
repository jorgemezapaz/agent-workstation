# MCPs

Este `mcp.json` es la configuracion global de servidores MCP de Cursor.

El instalador enlaza (symlink) este archivo a `~/.cursor/mcp.json`, de modo que
al hacer `git pull` en cualquier estacion tus MCPs quedan disponibles.

## Como funciona

- Si ya existe un `~/.cursor/mcp.json`, el instalador hace un **backup**
  (`mcp.json.backup.<fecha>`) antes de enlazar. Revisa ese backup y copia a este
  archivo los servidores que quieras conservar.
- Al ser un symlink, si agregas o editas servidores desde la UI de Cursor los
  cambios se guardan aqui y puedes commitearlos.

## Formato

```json
{
  "mcpServers": {
    "nombre-servidor": {
      "command": "npx",
      "args": ["-y", "@paquete/servidor", "argumentos"],
      "env": { "API_KEY": "..." }
    }
  }
}
```

## Importante: secretos

**No** subas API keys ni tokens a git. Opciones:

- Usa variables de entorno del sistema y referencialas.
- Manten los valores sensibles fuera del repo (el `.gitignore` ya ignora
  `.env`, `*.local.json` y `secrets/`).

El servidor `example-filesystem` es solo una plantilla: editalo o borralo.

# Tools

Scripts y utilidades CLI reutilizables. Todo lo que pongas en `tools/bin/` queda
disponible en tu terminal porque el instalador agrega esa carpeta al `PATH`.

Como se agrega al `PATH` (no se copian los scripts uno por uno), basta con hacer
`git pull` para tener nuevas tools sin reinstalar.

## Convencion multiplataforma

Para que una tool funcione en Windows, macOS y Linux, incluye:

- Una version **Unix** sin extension (shebang `#!/usr/bin/env bash` o
  `#!/usr/bin/env python3`), con permisos de ejecucion.
- Una version **Windows** con extension `.ps1` (o `.cmd`) con el mismo nombre.

Ejemplo: `hello` (Unix) + `hello.ps1` (Windows) se invocan ambos como `hello`.

Si el script es de Python puro, un solo archivo `mi-tool.py` puede servir en
todos lados (invocandolo como `python mi-tool.py` o via wrappers).

## Tools incluidas

- `hello` / `hello.ps1`: ejemplo minimo para verificar que el PATH funciona.
- `new-skill` / `new-skill.ps1`: crea el esqueleto de una nueva skill en
  `skills/<nombre>/SKILL.md`.

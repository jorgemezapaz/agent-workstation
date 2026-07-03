---
name: verification-gates
description: Define y exige gates ejecutables (lint, typecheck, tests, build, seguridad) antes de dar una tarea por terminada. Usar al finalizar una tarea, preparar un commit/PR, o cuando se pida verificar cambios.
---

# Verification Gates

Nunca declares el trabajo hecho por auto-certificacion. Corre los gates.

## Como correr

- `verify` — corre los gates disponibles en el proyecto actual (lint, typecheck, tests, build).
- `verify --quick` — solo lint + typecheck (loop rapido mientras trabajas).

## Definition of done

```
- [ ] Lint pasa
- [ ] Tipos pasan
- [ ] Tests pasan (codigo nuevo/cambiado cubierto)
- [ ] Build compila
- [ ] Sin secretos commiteados; least-privilege respetado
```

Si un gate no existe en el proyecto, dilo explicitamente en vez de saltarlo en silencio.

## Al fallar

Lee la salida del gate que fallo, corrige y vuelve a correr `verify`. Solo avanza cuando este en verde.

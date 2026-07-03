---
name: prompt-library
description: Plantillas de prompts reutilizables para tareas recurrentes (bug fix, refactor, code review, generacion de tests, descripcion de PR). Usar al iniciar una de estas tareas cuando un prompt estandar de alta calidad ayude.
---

# Prompt Library

Copia una plantilla y rellena los corchetes.

## Bug fix

```
Corrige: <sintoma>. Repro: <pasos / test que falla>.
Restricciones: cambio minimo, agrega test de regresion, corre `verify`.
```

## Refactor

```
Refactoriza <objetivo> para <meta: legibilidad/rendimiento/desacoplamiento>.
Sin cambio de comportamiento. Manten los tests en verde (`verify`). Pasos pequenos y revisables.
```

## Generacion de tests

```
Escribe tests para <unidad>. Cubre happy path + casos borde + modos de fallo.
Usa <framework>. Asegura que corran bajo `verify`.
```

## Code review

```
Revisa <diff/PR> por correccion, seguridad y mantenibilidad.
Salida: Critico / Sugerencia / Nice-to-have, con referencias archivo:linea.
```

## Descripcion de PR

```
Resume esta rama vs <base>. Secciones: Resumen (por que), Cambios (que), Plan de pruebas.
```

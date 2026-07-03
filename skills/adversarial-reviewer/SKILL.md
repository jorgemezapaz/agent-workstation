---
name: adversarial-reviewer
description: Evalua el resultado de un agente o subagente contra una rubrica explicita y lo reenvia a corregir si falla. Usar al revisar la salida de un subagente o cuando la correccion importa (antes de mergear o de terminar trabajo riesgoso).
---

# Adversarial Reviewer

Evalua la salida en un pase separado, contra una rubrica. Se estricto.

## Rubrica (por defecto)

```
- [ ] Cumple los requisitos declarados
- [ ] Todos los tests pasan; el nuevo comportamiento esta testeado
- [ ] Sin TODOs/placeholders/codigo muerto nuevos
- [ ] Sin cambios de API/contrato publico salvo que se pidieran
- [ ] Sin regresiones de seguridad ni de politicas de datos
```

Agrega criterios especificos de la tarea segun haga falta.

## Proceso

1. Reformula que significa "bueno" para esta tarea (la rubrica).
2. Verifica el resultado contra cada item; cita evidencia concreta.
3. Veredicto: PASS o FAIL con feedback especifico y accionable.
4. Si es FAIL: devuelvelo al autor (o subagente) para corregir y vuelve a revisar. Tope de 2-3 iteraciones.

## Formato de salida

```
Veredicto: PASS | FAIL
Hallazgos:
- <criterio>: <pass/fail> — <evidencia>
Correcciones requeridas (si FAIL):
- <item accionable>
```

---
name: agent-orchestrator
description: Descompone tareas grandes o paralelizables en subagentes con alcance acotado y los coordina (plan, fan-out, recolectar, verificar). Usar cuando una tarea abarca muchos archivos/areas, se puede paralelizar, o es demasiado grande para un solo pase lineal.
---

# Agent Orchestrator

El agente lider actua como planificador e integrador; delega el trabajo pesado a subagentes.

## Cuando hacer fan-out

- La tarea toca varios archivos/modulos independientes, o tiene subtareas separables.
- Un paso se beneficia del aislamiento (contexto propio): investigacion, migraciones, cambios por paquete.

No lo uses para tareas pequenas o lineales; en ese caso hazlo directo.

## Flujo

1. **Plan**: divide el objetivo en subtareas independientes y bien acotadas. Define entradas y salidas de cada una.
2. **Alcance**: cada subagente tiene UNA responsabilidad y los archivos/carpetas que puede tocar. Los cambios fuera de alcance se rechazan.
3. **Fan-out**: lanza subagentes (en paralelo si son independientes; en secuencia si hay dependencias).
4. **Recolectar**: reune resultados; en el contexto del lider conserva solo conclusiones, no el detalle.
5. **Verificar**: corre los gates (`verify`) y, para salidas riesgosas, aplica la rubrica de `adversarial-reviewer`. Reenvia a corregir si falla.

## Costo y latencia

- Manten el anidamiento bajo (2-3 niveles).
- Usa modelos mas baratos para reconocimiento y mas potentes para sintesis.
- Prefiere salidas estructuradas para que sean parseables aguas abajo.

## Anti-patrones

- Lanzar subagentes para tareas triviales.
- Anidar profundo sin necesidad.
- Subagentes sin alcance que editan cualquier cosa.

# Plan de implementación — Pro Cycling Replay Manager V3

## Decisiones confirmadas
- **Motor:** Godot 4.7.2 (mono instalado), lógica en **GDScript**.
- **Persistencia:** **SQLite** vía plugin `godot-sqlite` (GDExtension, binarios precompilados Windows).
- **Colores:** generación determinista por equipo (editable en Team Editor).
- **Alcance:** build completo según PRD (todos los módulos), en orden de dependencias.

## 1. Pipeline de datos (una sola vez, Python 3.13)
Script `tools/import_data.py` que:
- Lee `Equipos_2026.xlsx` y `Ciclistas_2026_1.xlsx` con `openpyxl`.
- **Vincula por nombre normalizado** (colapsa espacios/tildes) porque los `TeamID` no coinciden entre archivos.
- **Normaliza inconsistencias:** 12 equipos con corredores ausentes en Equipos se insertan igual (p. ej. L39ION, KSPO, Pardus, Crown-Tabriz); corrige `MBH Bank - CSB -  Telecom Fort` (doble espacio); conserva los 3 equipos sin corredores (Pinarello, Pauwels, MBH).
- Genera **colores principal/secundario deterministas** por equipo (hash del nombre → paleta HSL con contraste sobre fondo oscuro).
- Escribe `data/seed.db` con `sqlite3` (stdlib) en UTF-8 correcto.
- Resultado: ~220 equipos, 3.320 corredores, 14 atributos (50–84).

## 2. Esquema SQLite
- `teams(id, name, abbr, country, category, color_primary, color_secondary, extra)`
- `riders(id, name, birth_date, nationality, team_id, specialty, fla, mnt, mm, hil, ttr, prl, cob, spr, acc, dhi, att, sta, res, rec)`
- `stages(id, name, date, type, distance, start, finish, description, sections_json, modifiers_json, locked)`
- `races(id, name, edition, country, description, start_date, end_date, logo, stage_order_json)`
- `simulations(id, date, seed, mode, ref_id, results_json, classifications_json, events_json, decisions_json)`
- `settings(key, value)`

El `seed.db` vive en `res://data/`; en el primer arranque se copia a `user://` para lectura-escritura (patrón recomendado por el plugin).

## 3. Estructura del proyecto Godot
- **`core/`** (Simulation Core, GDScript puro, cero UI): `rng.gd` (PRNG SplitMix64 seedeable/reproducible), `rider.gd`, `team.gd`, `stage.gd`, `race.gd`, `group.gd`, `race_state.gd`, `fatigue.gd`, `classifications.gd`, `event_log.gd`, `decision_engine.gd`, `ai_team.gd`, `stage_resolver.gd`.
- **`data/`**: `db.gd` (singleton godot-sqlite), repositorios (`team_repo`, `rider_repo`, `stage_repo`, `race_repo`, `history_repo`), migraciones, import/export JSON-CSV.
- **`autoload/`**: `DataStore`, `GameState`, `SignalBus`, `Config`.
- **`ui/`** (escenas `.tscn` + scripts): menú, bibliotecas, editores, race view, paneles.
- **`themes/`**: `theme.tres` con paleta oscura PRD §26.

## 4. Motor de simulación (corazón del juego)
Secuencia PRD §34: etapa → secciones → situación → decisiones → RNG → rendimiento → fatiga → tiempo → clasificación.
- **Fatiga/recuperación:** STA (aguante) amortigua acumulación, RES (resistencia) degradación en etapas largas, REC (recuperación) recuperación entre secciones/etapas. Fatiga dinámica, atributos permanentes.
- **Rendimiento:** `atributo(terreno) + modificadores − penalización_fatiga + RNG`.
- **Grupos:** pelotón + fugas con gaps de tiempo; sprints intermedios, puntos de montaña, incidentes, viento cruzado/pavés (fragmentación), sprint final y final en alto.
- **Tipos de etapa:** Flat, Flat-Hilly, Medium Mountain, Mountain, ITT, TTT, Crosswind, Cobbles, Prólogo — todos usando los 14 atributos.
- **RNG reproducible:** PRNG propio (no el global) para que una seed dé el mismo resultado.
- **Mismo motor para jugador e IA.**

## 5. UI (rediseño completo, "broadcast + dashboard")
- **Menú principal** (Correr / Crear / Editar / Histórico / Configuración).
- **Bibliotecas** de etapas y carreras en tarjetas con perfil de altitud dibujado, filtros y búsqueda (§30), duplicar/eliminar.
- **Stage Editor** visual (secciones por km, terreno, pendiente, categoría, elementos especiales; modo Básico/Avanzado).
- **Race Editor** con drag & drop de etapas (crear/importar/duplicar).
- **Team/Rider Editors** (roles, colores, ficha con 14 atributos agrupados).
- **Participant Manager** (selección de equipos/corredores, roles).
- **Configuración de partida** (espectador/controlar equipo, velocidad, dados, seed).
- **Race View** (§18–24): barra superior, zona central (perfil interactivo + grupos visuales), panel táctico derecho, Race Feed visual, dados estilizados, Decision Panel, ficha de corredor.
- **Histórico**: simulaciones guardadas, consulta de resultados/clasificaciones.

## 6. IA
Objetivos de equipo (líder GC, sprinter, cazador de fugas), decisiones contextuales usando atributos/fatiga/posición/clasificación/terreno/importancia de etapa.

## 7. Guardado / import-export
Guardar etapa o carrera (con estado entre etapas), historial de simulaciones, import/export JSON y CSV.

## Orden de implementación (hitos verificables)
1. Instalar `godot-sqlite`, `project.godot`, autoloads, tema base.
2. Script de importación → `seed.db`.
3. Data Layer (repos + migraciones) y carga de datos.
4. Simulation Core completo (RNG, fatiga, tipos de etapa, clasificaciones) — **verificable sin UI**.
5. Menú + bibliotecas + ficha de corredor.
6. Editores (Stage/Race/Team/Rider).
7. Race View + participantes + config de partida.
8. IA + modo espectador + control de equipo.
9. Histórico + guardado + import/export.
10. Pulido (animaciones, sonido básico, transiciones, accesibilidad).

## Notas / riesgos
- Necesito descargar el addon `godot-sqlite` (binarios Windows) de su página de Releases durante el paso 1.
- La magnitud es grande: procederé por los hitos de arriba, manteniendo siempre una app ejecutable tras cada hito.
- No existe proyecto Godot previo en `C:\Proyectos\SimTour` (solo los 3 archivos), así que parto de cero.

## Repositorio
- URL: https://github.com/fpons73/TourSim.git
- Commit + push al finalizar cada hito.

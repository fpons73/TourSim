# ToDo — Pro Cycling Replay Manager V3

## Estado de hitos

- [x] Hito 0 — Setup: plan.md + TODO.md + init git + remote + primer push
- [x] Hito 1 — Instalar godot-sqlite, project.godot, autoloads, tema base
- [x] Hito 2 — Script de importación xlsx → seed.db (Python)
- [x] Hito 3 — Data Layer (repos + migraciones) y carga de datos
- [x] Hito 4 — Simulation Core (RNG, fatiga, tipos de etapa, clasificaciones)
- [x] Hito 5 — Menú + bibliotecas + ficha de corredor
- [x] Hito 6 — Editores (Stage/Race/Team/Rider)
- [x] Hito 7 — Race View + participantes + config de partida
- [x] Hito 8 — IA + modo espectador + control de equipo
- [x] Hito 9 — Histórico + guardado + import/export
- [ ] Hito 10 — Pulido (animaciones, sonido, transiciones, accesibilidad)

## Detalle por hito

### Hito 0 — Setup
- [x] Guardar plan.md
- [x] Guardar TODO.md
- [x] git init + remote origin
- [x] Primer commit + push

### Hito 1 — Base Godot
- [x] Descargar addon godot-sqlite (binarios Windows)
- [x] project.godot + estructura de carpetas
- [x] Autoloads: DataStore, GameState, SignalBus, Config
- [x] Theme.tres (paleta oscura PRD §26)

### Hito 2 — Importación de datos
- [x] tools/import_data.py
- [x] Normalización de equipos y corredores
- [x] Colores deterministas
- [x] Generar data/seed.db

### Hito 3 — Data Layer
- [x] db.gd (singleton godot-sqlite)
- [x] Repositorios: team, rider, stage, race, history
- [x] Migraciones de esquema
- [x] Copia seed.db → user:// en primer arranque
- [x] Import/export JSON-CSV

### Hito 4 — Simulation Core
- [x] rng.gd (PRNG determinista xorshift32 reproducible)
- [x] Modelos: rider, team, stage, race, group
- [x] Fatigue (STA/RES/REC)
- [x] Clasificaciones (GC, puntos, montaña, jóvenes, equipos)
- [x] EventLog
- [x] Resolver de etapa (9 tipos: flat, flat_hilly, mountain, medium_mountain, itt, ttt, crosswind, cobbles, prologue)

### Hito 5 — Menú y bibliotecas
- [x] Menú principal
- [x] Biblioteca de etapas (tarjetas + perfil)
- [x] Biblioteca de carreras
- [x] Ficha de corredor (14 atributos agrupados)
- [x] Filtros y búsqueda (corredores)
- [x] Biblioteca y detalle de equipos

### Hito 6 — Editores
- [x] Stage Editor (perfil visual, básico/avanzado)
- [x] Race Editor (reordenar etapas)
- [x] Team Editor (roles, colores)
- [x] Rider Editor

### Hito 7 — Race View
- [x] Participantes (equipos/corredores)
- [x] Config de partida (espectador/control, velocidad, dados, seed)
- [x] Race View: barra superior, perfil con marcador, grupos visuales
- [ ] Panel táctico derecho (→ hito 8)
- [x] Race Feed visual
- [ ] Dados estilizados (→ hito 10)
- [ ] Decision Panel (→ hito 8)

### Hito 8 — IA
- [x] Objetivos de equipo (TeamAI)
- [x] AI táctica contextual (fuga/split/caza)
- [x] Modo espectador
- [x] Control de un equipo (Decision Panel + panel táctico)

### Hito 9 — Histórico
- [x] Guardar etapa/carrera (fatiga entre etapas + historial)
- [x] Historial de simulaciones (ver/eliminar)
- [x] Consulta de resultados/clasificaciones
- [x] Import/export JSON-CSV (pantalla de datos)

### Hito 10 — Pulido
- [ ] Animaciones
- [ ] Sonido básico
- [ ] Transiciones
- [ ] Accesibilidad
- [ ] Optimización

## Repositorio
- URL: https://github.com/fpons73/TourSim.git
- Commit + push al finalizar cada hito.

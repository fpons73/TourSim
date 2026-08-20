# ToDo — Pro Cycling Replay Manager V3

## Estado de hitos

- [ ] Hito 0 — Setup: plan.md + TODO.md + init git + remote + primer push
- [ ] Hito 1 — Instalar godot-sqlite, project.godot, autoloads, tema base
- [ ] Hito 2 — Script de importación xlsx → seed.db (Python)
- [ ] Hito 3 — Data Layer (repos + migraciones) y carga de datos
- [ ] Hito 4 — Simulation Core (RNG, fatiga, tipos de etapa, clasificaciones)
- [ ] Hito 5 — Menú + bibliotecas + ficha de corredor
- [ ] Hito 6 — Editores (Stage/Race/Team/Rider)
- [ ] Hito 7 — Race View + participantes + config de partida
- [ ] Hito 8 — IA + modo espectador + control de equipo
- [ ] Hito 9 — Histórico + guardado + import/export
- [ ] Hito 10 — Pulido (animaciones, sonido, transiciones, accesibilidad)

## Detalle por hito

### Hito 0 — Setup
- [x] Guardar plan.md
- [x] Guardar TODO.md
- [ ] git init + remote origin
- [ ] Primer commit + push

### Hito 1 — Base Godot
- [ ] Descargar addon godot-sqlite (binarios Windows)
- [ ] project.godot + estructura de carpetas
- [ ] Autoloads: DataStore, GameState, SignalBus, Config
- [ ] Theme.tres (paleta oscura PRD §26)

### Hito 2 — Importación de datos
- [ ] tools/import_data.py
- [ ] Normalización de equipos y corredores
- [ ] Colores deterministas
- [ ] Generar data/seed.db

### Hito 3 — Data Layer
- [ ] db.gd (singleton godot-sqlite)
- [ ] Repositorios: team, rider, stage, race, history
- [ ] Migraciones de esquema
- [ ] Copia seed.db → user:// en primer arranque
- [ ] Import/export JSON-CSV

### Hito 4 — Simulation Core
- [ ] rng.gd (SplitMix64 reproducible)
- [ ] Modelos: rider, team, stage, race, group
- [ ] Fatigue (STA/RES/REC)
- [ ] Clasificaciones (GC, puntos, montaña, jóvenes, equipos)
- [ ] EventLog
- [ ] stage_resolver.gd (9 tipos de etapa)

### Hito 5 — Menú y bibliotecas
- [ ] Menú principal
- [ ] Biblioteca de etapas (tarjetas + perfil)
- [ ] Biblioteca de carreras
- [ ] Ficha de corredor (14 atributos agrupados)
- [ ] Filtros y búsqueda

### Hito 6 — Editores
- [ ] Stage Editor (perfil visual, básico/avanzado)
- [ ] Race Editor (drag & drop)
- [ ] Team Editor (roles, colores)
- [ ] Rider Editor

### Hito 7 — Race View
- [ ] Participantes (equipos/corredores/roles)
- [ ] Config de partida (espectador/control, velocidad, dados, seed)
- [ ] Race View: barra superior, perfil interactivo, grupos visuales
- [ ] Panel táctico derecho
- [ ] Race Feed visual
- [ ] Dados estilizados
- [ ] Decision Panel

### Hito 8 — IA
- [ ] Objetivos de equipo
- [ ] AI táctica contextual
- [ ] Modo espectador
- [ ] Control de un equipo

### Hito 9 — Histórico
- [ ] Guardar etapa/carrera (estado entre etapas)
- [ ] Historial de simulaciones
- [ ] Consulta de resultados/clasificaciones

### Hito 10 — Pulido
- [ ] Animaciones
- [ ] Sonido básico
- [ ] Transiciones
- [ ] Accesibilidad
- [ ] Optimización

## Repositorio
- URL: https://github.com/fpons73/TourSim.git
- Commit + push al finalizar cada hito.

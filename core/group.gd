class_name Group
extends RefCounted
## Un grupo en carrera (pelotón, fuga, grupo perseguidor...).

var id: int = -1
var name: String = ""
var riders: Array = []          # de Rider
var gap: float = 0.0            # segundos respecto al líder de carrera
var speed: float = 40.0         # km/h (para visualización)
var time: float = 0.0           # segundos acumulados del grupo
var leader_id: int = -1         # corredor cabeza del grupo (referencia de tiempo)

func rider_count() -> int:
	return riders.size()

func average_fatigue() -> float:
	if riders.is_empty():
		return 0.0
	var s := 0.0
	for r in riders:
		s += r.fatigue
	return s / riders.size()

func average_attr(key: String) -> float:
	if riders.is_empty():
		return 50.0
	var s := 0.0
	for r in riders:
		s += r.attr(key)
	return s / riders.size()

func contains_team(team_id: int) -> bool:
	for r in riders:
		if r.team_id == team_id:
			return true
	return false

func team_colors() -> Array:
	var seen := {}
	var out: Array = []
	for r in riders:
		if not seen.has(r.team_id):
			seen[r.team_id] = true
			out.append({"team_id": r.team_id, "color": r.team_color, "abbr": r.team_abbr})
	return out

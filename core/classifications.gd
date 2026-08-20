class_name Classifications
extends RefCounted
## Clasificaciones de una etapa/carrera.

var times: Dictionary = {}       # rider_id -> segundos totales
var points: Dictionary = {}      # rider_id -> puntos (sprint)
var mountain: Dictionary = {}    # rider_id -> puntos de montaña
var stage_results: Array = []    # orden de llegada de la última etapa (ids)

const MOUNTAIN_POINTS := {"4": 1, "3": 2, "2": 5, "1": 10, "HC": 20}
const SPRINT_POINTS := [20, 17, 15, 13, 11, 10, 9, 8, 7, 6, 5, 4, 3, 2, 1]

func add_time(rider_id: int, seconds: float) -> void:
	times[rider_id] = float(times.get(rider_id, 0.0)) + seconds

func get_time(rider_id: int) -> float:
	return float(times.get(rider_id, 0.0))

func add_points(rider_id: int, pts: int) -> void:
	points[rider_id] = int(points.get(rider_id, 0)) + pts

func add_mountain(rider_id: int, pts: int) -> void:
	mountain[rider_id] = int(mountain.get(rider_id, 0)) + pts

## Clasificación general ordenada (id, tiempo, diferencia con el líder).
func gc_ranking(riders: Dictionary) -> Array:
	var list: Array = []
	for rid in times.keys():
		var r: Rider = riders.get(int(rid))
		if r == null:
			continue
		list.append({"id": int(rid), "time": times[rid],
			"name": r.name, "team_id": r.team_id, "team_abbr": r.team_abbr,
			"team_color": r.team_color})
	list.sort_custom(func(a, b): return a["time"] < b["time"])
	var leader: float = list[0]["time"] if not list.is_empty() else 0.0
	for i in list.size():
		list[i]["gap"] = list[i]["time"] - leader
		list[i]["pos"] = i + 1
	return list

## Clasificación de la regularidad (puntos de sprint).
func points_ranking(riders: Dictionary) -> Array:
	var list: Array = []
	for rid in points.keys():
		var r: Rider = riders.get(int(rid))
		if r == null:
			continue
		list.append({"id": int(rid), "points": points[rid],
			"name": r.name, "team_id": r.team_id, "team_abbr": r.team_abbr,
			"team_color": r.team_color})
	list.sort_custom(func(a, b): return a["points"] > b["points"])
	for i in list.size():
		list[i]["pos"] = i + 1
	return list

## Clasificación de la montaña.
func mountain_ranking(riders: Dictionary) -> Array:
	var list: Array = []
	for rid in mountain.keys():
		var r: Rider = riders.get(int(rid))
		if r == null:
			continue
		list.append({"id": int(rid), "points": mountain[rid],
			"name": r.name, "team_id": r.team_id, "team_abbr": r.team_abbr,
			"team_color": r.team_color})
	list.sort_custom(func(a, b): return a["points"] > b["points"])
	for i in list.size():
		list[i]["pos"] = i + 1
	return list

## Clasificación de jóvenes (edad < 26).
func young_ranking(riders: Dictionary, ref_year: int = 2026) -> Array:
	var list: Array = []
	for rid in times.keys():
		var r: Rider = riders.get(int(rid))
		if r == null or r.age(ref_year) >= 26:
			continue
		list.append({"id": int(rid), "time": times[rid],
			"name": r.name, "age": r.age(ref_year), "team_id": r.team_id})
	list.sort_custom(func(a, b): return a["time"] < b["time"])
	for i in list.size():
		list[i]["pos"] = i + 1
	return list

## Clasificación por equipos (suma de los 3 mejores tiempos del equipo).
func team_ranking(riders: Dictionary, teams: Dictionary) -> Array:
	var team_times := {}   # team_id -> array de tiempos
	for rid in times.keys():
		var r: Rider = riders.get(int(rid))
		if r == null or r.finished == false:
			continue
		if not team_times.has(r.team_id):
			team_times[r.team_id] = []
		team_times[r.team_id].append(times[rid])
	var list: Array = []
	for tid in team_times.keys():
		var tarr: Array = team_times[tid]
		tarr.sort()
		var best := tarr.slice(0, mini(3, tarr.size()))
		var total := 0.0
		for v in best:
			total += v
		var t: Team = teams.get(int(tid))
		list.append({"id": int(tid), "time": total,
			"name": t.name if t != null else "?", "abbr": t.abbr if t != null else "?"})
	list.sort_custom(func(a, b): return a["time"] < b["time"])
	for i in list.size():
		list[i]["pos"] = i + 1
	return list

func to_json(riders: Dictionary) -> String:
	return JSON.stringify({
		"gc": gc_ranking(riders),
		"points": points_ranking(riders),
		"mountain": mountain_ranking(riders),
		"young": young_ranking(riders),
	})

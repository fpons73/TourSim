class_name RaceSim
extends RefCounted
## Helpers para ejecutar simulaciones (etapa o carrera) sobre el Simulation Core.

static func run_stage(stage_row: Dictionary, seed: int) -> Dictionary:
	var stage := Stage.from_row(stage_row)
	var st := RaceState.new()
	st.setup(stage, RiderRepo.get_all(), TeamRepo.get_all(), seed)
	return st.resolve_to_end()

static func run_stage_full(stage: Stage, rider_rows: Array, team_rows: Array, seed: int) -> Dictionary:
	var st := RaceState.new()
	st.setup(stage, rider_rows, team_rows, seed)
	return st.resolve_to_end()

## Simula una carrera completa (suma de etapas) y devuelve la GC combinada.
static func run_race(race: Race, seed: int) -> Dictionary:
	var rider_rows := RiderRepo.get_all()
	var team_rows := TeamRepo.get_all()
	var stage_list := race.stages()
	var gc_times := {}         # rider_id -> segundos
	var total_points := {}     # rider_id -> puntos
	var total_mountain := {}
	var stages_results: Array = []
	var stage_winners: Array = []

	for i in stage_list.size():
		var st := RaceState.new()
		st.setup(stage_list[i], rider_rows, team_rows, seed + i * 1000)
		var res := st.resolve_to_end()
		stages_results.append(res)
		stage_winners.append({"stage": stage_list[i].name, "winner": res.get("winner_name", "")})
		for e in res["gc"]:
			gc_times[e["id"]] = float(gc_times.get(e["id"], 0.0)) + float(e["time"])
		for e in res["points"]:
			total_points[e["id"]] = int(total_points.get(e["id"], 0)) + int(e["points"])
		for e in res["mountain"]:
			total_mountain[e["id"]] = int(total_mountain.get(e["id"], 0)) + int(e["points"])

	# GC final ordenada.
	var riders_lookup := {}
	for rr in rider_rows:
		riders_lookup[int(rr["id"])] = Rider.from_row(rr)
	var teams_lookup := {}
	for tr in team_rows:
		teams_lookup[int(tr["id"])] = Team.from_row(tr)

	var gc: Array = []
	for rid in gc_times.keys():
		var r: Rider = riders_lookup.get(int(rid))
		if r == null:
			continue
		gc.append({"id": int(rid), "time": gc_times[rid], "name": r.name,
			"team_id": r.team_id, "team_abbr": r.team_abbr, "team_color": r.team_color})
	gc.sort_custom(func(a, b): return a["time"] < b["time"])
	var leader: float = gc[0]["time"] if not gc.is_empty() else 0.0
	for i in gc.size():
		gc[i]["gap"] = gc[i]["time"] - leader
		gc[i]["pos"] = i + 1

	return {
		"race_name": race.name,
		"edition": race.edition,
		"gc": gc,
		"stage_winners": stage_winners,
		"stages": stages_results,
	}

class_name RaceState
extends RefCounted
## Estado en vivo de una etapa + motor de resolución (Simulation Core).

const BASE_SPEED := {
	"flat": 44.0, "hill": 32.0, "medium_mountain": 28.0, "mountain": 22.0,
	"descent": 56.0, "cobbles": 34.0, "crosswind": 40.0,
	"itt": 46.0, "ttt": 46.0, "prologue": 46.0,
}

const FATIGUE_RATE := 0.18
const REF_YEAR := 2026

var rng: RNG
var stage: Stage
var riders: Array = []               # de Rider
var riders_by_id: Dictionary = {}    # id -> Rider
var teams: Dictionary = {}           # id -> Team
var groups: Array = []               # de Group
var events: EventLog
var classifications: Classifications
var km: float = 0.0
var finished: bool = false
var stage_winner_id: int = -1
var player_team_id: int = -1
var pending_decision: Dictionary = {}
var decisions_log: Array = []
var _group_counter: int = 0

func setup(p_stage: Stage, rider_rows: Array, team_rows: Array, seed_value: int, p_player_team_id: int = -1) -> void:
	stage = p_stage
	rng = RNG.new(seed_value)
	player_team_id = p_player_team_id
	events = EventLog.new()
	classifications = Classifications.new()

	for tr in team_rows:
		var t := Team.from_row(tr)
		teams[t.id] = t

	for rr in rider_rows:
		var r := Rider.from_row(rr)
		var t: Team = teams.get(r.team_id)
		if t != null:
			r.team_abbr = t.abbr
			r.team_color = t.color_primary
			r.team_color2 = t.color_secondary
		r.group_id = -1
		riders.append(r)
		riders_by_id[r.id] = r

	# Pelotón inicial con todos los corredores.
	var peloton := _create_group("Pelotón")
	for r in riders:
		_assign_to_group(r, peloton)

	events.add(0.0, "info", "Salida", "Se da la salida de %s (%d km)." % [stage.name, int(stage.distance)],
		[])

func _create_group(gname: String) -> Group:
	var g := Group.new()
	g.id = _group_counter
	_group_counter += 1
	g.name = gname
	g.time = 0.0
	groups.append(g)
	return g

func _assign_to_group(r: Rider, g: Group) -> void:
	# Quitar de grupo anterior.
	if r.group_id >= 0:
		var old := _group_by_id(r.group_id)
		if old != null:
			old.riders.erase(r)
	r.group_id = g.id
	g.riders.append(r)

func _group_by_id(gid: int) -> Group:
	for g in groups:
		if g.id == gid:
			return g
	return null

# ------------------------------------------------------------------
# Resolución principal
# ------------------------------------------------------------------

var _section_index: int = 0

func resolve_to_end() -> Dictionary:
	while not finished:
		step()
	return get_results()

## Resuelve una sección (o finaliza) y devuelve una instantánea del estado.
func step() -> Dictionary:
	if finished:
		return snapshot()
	if not pending_decision.is_empty():
		return snapshot()
	if stage.type in ["itt", "ttt", "prologue"]:
		_resolve_time_trial()
		return snapshot()
	if _section_index < stage.sections.size():
		resolve_section(stage.sections[_section_index])
		_section_index += 1
	else:
		finish_stage()
	return snapshot()

## Instantánea del estado actual para la capa de presentación.
func snapshot() -> Dictionary:
	var gs: Array = []
	for g in groups:
		if g.riders.is_empty():
			continue
		var names: Array = []
		for r in g.riders.slice(0, 6):
			names.append({"name": r.name, "team_id": r.team_id, "abbr": r.team_abbr, "color": r.team_color})
		gs.append({
			"id": g.id, "name": g.name, "rider_count": g.rider_count(),
			"gap": g.gap, "speed": g.speed, "riders": names,
		})
	gs.sort_custom(func(a, b): return a["gap"] < b["gap"])
	return {
		"km": km,
		"finished": finished,
		"elapsed": _leader_time() if not groups.is_empty() else 0.0,
		"groups": gs,
		"events": events.get_all(),
		"event_count": events.count(),
		"decision": pending_decision,
		"player_riders": _player_riders_snapshot(),
	}

func _player_riders_snapshot() -> Array:
	var out: Array = []
	if player_team_id < 0:
		return out
	for r in riders:
		if r.team_id != player_team_id:
			continue
		var g := _group_by_id(r.group_id)
		out.append({
			"id": r.id, "name": r.name,
			"group": g.name if g != null else "-",
			"gap": r.gap, "fatigue": r.fatigue, "status": r.status,
		})
	out.sort_custom(func(a, b): return a["fatigue"] < b["fatigue"])
	return out

func resolve_section(sec: Dictionary) -> void:
	var a := float(sec.get("start_km", km))
	var b := float(sec.get("end_km", a))
	var terrain := str(sec.get("terrain", "flat"))
	var length := maxf(b - a, 0.1)
	km = b

	_handle_breakaway(sec, length)

	# Tiempo por grupo según rendimiento en el terreno.
	var lead_time := _advance_groups(terrain, length)

	_update_breakaway(sec, length)

	_apply_fatigue(terrain, length)
	if terrain in ["flat", "descent"]:
		_apply_recovery(length)

	# Eventos específicos de terreno.
	if terrain in Terrain.CLIMB_TERRAINS:
		_award_mountain(sec, terrain)
		_split_weak_riders(terrain, lead_time)
	elif terrain == "cobbles":
		_handle_incidents("cobbles", length)
		_split_weak_riders("cobbles", lead_time)
	elif terrain == "crosswind":
		_split_weak_riders("crosswind", lead_time)

	if sec.get("special", "") == "sprint":
		_award_sprint(sec)

	_update_gaps(lead_time)
	_maybe_generate_decision()

## Devuelve el tiempo (seg) del grupo líder tras avanzar esta sección.
func _advance_groups(terrain: String, length: float) -> float:
	var base := float(BASE_SPEED.get(terrain, 40.0))
	var tempo := float(stage.modifiers.get("tempo_modifier", 1.0))
	var best_perf := 0.0
	var perfs := {}
	for g in groups:
		var p := _group_perf(g, terrain)
		perfs[g.id] = p
		best_perf = maxf(best_perf, p)

	var min_time := INF
	for g in groups:
		var perf: float = perfs[g.id]
		var amp := 1.6 if terrain in Terrain.CLIMB_TERRAINS else 1.0
		var speed := base * (1.0 + (perf - 0.62) * 0.35 * amp) * tempo
		speed = maxf(speed, 8.0)
		g.speed = speed
		g.time += length / speed * 3600.0
		min_time = minf(min_time, g.time)
	return min_time

func _group_perf(g: Group, terrain: String) -> float:
	if g.riders.is_empty():
		return 0.0
	var s := 0.0
	for r in g.riders:
		s += r.performance(terrain)
	return s / g.riders.size()

func _update_gaps(lead_time: float) -> void:
	for g in groups:
		g.gap = maxf(g.time - lead_time, 0.0)
		for r in g.riders:
			r.gap = g.gap
			r.time = g.time

# ------------------------------------------------------------------
# Fuga (breakaway)
# ------------------------------------------------------------------

func _handle_breakaway(sec: Dictionary, length: float) -> void:
	if stage.type in ["itt", "ttt", "prologue"]:
		return
	if _has_breakaway():
		return
	var terrain := str(sec.get("terrain", "flat"))
	var progress := km / maxf(stage.distance, 1.0)
	# Más probable a mitad de etapa, menos al inicio/final.
	var p := 0.06
	if progress > 0.1 and progress < 0.75:
		p = 0.14
	if terrain in Terrain.CLIMB_TERRAINS:
		p *= 0.6
	if not rng.chance(p):
		return

	var peloton := _peloton()
	if peloton == null or peloton.riders.size() < 20:
		return

	# Elegir atacantes (alto ATT, fatiga moderada).
	var candidates: Array = []
	for r in peloton.riders:
		if r.status != "OK":
			continue
		candidates.append(r)
	if candidates.size() < 3:
		return

	var size := rng.rangei(2, mini(6, candidates.size() - 1))
	var attackers: Array = []
	var team_counts := {}
	var guard := 0
	while attackers.size() < size and guard < 200:
		guard += 1
		var weights: Array = []
		for r in candidates:
			var w: float = r.attr("att") * (1.0 - r.fatigue / 120.0)
			weights.append(maxf(w, 1.0))
		var idx := rng.pick_index(weights)
		var chosen: Rider = candidates[idx]
		if team_counts.get(chosen.team_id, 0) >= 2:
			continue
		attackers.append(chosen)
		team_counts[chosen.team_id] = team_counts.get(chosen.team_id, 0) + 1
		candidates.remove_at(idx)

	if attackers.size() < 2:
		return

	var fuga := _create_group("Fuga")
	for r in attackers:
		_assign_to_group(r, fuga)
	# La fuga parte con ventaja temporal sobre el pelotón.
	var initial_gap := 20.0 + rng.next_float() * 70.0
	fuga.time = peloton.time - initial_gap

	var names: Array = []
	for r in attackers:
		names.append(r.name)
	events.add(km, "breakaway", "FUGA", "%s forman la fuga (%s)." % [
		str(attackers.size()), ", ".join(names.slice(0, 3))],
		attacker_ids(attackers))

## Genera una decisión para el jugador si un rival está en fuga (PRD §14, §24).
func _maybe_generate_decision() -> void:
	if player_team_id < 0:
		return
	if not pending_decision.is_empty():
		return
	var fuga := _fuga_group()
	if fuga == null:
		return
	var attacker: Rider = null
	for r in fuga.riders:
		if r.team_id != player_team_id:
			attacker = r
			break
	if attacker == null:
		return
	var km_to_go := maxf(stage.distance - km, 0.0)
	pending_decision = {
		"type": "attack",
		"title": "ATAQUE DETECTADO",
		"attacker": attacker.name,
		"attacker_team": attacker.team_abbr,
		"text": "%s ataca. %d km para meta, el pelotón se tensa." % [attacker.name, int(km_to_go)],
		"options": [
			{"id": "respond", "label": "RESPONDER", "desc": "Tu líder salta al ataque (fatiga extra)."},
			{"id": "attack", "label": "ATACAR", "desc": "Lanza tu propio ataque."},
			{"id": "maintain", "label": "MANTENER RITMO", "desc": "Controla el ritmo del pelotón."},
			{"id": "save", "label": "NO RESPONDER", "desc": "Ahorra fuerzas."},
		],
	}

func apply_decision(choice_id: String) -> void:
	var d := pending_decision.duplicate()
	d["choice"] = choice_id
	decisions_log.append(d)
	pending_decision = {}
	if choice_id == "respond" or choice_id == "attack":
		var rider := _best_player_rider("att")
		var fuga := _fuga_group()
		if rider != null and fuga != null and rider.group_id != fuga.id:
			_assign_to_group(rider, fuga)
			rider.fatigue = clampf(rider.fatigue + 8.0, 0.0, 100.0)
			events.add(km, "attack", "RESPUESTA", "%s responde al ataque y salta a la fuga." % rider.name, [rider.id])
	elif choice_id == "maintain":
		events.add(km, "info", "RITMO", "Tu equipo mantiene el ritmo del pelotón.", [])
	else:
		events.add(km, "info", "AHORRO", "Tu equipo se mantiene a cubierto.", [])

func _best_player_rider(attr_key: String) -> Rider:
	var best: Rider = null
	for r in riders:
		if r.team_id != player_team_id or r.status != "OK":
			continue
		if best == null or r.attr(attr_key) > best.attr(attr_key):
			best = r
	return best

func _has_breakaway() -> bool:
	for g in groups:
		if g.name == "Fuga" and not g.riders.is_empty():
			return true
	return false

func _fuga_group() -> Group:
	for g in groups:
		if g.name == "Fuga" and not g.riders.is_empty():
			return g
	return null

## Actualiza la ventaja de la fuga y la neutraliza si es alcanzada.
func _update_breakaway(sec: Dictionary, length: float) -> void:
	var fuga := _fuga_group()
	if fuga == null:
		return
	var peloton := _peloton()
	if peloton == null or peloton == fuga:
		return
	var terrain := str(sec.get("terrain", "flat"))
	var gap := peloton.time - fuga.time
	var rate := _breakaway_gap_rate(terrain)
	if sec.get("special", "") == "finish" and terrain not in Terrain.CLIMB_TERRAINS:
		rate = -6.0
	gap += rate * length
	if gap < 8.0:
		_catch_breakaway(fuga, peloton)
		return
	fuga.time = peloton.time - gap

func _breakaway_gap_rate(terrain: String) -> float:
	match terrain:
		"flat":
			return 0.4
		"descent":
			return 0.3
		"hill":
			return -0.5
		"medium_mountain":
			return -1.2
		"mountain":
			return -2.0
		"cobbles", "crosswind":
			return 0.3
	return 0.0

func _catch_breakaway(fuga: Group, peloton: Group) -> void:
	var names: Array = []
	for r in fuga.riders:
		names.append(r.name)
	events.add(km, "info", "CAZA", "La fuga es neutralizada por el pelotón.", [])
	for r in fuga.riders.duplicate():
		_assign_to_group(r, peloton)
	fuga.riders.clear()

func _peloton() -> Group:
	var best: Group = null
	for g in groups:
		if best == null or g.rider_count() > best.rider_count():
			best = g
	return best

func _leader_time() -> float:
	var t := INF
	for g in groups:
		if not g.riders.is_empty():
			t = minf(t, g.time)
	return t

func attacker_ids(list: Array) -> Array:
	var out: Array = []
	for r in list:
		out.append(r.id)
	return out

# ------------------------------------------------------------------
# Fatiga / recuperación
# ------------------------------------------------------------------

func _apply_fatigue(terrain: String, length: float) -> void:
	var intensity := float(Terrain.INTENSITY.get(terrain, 1.0))
	var progress := km / maxf(stage.distance, 1.0)
	for r in riders:
		var sta_norm: float = (r.attr("sta") - 50.0) / 50.0
		var res_norm: float = (r.attr("res") - 50.0) / 50.0
		var sta_factor := clampf(sta_norm, 0.0, 1.0) * 0.55
		var late_factor := 1.0 + progress * 0.5 * (1.0 - clampf(res_norm, 0.0, 1.0))
		var add := intensity * length * FATIGUE_RATE * (1.0 - sta_factor) * late_factor
		r.fatigue = clampf(r.fatigue + add, 0.0, 100.0)

func _apply_recovery(length: float) -> void:
	for r in riders:
		var rec_norm: float = (r.attr("rec") - 50.0) / 50.0
		var rec: float = length * 0.05 * clampf(rec_norm, 0.0, 1.0) * (1.0 - r.fatigue / 100.0)
		r.fatigue = clampf(r.fatigue - rec, 0.0, 100.0)

# ------------------------------------------------------------------
# Splits e incidentes
# ------------------------------------------------------------------

func _split_weak_riders(terrain: String, lead_time: float) -> void:
	var peloton := _peloton()
	if peloton == null:
		return
	var attr_key: String = Terrain.ATTR_FOR.get(terrain, "fla")
	var avg := peloton.average_attr(attr_key)
	var threshold := avg - 7.0
	var weak: Array = []
	for r in peloton.riders:
		if r.attr(attr_key) < threshold and r.status == "OK":
			weak.append(r)
	if weak.size() < 3:
		return

	var g := _create_group("Gruppetto")
	for r in weak:
		_assign_to_group(r, g)
	g.time = lead_time + 20.0 + rng.next_float() * 30.0

	events.add(km, "split", "CORTE", "Un grupo de %d corredores se descuelga." % weak.size(),
		attacker_ids(weak))

func _handle_incidents(kind: String, length: float) -> void:
	var base_p := 0.03 * length * float(stage.modifiers.get("cobbles_density", 0.5))
	for r in riders:
		var skill: String = "cob" if kind == "cobbles" else "fla"
		var risk: float = (1.0 - r.attr(skill) / 99.0)
		if rng.chance(base_p * risk):
			r.status = "crashed"
			r.fatigue = clampf(r.fatigue + 8.0, 0.0, 100.0)
			r.time += rng.next_float() * 25.0
			events.add(km, "incident", "INCIDENTE", "%s sufre un incidente." % r.name, [r.id])

# ------------------------------------------------------------------
# Puntos
# ------------------------------------------------------------------

func _award_mountain(sec: Dictionary, terrain: String) -> void:
	var cat := str(sec.get("category", ""))
	if cat == "":
		return
	var pts := int(Classifications.MOUNTAIN_POINTS.get(cat, 2))
	# Primeros corredores del grupo líder por atributo de montaña.
	var leader := _leader_group()
	if leader == null:
		return
	var sorted := leader.riders.duplicate()
	sorted.sort_custom(func(a, b): return a.terrain_attr(terrain) > b.terrain_attr(terrain))
	var winners := sorted.slice(0, mini(6, sorted.size()))
	for i in winners.size():
		var r: Rider = winners[i]
		var p := int(pts * [1.0, 0.7, 0.5, 0.35, 0.25, 0.15][mini(i, 5)])
		classifications.add_mountain(r.id, p)
		r.stage_points += p
	events.add(km, "mountain", "PUERTO", "%s corona el puerto (cat %s)." % [winners[0].name, cat],
		attacker_ids(winners))

func _award_sprint(sec: Dictionary) -> void:
	var leader := _leader_group()
	if leader == null:
		return
	var sorted := leader.riders.duplicate()
	sorted.sort_custom(func(a, b): return a.attr("spr") > b.attr("spr"))
	var winners := sorted.slice(0, mini(8, sorted.size()))
	for i in winners.size():
		var r: Rider = winners[i]
		var p := int(Classifications.SPRINT_POINTS[mini(i, 14)])
		classifications.add_points(r.id, p)
		r.stage_points += p
	events.add(km, "sprint", "SPRINT", "%s gana el sprint intermedio." % winners[0].name,
		attacker_ids(winners))

func _leader_group() -> Group:
	var best: Group = null
	for g in groups:
		if g.riders.is_empty():
			continue
		if best == null or g.time < best.time:
			best = g
	return best

# ------------------------------------------------------------------
# Contrarreloj
# ------------------------------------------------------------------

func _resolve_time_trial() -> void:
	var length := stage.distance
	for sec in stage.sections:
		length = maxf(float(sec.get("end_km", length)), length)
	var is_ttt := stage.type == "ttt"

	if is_ttt:
		var by_team := {}
		for r in riders:
			if not by_team.has(r.team_id):
				by_team[r.team_id] = []
			by_team[r.team_id].append(r)
		for tid in by_team.keys():
			var team_riders: Array = by_team[tid]
			var avg := 0.0
			for r in team_riders:
				avg += r.attr("ttr")
			avg /= team_riders.size()
			var speed := 46.0 + (avg - 50.0) * 0.12
			var t := length / speed * 3600.0
			for r in team_riders:
				r.time = t
	else:
		var key := "prl" if stage.type == "prologue" else "ttr"
		for r in riders:
			var speed: float = 46.0 + (r.attr(key) - 50.0) * 0.12 + (rng.next_float() - 0.5) * 0.6
			r.time = length / speed * 3600.0

	_finalize_times()

# ------------------------------------------------------------------
# Final de etapa
# ------------------------------------------------------------------

func finish_stage() -> void:
	var leader := _leader_group()
	if leader == null:
		return
	var final_terrain := "flat"
	for i in range(stage.sections.size() - 1, -1, -1):
		final_terrain = str(stage.sections[i].get("terrain", "flat"))
		break

	if final_terrain in Terrain.CLIMB_TERRAINS:
		_final_mountain_finish(leader)
	else:
		_final_bunch_sprint(leader)

	_finalize_times()

func _final_bunch_sprint(leader: Group) -> void:
	var scored: Array = []
	for r in leader.riders:
		scored.append({"r": r, "score": _sprint_score(r)})
	scored.sort_custom(func(a, b): return a["score"] > b["score"])
	var winner: Rider = scored[0]["r"] if not scored.is_empty() else null
	if winner != null:
		stage_winner_id = winner.id
		events.add(stage.distance, "finish", "SPRINT", "%s gana el sprint de %s." % [
			winner.name, stage.finish if stage.finish != "" else "meta"], [winner.id])
	# Puntos de sprint del final.
	for i in mini(15, scored.size()):
		var r: Rider = scored[i]["r"]
		classifications.add_points(r.id, int(Classifications.SPRINT_POINTS[mini(i, 14)]))

func _sprint_score(r: Rider) -> float:
	return r.attr("spr") * 0.6 + r.attr("acc") * 0.4 + rng.next_float() * 6.0

func _final_mountain_finish(leader: Group) -> void:
	var key := "mnt"
	var sorted := leader.riders.duplicate()
	sorted.sort_custom(func(a, b): return a.attr(key) > b.attr(key))
	var winner: Rider = sorted[0] if not sorted.is_empty() else null
	if winner != null:
		stage_winner_id = winner.id
		events.add(stage.distance, "finish", "META", "%s gana en la cima de %s." % [
			winner.name, stage.finish if stage.finish != "" else "meta"], [winner.id])
		# Asignar gaps según capacidad de escalada (los corredores llegan escalonados).
		var w_mnt := float(winner.attr(key))
		for r in leader.riders:
			var g := maxf((w_mnt - float(r.attr(key))) * 3.0 + rng.next_float() * 4.0, 0.0)
			r.time += g

## Asigna tiempos finales y completa clasificaciones.
func _finalize_times() -> void:
	# Orden global por tiempo.
	riders.sort_custom(func(a, b): return a.time < b.time)
	var winner_time: float = riders[0].time if not riders.is_empty() else 0.0
	for i in riders.size():
		var r: Rider = riders[i]
		r.finished = true
		r.gap = r.time - winner_time
		classifications.add_time(r.id, r.time - winner_time)
		classifications.stage_results.append(r.id)

	finished = true
	if stage_winner_id == -1 and not riders.is_empty():
		stage_winner_id = riders[0].id

func get_results() -> Dictionary:
	var gc := classifications.gc_ranking(riders_by_id)
	return {
		"stage_id": stage.id,
		"stage_name": stage.name,
		"type": stage.type,
		"seed": rng.state,
		"winner_id": stage_winner_id,
		"winner_name": riders_by_id.get(stage_winner_id, {}).name if stage_winner_id >= 0 else "",
		"gc": gc,
		"points": classifications.points_ranking(riders_by_id),
		"mountain": classifications.mountain_ranking(riders_by_id),
		"young": classifications.young_ranking(riders_by_id),
		"teams": classifications.team_ranking(riders_by_id, teams),
		"events": events.get_all(),
	}

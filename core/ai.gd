class_name TeamAI
extends RefCounted
## Objetivos tácticos de equipo (PRD §15, §12).

## Objetivo del equipo según sus corredores (filas de BD).
static func objective(rows: Array) -> String:
	var best_mnt := 50
	var best_spr := 50
	var best_ttr := 50
	var best_att := 50
	for r in rows:
		best_mnt = maxi(best_mnt, int(r.get("mnt", 50)))
		best_spr = maxi(best_spr, int(r.get("spr", 50)))
		best_ttr = maxi(best_ttr, int(r.get("ttr", 50)))
		best_att = maxi(best_att, int(r.get("att", 50)))
	if best_mnt >= 80:
		return "General"
	if best_spr >= 82:
		return "Sprint"
	if best_ttr >= 80:
		return "Contrarreloj"
	if best_att >= 80:
		return "Cazador de fugas"
	if best_mnt >= 74:
		return "Escalada"
	return "Equilibrado"

## Líder del equipo para una especialidad concreta.
static func team_leader(rows: Array, attr_key: String) -> Dictionary:
	var best: Dictionary = {}
	var best_v := -1
	for r in rows:
		var v := int(r.get(attr_key, 50))
		if v > best_v:
			best_v = v
			best = r
	return best

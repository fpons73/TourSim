class_name Stage
extends RefCounted
## Modelo runtime de una etapa (definición + perfil de secciones).

var id: int = -1
var name: String = ""
var date: String = ""
var type: String = "flat"
var distance: float = 150.0
var start: String = ""
var finish: String = ""
var description: String = ""
var sections: Array = []        # de Dictionary (start_km, end_km, terrain, gradient, category, special)
var modifiers: Dictionary = {}  # tempo_modifier, incident_phase, time_factor, etc.

const DEFAULT_MODIFIERS := {
	"tempo_modifier": 1.0,     # multiplica el ritmo/velocidad global
	"incident_phase": 0.5,     # km de la etapa donde se concentran incidentes
	"time_factor": 1.0,        # escala los gaps de tiempo
	"wind": 0.0,               # intensidad de viento 0..1
	"cobbles_density": 0.5,    # dureza relativa del pavés
}

static func from_row(row: Dictionary) -> Stage:
	var s := Stage.new()
	s.id = int(row.get("id", -1))
	s.name = str(row.get("name", ""))
	s.date = str(row.get("date", ""))
	s.type = str(row.get("type", "flat"))
	s.distance = float(row.get("distance", 150.0))
	s.start = str(row.get("start", ""))
	s.finish = str(row.get("finish", ""))
	s.description = str(row.get("description", ""))
	s.sections = _parse_sections(row.get("sections_json"))
	s.modifiers = _parse_modifiers(row.get("modifiers_json"))
	if s.sections.is_empty():
		s.sections = StageProfile.build(s.type, s.distance)
	return s

static func _parse_sections(raw) -> Array:
	if raw == null or raw == "":
		return []
	var parsed = JSON.parse_string(str(raw))
	if parsed is Array:
		return parsed
	return []

static func _parse_modifiers(raw) -> Dictionary:
	var m := DEFAULT_MODIFIERS.duplicate()
	if raw == null or raw == "":
		return m
	var parsed = JSON.parse_string(str(raw))
	if parsed is Dictionary:
		for k in parsed.keys():
			m[k] = parsed[k]
	return m

func label() -> String:
	return Terrain.STAGE_TYPES.get(type, type)


class StageProfile:
	## Genera un perfil de secciones por defecto según tipo y distancia.
	static func build(type: String, distance: float) -> Array:
		var d := maxf(distance, 1.0)
		match type:
			"flat":
				return _secs(d, [
					[0.0, 0.85, "flat", 0.0, ""],
					[0.85, 1.0, "flat", 0.0, "finish"],
				])
			"flat_hilly":
				return _secs(d, [
					[0.0, 0.3, "flat", 0.0, ""],
					[0.3, 0.55, "hill", 5.0, "4"],
					[0.55, 0.7, "descent", -5.0, ""],
					[0.7, 1.0, "flat", 0.0, "finish"],
				])
			"medium_mountain":
				return _secs(d, [
					[0.0, 0.2, "flat", 0.0, ""],
					[0.2, 0.4, "medium_mountain", 5.5, "2"],
					[0.4, 0.5, "descent", -5.5, ""],
					[0.5, 0.7, "medium_mountain", 6.0, "1"],
					[0.7, 0.85, "descent", -6.0, ""],
					[0.85, 1.0, "flat", 0.0, "finish"],
				])
			"mountain":
				return _secs(d, [
					[0.0, 0.15, "flat", 0.0, ""],
					[0.15, 0.35, "mountain", 7.0, "1"],
					[0.35, 0.45, "descent", -7.0, ""],
					[0.45, 0.7, "mountain", 8.0, "HC"],
					[0.7, 0.8, "descent", -7.5, ""],
					[0.8, 1.0, "mountain", 6.0, "1"],
				])
			"itt":
				return _secs(d, [[0.0, 1.0, "itt", 0.0, "finish"]])
			"ttt":
				return _secs(d, [[0.0, 1.0, "ttt", 0.0, "finish"]])
			"prologue":
				return _secs(d, [[0.0, 1.0, "prologue", 0.0, "finish"]])
			"crosswind":
				return _secs(d, [
					[0.0, 0.4, "flat", 0.0, ""],
					[0.4, 0.7, "crosswind", 0.0, ""],
					[0.7, 1.0, "flat", 0.0, "finish"],
				])
			"cobbles":
				return _secs(d, [
					[0.0, 0.3, "flat", 0.0, ""],
					[0.3, 0.55, "cobbles", 0.0, ""],
					[0.55, 0.8, "cobbles", 0.0, ""],
					[0.8, 1.0, "flat", 0.0, "finish"],
				])
			_:
				return _secs(d, [[0.0, 1.0, "flat", 0.0, "finish"]])

	static func _secs(distance: float, spec: Array) -> Array:
		var out: Array = []
		for s in spec:
			var a := float(s[0]) * distance
			var b := float(s[1]) * distance
			out.append({
				"start_km": a,
				"end_km": b,
				"terrain": s[2],
				"gradient": s[3],
				"category": s[4],
				"special": "",
			})
		# Marcar la última sección como final.
		if not out.is_empty():
			out[out.size() - 1]["special"] = "finish"
		return out

## Altitud aproximada (m) en un km dado, integrando pendientes del perfil.
static func altitude_at(stage: Stage, km: float) -> float:
	var alt := 0.0
	var remaining := km
	for sec in stage.sections:
		var a := float(sec.get("start_km", 0.0))
		var b := float(sec.get("end_km", 0.0))
		var grad := float(sec.get("gradient", 0.0))
		var seg_len := b - a
		var covered := clampf(remaining - a, 0.0, seg_len)
		if covered > 0.0:
			alt += covered * grad * 10.0
		remaining -= seg_len
		if remaining <= 0.0:
			break
	return maxf(alt, 0.0)

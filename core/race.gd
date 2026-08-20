class_name Race
extends RefCounted
## Modelo runtime de una carrera (lista ordenada de etapas).

var id: int = -1
var name: String = ""
var edition: String = ""
var country: String = ""
var description: String = ""
var start_date: String = ""
var end_date: String = ""
var logo: String = ""
var stage_order: Array = []     # ids de etapa en orden

static func from_row(row: Dictionary) -> Race:
	var r := Race.new()
	r.id = int(row.get("id", -1))
	r.name = str(row.get("name", ""))
	r.edition = str(row.get("edition", ""))
	r.country = str(row.get("country", ""))
	r.description = str(row.get("description", ""))
	r.start_date = str(row.get("start_date", ""))
	r.end_date = str(row.get("end_date", ""))
	r.logo = str(row.get("logo", ""))
	r.stage_order = RaceRepo.get_stage_ids(r.id)
	return r

func stage_count() -> int:
	return stage_order.size()

## Carga las etapas (objetos Stage) en orden.
func stages() -> Array:
	var out: Array = []
	for sid in stage_order:
		var row := StageRepo.get_by_id(int(sid))
		if not row.is_empty():
			out.append(Stage.from_row(row))
	return out

func total_distance() -> float:
	var d := 0.0
	for s in stages():
		d += s.distance
	return d

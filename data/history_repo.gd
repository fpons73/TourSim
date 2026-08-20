class_name HistoryRepo
extends RefCounted
## Repositorio del histórico de simulaciones (tabla simulations).

static func save_simulation(data: Dictionary) -> int:
	var cols := ["date", "seed", "mode", "ref_type", "ref_id",
		"results_json", "classifications_json", "events_json", "decisions_json"]
	var vals: Array = []
	var marks: Array = []
	for c in cols:
		vals.append(data.get(c))
		marks.append("?")
	var sql := "INSERT INTO simulations (%s) VALUES (%s)" % [",".join(cols), ",".join(marks)]
	if DataStore.execute(sql, vals):
		return DataStore.get_last_insert_id()
	return -1

static func list_all() -> Array:
	return DataStore.query("SELECT * FROM simulations ORDER BY id DESC")

static func get_by_id(id: int) -> Dictionary:
	return DataStore.query_one("SELECT * FROM simulations WHERE id=?", [id])

static func count() -> int:
	return int(DataStore.query_one("SELECT COUNT(*) AS c FROM simulations").get("c", 0))

static func delete(id: int) -> bool:
	return DataStore.execute("DELETE FROM simulations WHERE id=?", [id])

## Decodifica un campo JSON almacenado en la simulación.
static func decode_field(sim: Dictionary, field: String) -> Variant:
	var raw = sim.get(field)
	if raw == null or raw == "":
		return null
	var parsed = JSON.parse_string(raw)
	return parsed

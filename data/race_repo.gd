class_name RaceRepo
extends RefCounted
## Repositorio de carreras (tabla races).

const COLS := ["name", "edition", "country", "description", "start_date",
	"end_date", "logo", "stage_order_json"]

static func get_all() -> Array:
	return DataStore.query("SELECT * FROM races ORDER BY name")

static func get_by_id(id: int) -> Dictionary:
	return DataStore.query_one("SELECT * FROM races WHERE id=?", [id])

static func search(text: String) -> Array:
	var q := "%" + text + "%"
	return DataStore.query(
		"SELECT * FROM races WHERE name LIKE ? OR edition LIKE ? OR country LIKE ? ORDER BY name",
		[q, q, q]
	)

static func count() -> int:
	return int(DataStore.query_one("SELECT COUNT(*) AS c FROM races").get("c", 0))

## Devuelve la lista ordenada de ids de etapa de una carrera.
static func get_stage_ids(race_id: int) -> Array:
	var r := get_by_id(race_id)
	if r.is_empty():
		return []
	var raw: String = r.get("stage_order_json", "[]")
	if raw == "" or raw == null:
		return []
	var parsed = JSON.parse_string(raw)
	if parsed is Array:
		return parsed
	return []

static func set_stage_ids(race_id: int, ids: Array) -> bool:
	return update(race_id, {"stage_order_json": JSON.stringify(ids)})

static func get_stages(race_id: int) -> Array:
	var out: Array = []
	for sid in get_stage_ids(race_id):
		var s := StageRepo.get_by_id(int(sid))
		if not s.is_empty():
			out.append(s)
	return out

static func create(data: Dictionary) -> int:
	var cols: Array = []
	var vals: Array = []
	var marks: Array = []
	for c in COLS:
		if data.has(c):
			cols.append(c)
			vals.append(data[c])
			marks.append("?")
	if cols.is_empty():
		return -1
	var sql := "INSERT INTO races (%s) VALUES (%s)" % [",".join(cols), ",".join(marks)]
	if DataStore.execute(sql, vals):
		return DataStore.get_last_insert_id()
	return -1

static func update(id: int, data: Dictionary) -> bool:
	var sets: Array = []
	var vals: Array = []
	for c in COLS:
		if data.has(c):
			sets.append(c + "=?")
			vals.append(data[c])
	if sets.is_empty():
		return false
	vals.append(id)
	return DataStore.execute("UPDATE races SET %s WHERE id=?" % ",".join(sets), vals)

static func delete(id: int) -> bool:
	return DataStore.execute("DELETE FROM races WHERE id=?", [id])

## Duplica una carrera. Devuelve el nuevo id.
static func duplicate_race(id: int) -> int:
	var src := get_by_id(id)
	if src.is_empty():
		return -1
	var data := src.duplicate()
	data.erase("id")
	data["name"] = str(src.get("name", "")) + " — What If"
	return create(data)

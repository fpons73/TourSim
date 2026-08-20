class_name StageRepo
extends RefCounted
## Repositorio de etapas (tabla stages).

const COLS := ["name", "date", "type", "distance", "start", "finish",
	"description", "sections_json", "modifiers_json", "difficulty", "locked"]

static func get_all() -> Array:
	return DataStore.query("SELECT * FROM stages ORDER BY id")

static func get_by_id(id: int) -> Dictionary:
	return DataStore.query_one("SELECT * FROM stages WHERE id=?", [id])

static func get_by_type(type: String) -> Array:
	return DataStore.query("SELECT * FROM stages WHERE type=? ORDER BY name", [type])

static func search(text: String) -> Array:
	var q := "%" + text + "%"
	return DataStore.query(
		"SELECT * FROM stages WHERE name LIKE ? OR type LIKE ? OR start LIKE ? OR finish LIKE ? ORDER BY name",
		[q, q, q, q]
	)

static func count() -> int:
	return int(DataStore.query_one("SELECT COUNT(*) AS c FROM stages").get("c", 0))

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
	var sql := "INSERT INTO stages (%s) VALUES (%s)" % [",".join(cols), ",".join(marks)]
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
	return DataStore.execute("UPDATE stages SET %s WHERE id=?" % ",".join(sets), vals)

static func delete(id: int) -> bool:
	return DataStore.execute("DELETE FROM stages WHERE id=?", [id])

## Duplica una etapa (copia independiente). Devuelve el nuevo id.
static func duplicate_stage(id: int) -> int:
	var src := get_by_id(id)
	if src.is_empty():
		return -1
	var data := src.duplicate()
	data.erase("id")
	data["name"] = str(src.get("name", "")) + " (copia)"
	data["locked"] = 0
	return create(data)

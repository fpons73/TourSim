class_name TeamRepo
extends RefCounted
## Repositorio de equipos (tabla teams).

const COLS := ["name", "abbr", "country", "category", "color_primary", "color_secondary", "roles_json", "extra"]

static func get_all() -> Array:
	return DataStore.query("SELECT * FROM teams ORDER BY name")

static func get_by_id(id: int) -> Dictionary:
	return DataStore.query_one("SELECT * FROM teams WHERE id=?", [id])

static func get_by_name(name: String) -> Dictionary:
	return DataStore.query_one("SELECT * FROM teams WHERE name=?", [name])

static func get_by_category(category: String) -> Array:
	return DataStore.query("SELECT * FROM teams WHERE category=? ORDER BY name", [category])

static func search(text: String) -> Array:
	var q := "%" + text + "%"
	return DataStore.query(
		"SELECT * FROM teams WHERE name LIKE ? OR abbr LIKE ? OR country LIKE ? ORDER BY name",
		[q, q, q]
	)

static func count() -> int:
	return int(DataStore.query_one("SELECT COUNT(*) AS c FROM teams").get("c", 0))

static func get_riders(team_id: int) -> Array:
	return DataStore.query("SELECT * FROM riders WHERE team_id=? ORDER BY name", [team_id])

static func rider_count(team_id: int) -> int:
	return int(DataStore.query_one(
		"SELECT COUNT(*) AS c FROM riders WHERE team_id=?", [team_id]
	).get("c", 0))

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
	var sql := "INSERT INTO teams (%s) VALUES (%s)" % [",".join(cols), ",".join(marks)]
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
	return DataStore.execute("UPDATE teams SET %s WHERE id=?" % ",".join(sets), vals)

static func delete(id: int) -> bool:
	return DataStore.execute("DELETE FROM teams WHERE id=?", [id])

## Roles de la plantilla: { rider_id: rol } (rol: líder, sprinter, escalador, gregario...).
static func get_roles(team_id: int) -> Dictionary:
	var t := get_by_id(team_id)
	if t.is_empty():
		return {}
	var raw = t.get("roles_json")
	if raw == null or raw == "":
		return {}
	var parsed = JSON.parse_string(str(raw))
	if parsed is Dictionary:
		return parsed
	return {}

static func set_roles(team_id: int, roles: Dictionary) -> bool:
	return update(team_id, {"roles_json": JSON.stringify(roles)})

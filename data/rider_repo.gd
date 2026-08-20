class_name RiderRepo
extends RefCounted
## Repositorio de corredores (tabla riders).

const ATTRS := ["fla", "mnt", "mm", "hil", "ttr", "prl", "cob", "spr",
	"acc", "dhi", "att", "sta", "res", "rec"]

const COLS := ["name", "birth_date", "nationality", "team_id", "specialty"] + ATTRS

static func get_all() -> Array:
	return DataStore.query("SELECT * FROM riders ORDER BY name")

static func get_by_id(id: int) -> Dictionary:
	return DataStore.query_one("SELECT * FROM riders WHERE id=?", [id])

static func get_by_team(team_id: int) -> Array:
	return DataStore.query("SELECT * FROM riders WHERE team_id=? ORDER BY name", [team_id])

static func get_by_nationality(nat: String) -> Array:
	return DataStore.query("SELECT * FROM riders WHERE nationality=? ORDER BY name", [nat])

static func search(text: String) -> Array:
	var q := "%" + text + "%"
	return DataStore.query(
		"SELECT * FROM riders WHERE name LIKE ? OR nationality LIKE ? ORDER BY name",
		[q, q]
	)

static func count() -> int:
	return int(DataStore.query_one("SELECT COUNT(*) AS c FROM riders").get("c", 0))

static func get_top_by(attr: String, limit: int = 20) -> Array:
	var a := attr if attr in ATTRS else "spr"
	return DataStore.query("SELECT * FROM riders ORDER BY %s DESC LIMIT ?" % a, [limit])

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
	var sql := "INSERT INTO riders (%s) VALUES (%s)" % [",".join(cols), ",".join(marks)]
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
	return DataStore.execute("UPDATE riders SET %s WHERE id=?" % ",".join(sets), vals)

static func delete(id: int) -> bool:
	return DataStore.execute("DELETE FROM riders WHERE id=?", [id])

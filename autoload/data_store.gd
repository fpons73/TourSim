extends Node
## DataStore — capa de acceso a SQLite (singleton).
## El esquema y la semilla se gestionan en los repositorios (data/*.gd).

const DB_PATH := "user://simtour.db"

var db: SQLite
var initialized := false

func _ready() -> void:
	open_db()

func open_db() -> bool:
	if db == null:
		db = SQLite.new()
		db.path = DB_PATH
		db.foreign_keys = true
		db.verbosity_level = 0
	if initialized:
		return true
	initialized = db.open_db()
	if not initialized:
		push_warning("DataStore: no se pudo abrir la base de datos en %s" % DB_PATH)
	return initialized

func close_db() -> void:
	if db != null and initialized:
		db.close_db()
	initialized = false

func is_ready() -> bool:
	return initialized

## Ejecuta una consulta y devuelve las filas (Array de Dictionary) o [] en caso de error.
func query(sql: String, bindings: Array = []) -> Array:
	if not open_db():
		return []
	var ok := true
	if bindings.is_empty():
		ok = db.query(sql)
	else:
		ok = db.query_with_bindings(sql, bindings)
	if not ok:
		push_warning("DataStore SQL error: %s" % db.error_message)
		return []
	var res: Array = db.query_result
	if res == null:
		return []
	return res

func execute(sql: String, bindings: Array = []) -> bool:
	if not open_db():
		return false
	if bindings.is_empty():
		return db.query(sql)
	return db.query_with_bindings(sql, bindings)

func table_exists(table_name: String) -> bool:
	var rows := query(
		"SELECT name FROM sqlite_master WHERE type='table' AND name=?",
		[table_name]
	)
	return not rows.is_empty()

func get_setting(key: String, default: Variant = null) -> Variant:
	if not table_exists("settings"):
		return default
	var rows := query("SELECT value FROM settings WHERE key=?", [key])
	if rows.is_empty():
		return default
	return JSON.parse_string(str(rows[0]["value"])) if rows[0]["value"] is String else default

func set_setting(key: String, value: Variant) -> void:
	if not table_exists("settings"):
		execute("CREATE TABLE IF NOT EXISTS settings (key TEXT PRIMARY KEY, value TEXT)")
	var payload: String = JSON.stringify(value) if not (value is String) else value
	execute(
		"INSERT INTO settings (key, value) VALUES (?, ?) ON CONFLICT(key) DO UPDATE SET value=excluded.value",
		[key, payload]
	)

func get_last_insert_id() -> int:
	return int(db.last_insert_rowid) if db != null else -1

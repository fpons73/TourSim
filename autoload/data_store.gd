extends Node
## DataStore — capa de acceso a SQLite (singleton).
## Bootstrap: copia res://data/seed.db -> user://simtour.db la primera vez y
## ejecuta las migraciones de esquema. Los repositorios (data/*.gd) construyen
## sobre esta capa.

const DB_PATH := "user://simtour.db"
const SEED_PATH := "res://data/seed.db"

const SCHEMA := """
CREATE TABLE IF NOT EXISTS teams (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL UNIQUE,
    abbr TEXT,
    country TEXT,
    category TEXT,
    color_primary TEXT,
    color_secondary TEXT,
    roles_json TEXT,
    extra INTEGER DEFAULT 0
);
CREATE TABLE IF NOT EXISTS riders (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL,
    birth_date TEXT,
    nationality TEXT,
    team_id INTEGER REFERENCES teams(id),
    specialty TEXT,
    fla INTEGER, mnt INTEGER, mm INTEGER, hil INTEGER,
    ttr INTEGER, prl INTEGER, cob INTEGER, spr INTEGER,
    acc INTEGER, dhi INTEGER, att INTEGER, sta INTEGER,
    res INTEGER, rec INTEGER
);
CREATE TABLE IF NOT EXISTS stages (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL,
    date TEXT,
    type TEXT,
    distance REAL,
    start TEXT,
    finish TEXT,
    description TEXT,
    sections_json TEXT,
    modifiers_json TEXT,
    difficulty INTEGER DEFAULT 0,
    locked INTEGER DEFAULT 0
);
CREATE TABLE IF NOT EXISTS races (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL,
    edition TEXT,
    country TEXT,
    description TEXT,
    start_date TEXT,
    end_date TEXT,
    logo TEXT,
    stage_order_json TEXT
);
CREATE TABLE IF NOT EXISTS simulations (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    date TEXT,
    seed TEXT,
    mode TEXT,
    ref_type TEXT,
    ref_id INTEGER,
    results_json TEXT,
    classifications_json TEXT,
    events_json TEXT,
    decisions_json TEXT
);
CREATE TABLE IF NOT EXISTS settings (
    key TEXT PRIMARY KEY,
    value TEXT
);
"""

var db: SQLite
var initialized := false
var _reseeded := false

func _ready() -> void:
	bootstrap()

func bootstrap() -> void:
	_ensure_user_db()
	open_db()
	migrate()
	if not _reseeded and TeamRepo.count() == 0 and FileAccess.file_exists(SEED_PATH):
		close_db()
		_copy_seed()
		open_db()
		migrate()
		_reseeded = true

func _ensure_user_db() -> void:
	if not FileAccess.file_exists(DB_PATH):
		_copy_seed()

func _copy_seed() -> void:
	var seed := FileAccess.open(SEED_PATH, FileAccess.READ)
	if seed == null:
		return
	var bytes := seed.get_buffer(seed.get_length())
	seed.close()
	var out := FileAccess.open(DB_PATH, FileAccess.WRITE)
	if out != null:
		out.store_buffer(bytes)
		out.close()

func migrate() -> void:
	if not initialized:
		return
	var stmts := SCHEMA.split(";")
	for s in stmts:
		var t := s.strip_edges()
		if t != "":
			db.query(t + ";")
	_ensure_column("teams", "roles_json", "TEXT")

func _ensure_column(table: String, column: String, decl: String) -> void:
	var rows := query("PRAGMA table_info(%s)" % table)
	for r in rows:
		if str(r.get("name", "")) == column:
			return
	execute("ALTER TABLE %s ADD COLUMN %s %s" % [table, column, decl])

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

## Consulta y devuelve las filas (Array de Dictionary) o [] en caso de error.
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

func query_one(sql: String, bindings: Array = []) -> Dictionary:
	var rows := query(sql, bindings)
	return rows[0] if not rows.is_empty() else {}

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

func get_last_insert_id() -> int:
	return int(db.last_insert_rowid) if db != null else -1

func get_setting(key: String, default: Variant = null) -> Variant:
	if not table_exists("settings"):
		return default
	var rows := query("SELECT value FROM settings WHERE key=?", [key])
	if rows.is_empty():
		return default
	var raw = rows[0]["value"]
	if raw is String:
		var parsed = JSON.parse_string(raw)
		return parsed if parsed != null else raw
	return default

func set_setting(key: String, value: Variant) -> void:
	if not table_exists("settings"):
		execute("CREATE TABLE IF NOT EXISTS settings (key TEXT PRIMARY KEY, value TEXT)")
	var payload: String
	if value is String:
		payload = value
	else:
		payload = JSON.stringify(value)
	execute(
		"INSERT INTO settings (key, value) VALUES (?, ?) ON CONFLICT(key) DO UPDATE SET value=excluded.value",
		[key, payload]
	)

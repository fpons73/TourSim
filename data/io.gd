class_name DataIO
extends RefCounted
## Importación/exportación de datos (JSON y CSV).

static func export_json(path: String, include_history: bool = true) -> bool:
	var payload := {
		"teams": TeamRepo.get_all(),
		"riders": RiderRepo.get_all(),
		"stages": StageRepo.get_all(),
		"races": RaceRepo.get_all(),
	}
	if include_history:
		payload["simulations"] = HistoryRepo.list_all()
	var f := FileAccess.open(path, FileAccess.WRITE)
	if f == null:
		return false
	f.store_string(JSON.stringify(payload, "\t"))
	f.close()
	return true

static func import_json(path: String, replace: bool = true) -> bool:
	var f := FileAccess.open(path, FileAccess.READ)
	if f == null:
		return false
	var parsed = JSON.parse_string(f.get_as_text())
	f.close()
	if not (parsed is Dictionary):
		return false
	if replace:
		_clear_all()
	for table in ["teams", "riders", "stages", "races"]:
		if parsed.has(table) and parsed[table] is Array:
			_insert_rows(table, parsed[table])
	return true

static func _clear_all() -> void:
	for t in ["simulations", "races", "stages", "riders", "teams"]:
		DataStore.execute("DELETE FROM " + t)

static func _insert_rows(table: String, rows: Array) -> void:
	for row in rows:
		if not (row is Dictionary):
			continue
		var d: Dictionary = row.duplicate()
		d.erase("id")
		match table:
			"teams": TeamRepo.create(d)
			"riders": RiderRepo.create(d)
			"stages": StageRepo.create(d)
			"races": RaceRepo.create(d)

static func export_riders_csv(path: String) -> bool:
	var lines := PackedStringArray()
	lines.append("id,name,birth_date,nationality,team_id,specialty," + ",".join(RiderRepo.ATTRS))
	for r in RiderRepo.get_all():
		var parts: Array = [str(r.get("id", "")), _csv_escape(str(r.get("name", ""))),
			_csv_escape(str(r.get("birth_date", ""))), _csv_escape(str(r.get("nationality", ""))),
			str(r.get("team_id", "")), _csv_escape(str(r.get("specialty", "")))]
		for a in RiderRepo.ATTRS:
			parts.append(str(r.get(a, "")))
		lines.append(",".join(parts))
	return _write_text(path, "\n".join(lines))

static func export_teams_csv(path: String) -> bool:
	var lines := PackedStringArray()
	lines.append("id,name,abbr,country,category,color_primary,color_secondary")
	for t in TeamRepo.get_all():
		lines.append(",".join([
			str(t.get("id", "")), _csv_escape(str(t.get("name", ""))),
			_csv_escape(str(t.get("abbr", ""))), _csv_escape(str(t.get("country", ""))),
			_csv_escape(str(t.get("category", ""))), _csv_escape(str(t.get("color_primary", ""))),
			_csv_escape(str(t.get("color_secondary", ""))),
		]))
	return _write_text(path, "\n".join(lines))

static func import_riders_csv(path: String) -> int:
	var f := FileAccess.open(path, FileAccess.READ)
	if f == null:
		return 0
	var text := f.get_as_text()
	f.close()
	var rows := _parse_csv(text)
	if rows.size() < 2:
		return 0
	var header: Array = rows[0]
	var idx := {}
	for i in header.size():
		idx[str(header[i]).strip_edges().to_lower()] = i
	var imported := 0
	for i in range(1, rows.size()):
		var row: Array = rows[i]
		if row.size() < header.size():
			continue
		var d := {}
		d["name"] = _get_cell(row, idx, "name", "")
		d["birth_date"] = _get_cell(row, idx, "birth_date", "")
		d["nationality"] = _get_cell(row, idx, "nationality", "")
		d["specialty"] = _get_cell(row, idx, "specialty", "")
		var tid_text := _get_cell(row, idx, "team_id", "")
		if tid_text != "" and tid_text.is_valid_int():
			d["team_id"] = int(tid_text)
		for a in RiderRepo.ATTRS:
			var v := _get_cell(row, idx, a, "")
			if v != "" and v.is_valid_int():
				d[a] = int(v)
		if d.get("name", "") != "":
			RiderRepo.create(d)
			imported += 1
	return imported

static func _get_cell(row: Array, idx: Dictionary, col: String, default: String) -> String:
	var i = idx.get(col, -1)
	if i >= 0 and i < row.size():
		return str(row[i]).strip_edges()
	return default

static func _csv_escape(s: String) -> String:
	if s.contains(",") or s.contains("\"") or s.contains("\n"):
		return "\"" + s.replace("\"", "\"\"") + "\""
	return s

static func _write_text(path: String, text: String) -> bool:
	var f := FileAccess.open(path, FileAccess.WRITE)
	if f == null:
		return false
	f.store_string(text)
	f.close()
	return true

## Parser CSV mínimo (soporta comillas y saltos de línea dentro de campos).
static func _parse_csv(text: String) -> Array:
	var rows: Array = []
	var row: Array = []
	var field := ""
	var in_quotes := false
	var i := 0
	while i < text.length():
		var c := text[i]
		if in_quotes:
			if c == "\"":
				if i + 1 < text.length() and text[i + 1] == "\"":
					field += "\""
					i += 1
				else:
					in_quotes = false
			else:
				field += c
		else:
			if c == "\"":
				in_quotes = true
			elif c == ",":
				row.append(field)
				field = ""
			elif c == "\n" or c == "\r":
				if c == "\r" and i + 1 < text.length() and text[i + 1] == "\n":
					i += 1
				row.append(field)
				field = ""
				rows.append(row)
				row = []
			else:
				field += c
		i += 1
	if field != "" or not row.is_empty():
		row.append(field)
		rows.append(row)
	return rows

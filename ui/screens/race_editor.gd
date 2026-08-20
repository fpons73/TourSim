class_name RaceEditor
extends BaseScreen
## Editor de carreras (PRD §10): información + lista ordenada de etapas.

var _race_id: int = -1
var _stage_ids: Array = []
var _list: VBoxContainer
var _name: LineEdit
var _edition: LineEdit
var _country: LineEdit
var _desc: LineEdit
var _start: LineEdit
var _end: LineEdit

func _init(p: Dictionary = {}) -> void:
	_race_id = int(p.get("race_id", -1))
	title = "Editar carrera" if _race_id >= 0 else "Crear carrera"
	super._init(p)

func _build() -> void:
	var scroll := add_scroll()

	_name = LineEdit.new()
	_name.placeholder_text = "Nombre de la carrera"
	scroll.add_child(UIUtil.form_row("Nombre", _name))

	_edition = LineEdit.new()
	_edition.placeholder_text = "2026"
	scroll.add_child(UIUtil.form_row("Edición", _edition))

	_country = LineEdit.new()
	_country.placeholder_text = "País"
	scroll.add_child(UIUtil.form_row("País", _country))

	_desc = LineEdit.new()
	_desc.placeholder_text = "Descripción (opcional)"
	scroll.add_child(UIUtil.form_row("Descripción", _desc))

	_start = LineEdit.new()
	_start.placeholder_text = "2026-07-04"
	scroll.add_child(UIUtil.form_row("Fecha inicio", _start))

	_end = LineEdit.new()
	_end.placeholder_text = "2026-07-25"
	scroll.add_child(UIUtil.form_row("Fecha final", _end))

	scroll.add_child(UIUtil.spacer(6))
	scroll.add_child(UIUtil.label("ETAPAS", 12, Palette.BLUE))

	# Añadir etapa.
	var add_row := UIUtil.hbox(8)
	scroll.add_child(add_row)
	var picker := OptionButton.new()
	picker.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var all_stages := StageRepo.get_all()
	for s in all_stages:
		picker.add_item(str(s.get("name", "")))
	var add_btn := UIUtil.button("Añadir etapa", 38)
	add_btn.pressed.connect(func():
		if all_stages.is_empty():
			return
		var sid := int(all_stages[picker.selected]["id"])
		if not _stage_ids.has(sid):
			_stage_ids.append(sid)
			_refresh_list())
	add_row.add_child(picker)
	add_row.add_child(add_btn)

	var new_btn := UIUtil.button("Crear nueva etapa...", 38)
	new_btn.pressed.connect(func(): SignalBus.navigation_requested.emit("stage_editor", {}))
	scroll.add_child(new_btn)

	_list = UIUtil.vbox(6)
	scroll.add_child(_list)

	scroll.add_child(UIUtil.spacer(6))
	var save := UIUtil.button("Guardar carrera", 46)
	save.pressed.connect(func(): _save())
	scroll.add_child(save)

	if _race_id >= 0:
		_load()

func _load() -> void:
	var row := RaceRepo.get_by_id(_race_id)
	if row.is_empty():
		return
	_name.text = str(row.get("name", ""))
	_edition.text = str(row.get("edition", ""))
	_country.text = str(row.get("country", ""))
	_desc.text = str(row.get("description", ""))
	_start.text = str(row.get("start_date", ""))
	_end.text = str(row.get("end_date", ""))
	_stage_ids = RaceRepo.get_stage_ids(_race_id)
	_refresh_list()

func _refresh_list() -> void:
	UIUtil.clear(_list)
	if _stage_ids.is_empty():
		_list.add_child(UIUtil.label("Sin etapas. Añade etapas desde el selector.", 13, Palette.MUTED))
	for i in _stage_ids.size():
		var sid: int = _stage_ids[i]
		var s := StageRepo.get_by_id(sid)
		if s.is_empty():
			continue
		_list.add_child(_stage_row(i, sid, s))

func _stage_row(i: int, sid: int, s: Dictionary) -> Control:
	var row := UIUtil.hbox(8)
	var info := UIUtil.vbox(0)
	info.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	info.add_child(UIUtil.label("%d. %s" % [i + 1, s.get("name", "")], 14, Palette.TEXT))
	info.add_child(UIUtil.label("%s · %.0f km" % [
		Terrain.STAGE_TYPES.get(s.get("type", "flat"), s.get("type")), float(s.get("distance", 0.0))], 11, Palette.MUTED))
	row.add_child(info)

	var up := Button.new()
	up.text = "↑"
	up.custom_minimum_size = Vector2(34, 0)
	up.disabled = i == 0
	up.pressed.connect(func(): _move(i, -1))
	row.add_child(up)
	var down := Button.new()
	down.text = "↓"
	down.custom_minimum_size = Vector2(34, 0)
	down.disabled = i == _stage_ids.size() - 1
	down.pressed.connect(func(): _move(i, 1))
	row.add_child(down)
	var rm := Button.new()
	rm.text = "×"
	rm.custom_minimum_size = Vector2(34, 0)
	rm.pressed.connect(func():
		_stage_ids.remove_at(i)
		_refresh_list())
	row.add_child(rm)
	return row

func _move(i: int, delta: int) -> void:
	var j := i + delta
	if j < 0 or j >= _stage_ids.size():
		return
	var tmp = _stage_ids[i]
	_stage_ids[i] = _stage_ids[j]
	_stage_ids[j] = tmp
	_refresh_list()

func _save() -> void:
	var data := {
		"name": _name.text.strip_edges() if _name.text.strip_edges() != "" else "Carrera sin nombre",
		"edition": _edition.text,
		"country": _country.text,
		"description": _desc.text,
		"start_date": _start.text,
		"end_date": _end.text,
		"stage_order_json": JSON.stringify(_stage_ids),
	}
	if _race_id >= 0:
		RaceRepo.update(_race_id, data)
	else:
		RaceRepo.create(data)
	SignalBus.back_requested.emit()

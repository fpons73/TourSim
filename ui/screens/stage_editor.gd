class_name StageEditor
extends BaseScreen
## Editor de etapas (PRD §9): básico (auto-perfil) o avanzado (secciones).

const STAGE_TYPES := ["flat", "flat_hilly", "medium_mountain", "mountain", "itt", "ttt", "crosswind", "cobbles", "prologue"]
const SECTION_TERRAINS := ["flat", "hill", "medium_mountain", "mountain", "descent", "cobbles", "crosswind", "itt", "ttt", "prologue"]
const CATEGORIES := ["", "4", "3", "2", "1", "HC"]

var _stage_id: int = -1
var _name: LineEdit
var _date: LineEdit
var _start: LineEdit
var _finish: LineEdit
var _desc: LineEdit
var _type: OptionButton
var _distance: SpinBox
var _sections: Array = []          # de {terrain, gradient, category}
var _sections_box: VBoxContainer
var _chart: ProfileChart

func _init(p: Dictionary = {}) -> void:
	_stage_id = int(p.get("stage_id", -1))
	title = "Editar etapa" if _stage_id >= 0 else "Crear etapa"
	super._init(p)

func _build() -> void:
	var scroll := add_scroll()

	# Datos básicos.
	_name = LineEdit.new()
	_name.placeholder_text = "Nombre de la etapa"
	scroll.add_child(UIUtil.form_row("Nombre", _name))

	_date = LineEdit.new()
	_date.placeholder_text = "2026-07-01"
	scroll.add_child(UIUtil.form_row("Fecha", _date))

	_type = OptionButton.new()
	for t in STAGE_TYPES:
		_type.add_item(Terrain.STAGE_TYPES.get(t, t))
	scroll.add_child(UIUtil.form_row("Tipo", _type))

	_distance = SpinBox.new()
	_distance.min_value = 1
	_distance.max_value = 400
	_distance.value = 150
	_distance.suffix = " km"
	scroll.add_child(UIUtil.form_row("Distancia", _distance))

	_start = LineEdit.new()
	_start.placeholder_text = "Salida"
	scroll.add_child(UIUtil.form_row("Salida", _start))

	_finish = LineEdit.new()
	_finish.placeholder_text = "Llegada"
	scroll.add_child(UIUtil.form_row("Llegada", _finish))

	_desc = LineEdit.new()
	_desc.placeholder_text = "Descripción (opcional)"
	scroll.add_child(UIUtil.form_row("Descripción", _desc))

	# Perfil.
	scroll.add_child(UIUtil.spacer(6))
	var profile_header := UIUtil.hbox(8)
	scroll.add_child(profile_header)
	profile_header.add_child(UIUtil.label("PERFIL", 12, Palette.BLUE))
	var auto_btn := UIUtil.button("Auto-generar", 34)
	auto_btn.pressed.connect(func(): _autogenerate())
	profile_header.add_child(auto_btn)
	_chart = ProfileChart.new()
	_chart.custom_minimum_size = Vector2(0, 140)
	scroll.add_child(_chart)

	# Secciones (modo avanzado).
	_sections_box = UIUtil.vbox(6)
	scroll.add_child(_sections_box)

	scroll.add_child(UIUtil.spacer(6))
	var save := UIUtil.button("Guardar etapa", 46)
	save.pressed.connect(func(): _save())
	scroll.add_child(save)

	_type.item_selected.connect(func(_i): _autogenerate())
	_distance.value_changed.connect(func(_v): _rebuild_chart())

	if _stage_id >= 0:
		_load()
	else:
		_autogenerate()

func _load() -> void:
	var row := StageRepo.get_by_id(_stage_id)
	if row.is_empty():
		return
	_name.text = str(row.get("name", ""))
	_date.text = str(row.get("date", ""))
	_start.text = str(row.get("start", ""))
	_finish.text = str(row.get("finish", ""))
	_desc.text = str(row.get("description", ""))
	var t := str(row.get("type", "flat"))
	_type.selected = maxi(STAGE_TYPES.find(t), 0)
	_distance.value = float(row.get("distance", 150.0))
	var raw = row.get("sections_json")
	if raw != null and raw != "":
		var parsed = JSON.parse_string(str(raw))
		if parsed is Array and not parsed.is_empty():
			_sections = []
			for sec in parsed:
				_sections.append({
					"terrain": str(sec.get("terrain", "flat")),
					"gradient": float(sec.get("gradient", 0.0)),
					"category": str(sec.get("category", "")),
				})
			_refresh_sections_ui()
			_rebuild_chart()
			return
	_autogenerate()

func _autogenerate() -> void:
	var t: String = STAGE_TYPES[_type.selected]
	_sections = []
	for sec in Stage.StageProfile.build(t, _distance.value):
		_sections.append({
			"terrain": str(sec.get("terrain", "flat")),
			"gradient": float(sec.get("gradient", 0.0)),
			"category": str(sec.get("category", "")),
		})
	_refresh_sections_ui()
	_rebuild_chart()

func _refresh_sections_ui() -> void:
	UIUtil.clear(_sections_box)
	_sections_box.add_child(UIUtil.label("SECCIONES (%d)" % _sections.size(), 12, Palette.ORANGE))
	for i in _sections.size():
		_sections_box.add_child(_section_row(i))
	var add := UIUtil.button("+ Añadir sección", 34)
	add.pressed.connect(func():
		_sections.append({"terrain": "flat", "gradient": 0.0, "category": ""})
		_refresh_sections_ui()
		_rebuild_chart())
	_sections_box.add_child(add)

func _section_row(i: int) -> Control:
	var row := UIUtil.hbox(6)
	var terrain := OptionButton.new()
	for t in SECTION_TERRAINS:
		terrain.add_item(Terrain.TERRAIN_LABEL.get(t, t))
	terrain.selected = maxi(SECTION_TERRAINS.find(_sections[i]["terrain"]), 0)
	terrain.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	terrain.item_selected.connect(func(idx):
		_sections[i]["terrain"] = SECTION_TERRAINS[idx]
		_rebuild_chart())
	row.add_child(terrain)

	var grad := SpinBox.new()
	grad.min_value = -15
	grad.max_value = 15
	grad.value = _sections[i]["gradient"]
	grad.suffix = " %"
	grad.custom_minimum_size = Vector2(90, 0)
	grad.value_changed.connect(func(v):
		_sections[i]["gradient"] = v
		_rebuild_chart())
	row.add_child(grad)

	var cat := OptionButton.new()
	for c in CATEGORIES:
		cat.add_item(c if c != "" else "—")
	cat.selected = maxi(CATEGORIES.find(_sections[i]["category"]), 0)
	cat.custom_minimum_size = Vector2(70, 0)
	cat.item_selected.connect(func(idx):
		_sections[i]["category"] = CATEGORIES[idx]
		_rebuild_chart())
	row.add_child(cat)

	var rm := Button.new()
	rm.text = "×"
	rm.custom_minimum_size = Vector2(34, 0)
	rm.pressed.connect(func():
		_sections.remove_at(i)
		_refresh_sections_ui()
		_rebuild_chart())
	row.add_child(rm)
	return row

func _build_sections_json() -> String:
	var out: Array = []
	var dist := _distance.value
	var n := maxi(_sections.size(), 1)
	for i in _sections.size():
		var sec: Dictionary = _sections[i]
		out.append({
			"start_km": dist * i / n,
			"end_km": dist * (i + 1) / n,
			"terrain": sec["terrain"],
			"gradient": sec["gradient"],
			"category": sec["category"],
			"special": "finish" if i == _sections.size() - 1 else "",
		})
	return JSON.stringify(out)

func _rebuild_chart() -> void:
	var s := Stage.new()
	s.type = STAGE_TYPES[_type.selected]
	s.distance = _distance.value
	s.sections = _build_sections_array()
	_chart.set_stage(s)

func _build_sections_array() -> Array:
	var out: Array = []
	var dist := _distance.value
	var n := maxi(_sections.size(), 1)
	for i in _sections.size():
		var sec: Dictionary = _sections[i]
		out.append({
			"start_km": dist * i / n,
			"end_km": dist * (i + 1) / n,
			"terrain": sec["terrain"],
			"gradient": sec["gradient"],
			"category": sec["category"],
			"special": "finish" if i == _sections.size() - 1 else "",
		})
	return out

func _save() -> void:
	var data := {
		"name": _name.text.strip_edges() if _name.text.strip_edges() != "" else "Etapa sin nombre",
		"date": _date.text,
		"type": STAGE_TYPES[_type.selected],
		"distance": _distance.value,
		"start": _start.text,
		"finish": _finish.text,
		"description": _desc.text,
		"sections_json": _build_sections_json(),
		"locked": 0,
	}
	if _stage_id >= 0:
		StageRepo.update(_stage_id, data)
	else:
		StageRepo.create(data)
	SignalBus.back_requested.emit()

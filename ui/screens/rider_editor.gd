class_name RiderEditor
extends BaseScreen
## Editor de corredores (PRD §29): datos + 14 atributos.

var _rider_id: int = -1
var _name: LineEdit
var _nat: LineEdit
var _birth: LineEdit
var _team: OptionButton
var _specialty: LineEdit
var _attr_spins: Dictionary = {}
var _teams: Array = []

func _init(p: Dictionary = {}) -> void:
	_rider_id = int(p.get("rider_id", -1))
	title = "Editar corredor" if _rider_id >= 0 else "Crear corredor"
	super._init(p)

func _build() -> void:
	_teams = TeamRepo.get_all()
	var scroll := add_scroll()

	_name = LineEdit.new()
	_name.placeholder_text = "Nombre"
	scroll.add_child(UIUtil.form_row("Nombre", _name))

	_nat = LineEdit.new()
	_nat.placeholder_text = "Nacionalidad (p. ej. ESP)"
	scroll.add_child(UIUtil.form_row("Nacionalidad", _nat))

	_birth = LineEdit.new()
	_birth.placeholder_text = "DD/MM/AAAA"
	scroll.add_child(UIUtil.form_row("F. nacimiento", _birth))

	_team = OptionButton.new()
	for t in _teams:
		_team.add_item(str(t.get("name", "")))
	_team.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.add_child(UIUtil.form_row("Equipo", _team))

	_specialty = LineEdit.new()
	_specialty.placeholder_text = "Especialidad (opcional)"
	scroll.add_child(UIUtil.form_row("Especialidad", _specialty))

	scroll.add_child(UIUtil.spacer(6))
	var groups := [
		{"name": "TERRENO", "color": Palette.BLUE, "attrs": ["fla", "mm", "mnt", "hil", "cob"]},
		{"name": "ESPECIALIDADES", "color": Palette.ORANGE, "attrs": ["spr", "acc", "att", "dhi", "ttr", "prl"]},
		{"name": "FÍSICO", "color": Palette.GREEN, "attrs": ["sta", "res", "rec"]},
	]
	for g in groups:
		scroll.add_child(UIUtil.label(g.name, 12, g.color))
		for a in g.attrs:
			var spin := SpinBox.new()
			spin.min_value = 50
			spin.max_value = 99
			spin.value = 65
			scroll.add_child(UIUtil.form_row(Terrain.ATTR_LABEL.get(a, a), spin))
			_attr_spins[a] = spin

	scroll.add_child(UIUtil.spacer(6))
	var save := UIUtil.button("Guardar corredor", 46)
	save.pressed.connect(func(): _save())
	scroll.add_child(save)

	if _rider_id >= 0:
		_load()

func _load() -> void:
	var row := RiderRepo.get_by_id(_rider_id)
	if row.is_empty():
		return
	_name.text = str(row.get("name", ""))
	_nat.text = str(row.get("nationality", ""))
	_birth.text = str(row.get("birth_date", ""))
	_specialty.text = str(row.get("specialty", ""))
	var tid := int(row.get("team_id", -1))
	var idx := 0
	for i in _teams.size():
		if int(_teams[i]["id"]) == tid:
			idx = i
	_team.selected = idx
	for a in Terrain.ATTRS:
		_attr_spins[a].value = int(row.get(a, 65))

func _save() -> void:
	var data := {
		"name": _name.text.strip_edges() if _name.text.strip_edges() != "" else "Sin nombre",
		"nationality": _nat.text,
		"birth_date": _birth.text,
		"specialty": _specialty.text,
		"team_id": int(_teams[_team.selected]["id"]),
	}
	for a in Terrain.ATTRS:
		data[a] = int(_attr_spins[a].value)
	if _rider_id >= 0:
		RiderRepo.update(_rider_id, data)
	else:
		RiderRepo.create(data)
	SignalBus.back_requested.emit()

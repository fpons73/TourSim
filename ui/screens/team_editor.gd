class_name TeamEditor
extends BaseScreen
## Editor de equipos (PRD §27): datos, colores y roles de plantilla.

const ROLES := ["", "Líder", "Sprinter", "Escalador", "Gregario", "Contrarrelojista", "Cazador"]

var _team_id: int = -1
var _name: LineEdit
var _abbr: LineEdit
var _country: LineEdit
var _category: OptionButton
var _color1: ColorPickerButton
var _color2: ColorPickerButton
var _roles: Dictionary = {}
var _roles_box: VBoxContainer

func _init(p: Dictionary = {}) -> void:
	_team_id = int(p.get("team_id", -1))
	title = "Editar equipo" if _team_id >= 0 else "Crear equipo"
	super._init(p)

func _build() -> void:
	var scroll := add_scroll()

	_name = LineEdit.new()
	_name.placeholder_text = "Nombre"
	scroll.add_child(UIUtil.form_row("Nombre", _name))

	_abbr = LineEdit.new()
	_abbr.placeholder_text = "ABC"
	scroll.add_child(UIUtil.form_row("Abreviatura", _abbr))

	_country = LineEdit.new()
	_country.placeholder_text = "País"
	scroll.add_child(UIUtil.form_row("País", _country))

	_category = OptionButton.new()
	for c in ["WorldTour", "ProTeam", "Continental"]:
		_category.add_item(c)
	scroll.add_child(UIUtil.form_row("Categoría", _category))

	_color1 = ColorPickerButton.new()
	scroll.add_child(UIUtil.form_row("Color principal", _color1))
	_color2 = ColorPickerButton.new()
	scroll.add_child(UIUtil.form_row("Color secundario", _color2))

	scroll.add_child(UIUtil.spacer(6))
	scroll.add_child(UIUtil.label("ROLES DE PLANTILLA", 12, Palette.BLUE))
	_roles_box = UIUtil.vbox(4)
	scroll.add_child(_roles_box)

	scroll.add_child(UIUtil.spacer(6))
	var save := UIUtil.button("Guardar equipo", 46)
	save.pressed.connect(func(): _save())
	scroll.add_child(save)

	if _team_id >= 0:
		_load()
		_refresh_roles()

func _load() -> void:
	var row := TeamRepo.get_by_id(_team_id)
	if row.is_empty():
		return
	_name.text = str(row.get("name", ""))
	_abbr.text = str(row.get("abbr", ""))
	_country.text = str(row.get("country", ""))
	var cat := str(row.get("category", "WorldTour"))
	_category.selected = maxi(["WorldTour", "ProTeam", "Continental"].find(cat), 0)
	_color1.color = Team.from_row(row).color_primary
	_color2.color = Team.from_row(row).color_secondary
	_roles = TeamRepo.get_roles(_team_id)

func _refresh_roles() -> void:
	UIUtil.clear(_roles_box)
	if _team_id < 0:
		_roles_box.add_child(UIUtil.label("Guarda el equipo para asignar roles.", 12, Palette.MUTED))
		return
	var riders := TeamRepo.get_riders(_team_id)
	if riders.is_empty():
		_roles_box.add_child(UIUtil.label("Este equipo no tiene corredores.", 12, Palette.MUTED))
		return
	for row in riders:
		var rid := int(row["id"])
		var h := UIUtil.hbox(8)
		var name := UIUtil.label(str(row.get("name", "")), 14, Palette.TEXT)
		name.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		h.add_child(name)
		var opt := OptionButton.new()
		for r in ROLES:
			opt.add_item(r if r != "" else "—")
		var current: String = str(_roles.get(rid, ""))
		var idx := 0
		for j in ROLES.size():
			if ROLES[j].to_lower() == current.to_lower():
				idx = j
		opt.selected = idx
		opt.item_selected.connect(func(i):
			_roles[rid] = ROLES[i].to_lower() if i > 0 else "")
		h.add_child(opt)
		_roles_box.add_child(h)

func _save() -> void:
	var data := {
		"name": _name.text.strip_edges() if _name.text.strip_edges() != "" else "Equipo sin nombre",
		"abbr": _abbr.text,
		"country": _country.text,
		"category": ["WorldTour", "ProTeam", "Continental"][_category.selected],
		"color_primary": _color1.color.to_html(false),
		"color_secondary": _color2.color.to_html(false),
	}
	if _team_id >= 0:
		TeamRepo.update(_team_id, data)
		TeamRepo.set_roles(_team_id, _roles)
	else:
		_team_id = TeamRepo.create(data)
		TeamRepo.set_roles(_team_id, _roles)
	SignalBus.back_requested.emit()

class_name RiderSheet
extends BaseScreen
## Ficha del corredor: identidad + 14 atributos agrupados (PRD §25).

func _init(p: Dictionary = {}) -> void:
	super._init(p)

func _build() -> void:
	var rider := RiderRepo.get_by_id(int(payload.get("rider_id", -1)))
	if rider.is_empty():
		return
	var team := TeamRepo.get_by_id(int(rider.get("team_id", -1)))
	var r := Rider.from_row(rider)

	title = str(rider.get("name", ""))

	# Identidad.
	var ident := UIUtil.hbox(12)
	content.add_child(ident)
	var avatar := ColorRect.new()
	avatar.color = r.team_color
	avatar.custom_minimum_size = Vector2(48, 48)
	ident.add_child(avatar)
	var info := UIUtil.vbox(2)
	info.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	info.add_child(UIUtil.label("%s · %s años" % [r.nationality, r.age()], 14, Palette.TEXT))
	info.add_child(UIUtil.label("%s" % (team.get("name", "—") if not team.is_empty() else "—"), 13, Palette.MUTED))
	if r.specialty != "" and r.specialty != null:
		info.add_child(UIUtil.label("Especialidad: %s" % r.specialty, 12, Palette.ORANGE))
	ident.add_child(info)

	var edit := UIUtil.button("Editar", 36)
	edit.pressed.connect(func(): SignalBus.navigation_requested.emit("rider_editor", {"rider_id": int(payload.get("rider_id", -1))}))
	ident.add_child(edit)

	var scroll := add_scroll()

	# Atributos agrupados.
	var groups := [
		{"name": "TERRENO", "color": Palette.BLUE, "attrs": ["fla", "mm", "mnt", "hil", "cob"]},
		{"name": "ESPECIALIDADES", "color": Palette.ORANGE, "attrs": ["spr", "acc", "att", "dhi", "ttr", "prl"]},
		{"name": "FÍSICO", "color": Palette.GREEN, "attrs": ["sta", "res", "rec"]},
	]
	for g in groups:
		scroll.add_child(UIUtil.label(g.name, 12, g.color))
		for a in g.attrs:
			scroll.add_child(_attr_bar(a, r.attr(a)))

func _attr_bar(attr_key: String, value: int) -> Control:
	var box := UIUtil.vbox(2)
	var row := UIUtil.hbox(10)
	box.add_child(row)
	var label := UIUtil.label(Terrain.ATTR_LABEL.get(attr_key, attr_key), 13, Palette.TEXT)
	label.custom_minimum_size = Vector2(150, 0)
	row.add_child(label)
	var val := UIUtil.label(str(value), 13, Palette.YELLOW)
	val.custom_minimum_size = Vector2(30, 0)
	row.add_child(val)

	# Barra de atributo.
	var bar_bg := ColorRect.new()
	bar_bg.color = Color(0.09, 0.13, 0.17)
	bar_bg.custom_minimum_size = Vector2(0, 10)
	box.add_child(bar_bg)
	var fill := ColorRect.new()
	fill.color = Palette.ACCENT
	fill.anchor_right = clampf((value - 50.0) / 49.0, 0.0, 1.0)
	bar_bg.add_child(fill)
	return box

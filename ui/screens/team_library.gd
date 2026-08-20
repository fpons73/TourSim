class_name TeamLibrary
extends BaseScreen
## Biblioteca de equipos (PRD §27, §30).

var _list: VBoxContainer

func _init(p: Dictionary = {}) -> void:
	title = "Equipos"
	subtitle = "%d equipos" % TeamRepo.count()
	super._init(p)

func _build() -> void:
	if payload.get("mode", "view") == "manage":
		var new_btn := UIUtil.button("+ Nuevo equipo", 40)
		new_btn.pressed.connect(func(): SignalBus.navigation_requested.emit("team_editor", {}))
		content.add_child(new_btn)
	_list = add_scroll()
	_reload()

func _reload() -> void:
	UIUtil.clear(_list)
	var teams := TeamRepo.get_all()
	for row in teams:
		_list.add_child(_make_card(row))

func _make_card(row: Dictionary) -> Control:
	var team := Team.from_row(row)
	var card := UIUtil.panel()
	var box := UIUtil.hbox(10)
	card.add_child(box)

	var swatch := ColorRect.new()
	swatch.color = team.color_primary
	swatch.custom_minimum_size = Vector2(10, 0)
	swatch.size_flags_vertical = Control.SIZE_EXPAND_FILL
	box.add_child(swatch)
	var swatch2 := ColorRect.new()
	swatch2.color = team.color_secondary
	swatch2.custom_minimum_size = Vector2(4, 0)
	swatch2.size_flags_vertical = Control.SIZE_EXPAND_FILL
	box.add_child(swatch2)

	var texts := UIUtil.vbox(0)
	texts.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	texts.add_child(UIUtil.label(str(row.get("name", "")), 15, Palette.TEXT))
	texts.add_child(UIUtil.label("%s · %s · %s · %d corredores" % [
		str(row.get("abbr", "")), str(row.get("country", "")),
		str(row.get("category", "")), TeamRepo.rider_count(int(row["id"]))], 11, Palette.MUTED))
	box.add_child(texts)

	var mode: String = payload.get("mode", "view")
	if mode == "manage":
		var edit := UIUtil.button("Editar", 34)
		edit.pressed.connect(func(): SignalBus.navigation_requested.emit("team_editor", {"team_id": int(row["id"])}))
		box.add_child(edit)
		var dele := UIUtil.button("Eliminar", 34)
		dele.pressed.connect(func():
			TeamRepo.delete(int(row["id"]))
			_reload())
		box.add_child(dele)
	else:
		var view := UIUtil.button("Ver", 34)
		view.pressed.connect(func(): SignalBus.navigation_requested.emit("team_detail", {"team_id": int(row["id"])}))
		box.add_child(view)
	return card

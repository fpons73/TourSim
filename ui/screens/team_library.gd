class_name TeamLibrary
extends BaseScreen
## Biblioteca de equipos (PRD §27, §30).

var _list: VBoxContainer

func _init(p: Dictionary = {}) -> void:
	title = "Equipos"
	subtitle = "%d equipos" % TeamRepo.count()
	super._init(p)

func _build() -> void:
	_list = add_scroll()
	_reload()

func _reload() -> void:
	UIUtil.clear(_list)
	var teams := TeamRepo.get_all()
	for row in teams:
		_list.add_child(_make_card(row))

func _make_card(row: Dictionary) -> Control:
	var team := Team.from_row(row)
	var btn := Button.new()
	btn.custom_minimum_size = Vector2(0, 48)
	btn.pressed.connect(func(): SignalBus.navigation_requested.emit("team_detail", {"team_id": int(row["id"])}))
	var row_ui := UIUtil.hbox(10)
	row_ui.mouse_filter = Control.MOUSE_FILTER_IGNORE
	btn.add_child(row_ui)
	row_ui.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var swatch := ColorRect.new()
	swatch.color = team.color_primary
	swatch.custom_minimum_size = Vector2(10, 0)
	swatch.size_flags_vertical = Control.SIZE_EXPAND_FILL
	row_ui.add_child(swatch)
	var swatch2 := ColorRect.new()
	swatch2.color = team.color_secondary
	swatch2.custom_minimum_size = Vector2(4, 0)
	swatch2.size_flags_vertical = Control.SIZE_EXPAND_FILL
	row_ui.add_child(swatch2)
	var texts := UIUtil.vbox(0)
	texts.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	texts.add_child(UIUtil.label(str(row.get("name", "")), 15, Palette.TEXT))
	var sub := "%s · %s · %s · %d corredores" % [
		str(row.get("abbr", "")), str(row.get("country", "")),
		str(row.get("category", "")), TeamRepo.rider_count(int(row["id"]))]
	texts.add_child(UIUtil.label(sub, 11, Palette.MUTED))
	row_ui.add_child(texts)
	row_ui.add_child(UIUtil.label("›", 20, Palette.MUTED))
	return btn

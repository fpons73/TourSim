class_name TeamDetail
extends BaseScreen
## Detalle de un equipo: plantilla de corredores.

var _list: VBoxContainer

func _init(p: Dictionary = {}) -> void:
	super._init(p)

func _build() -> void:
	var team_id := int(payload.get("team_id", -1))
	var team := TeamRepo.get_by_id(team_id)
	if team.is_empty():
		return
	title = str(team.get("name", "Equipo"))
	subtitle = "%s · %s · %s" % [team.get("abbr", ""), team.get("country", ""), team.get("category", "")]

	var swatch := ColorRect.new()
	swatch.color = Team.from_row(team).color_primary
	swatch.custom_minimum_size = Vector2(0, 6)
	content.add_child(swatch)

	_list = add_scroll()
	var riders := TeamRepo.get_riders(team_id)
	_list.add_child(UIUtil.label("OBJETIVO: %s" % TeamAI.objective(riders), 12, Palette.YELLOW))
	for row in riders:
		_list.add_child(_rider_row(row))

func _rider_row(row: Dictionary) -> Control:
	var btn := Button.new()
	btn.custom_minimum_size = Vector2(0, 40)
	btn.pressed.connect(func(): SignalBus.navigation_requested.emit("rider_sheet", {"rider_id": int(row["id"])}))
	var row_ui := UIUtil.hbox(10)
	row_ui.mouse_filter = Control.MOUSE_FILTER_IGNORE
	btn.add_child(row_ui)
	row_ui.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var name := UIUtil.label(str(row.get("name", "")), 14, Palette.TEXT)
	name.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row_ui.add_child(name)
	row_ui.add_child(UIUtil.label(_top_attr(row), 12, Palette.MUTED))
	row_ui.add_child(UIUtil.label("›", 16, Palette.MUTED))
	return btn

func _top_attr(row: Dictionary) -> String:
	var best := "spr"
	var best_v := -1
	for a in Terrain.ATTRS:
		var v := int(row.get(a, 50))
		if v > best_v:
			best_v = v
			best = a
	return "%s %d" % [Terrain.ATTR_LABEL.get(best, best), best_v]

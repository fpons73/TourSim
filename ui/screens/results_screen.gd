class_name ResultsScreen
extends BaseScreen
## Pantalla de resultados de una etapa o carrera.

func _init(p: Dictionary = {}) -> void:
	title = "Resultados"
	super._init(p)

func _build() -> void:
	var res: Dictionary = payload.get("results", {})
	var is_race: bool = payload.get("race", false)

	var scroll := add_scroll()

	if is_race:
		scroll.add_child(UIUtil.label("%s %s" % [res.get("race_name", ""), res.get("edition", "")], 20, Palette.YELLOW))
		var sw: Array = res.get("stage_winners", [])
		for s in sw:
			scroll.add_child(UIUtil.label("· %s — %s" % [s.get("stage", ""), s.get("winner", "")], 13, Palette.MUTED))
	else:
		var winner := str(res.get("winner_name", ""))
		if str(res.get("stage_name", "")) != "":
			scroll.add_child(UIUtil.label(str(res.get("stage_name", "")), 18, Palette.TEXT))
		scroll.add_child(UIUtil.label("Ganador: %s" % winner, 20, Palette.YELLOW))

	scroll.add_child(UIUtil.spacer(8))

	# Clasificación general.
	scroll.add_child(UIUtil.label("CLASIFICACIÓN", 13, Palette.BLUE))
	var gc: Array = res.get("gc", [])
	scroll.add_child(_ranking_table(gc, "gap"))

	if not is_race:
		scroll.add_child(UIUtil.spacer(8))
		scroll.add_child(UIUtil.label("PUNTOS", 13, Palette.GREEN))
		scroll.add_child(_ranking_table(res.get("points", []), "points"))
		scroll.add_child(UIUtil.spacer(8))
		scroll.add_child(UIUtil.label("MONTAÑA", 13, Palette.VIOLET))
		scroll.add_child(_ranking_table(res.get("mountain", []), "points"))

	var back := UIUtil.button("Volver al inicio", 44)
	back.pressed.connect(func(): SignalBus.navigation_requested.emit("home", {}))
	scroll.add_child(UIUtil.spacer(8))
	scroll.add_child(back)

func _ranking_table(entries: Array, value_key: String) -> Control:
	var box := UIUtil.vbox(2)
	for i in mini(15, entries.size()):
		var e: Dictionary = entries[i]
		var row := UIUtil.hbox(8)
		box.add_child(row)
		var pos := UIUtil.label("%2d" % e.get("pos", i + 1), 13, Palette.MUTED)
		pos.custom_minimum_size = Vector2(28, 0)
		row.add_child(pos)
		var dot := ColorRect.new()
		dot.color = e.get("team_color", Palette.MUTED)
		dot.custom_minimum_size = Vector2(4, 16)
		row.add_child(dot)
		var name := UIUtil.label(str(e.get("name", "")), 13, Palette.TEXT)
		name.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		row.add_child(name)
		if value_key == "gap":
			row.add_child(UIUtil.label(UIUtil.fmt_gap(float(e.get("gap", 0.0))), 13, Palette.TEXT))
		else:
			row.add_child(UIUtil.label(str(e.get(value_key, "")), 13, Palette.TEXT))
	return box

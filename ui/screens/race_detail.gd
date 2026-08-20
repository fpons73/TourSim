class_name RaceDetail
extends BaseScreen
## Detalle de una carrera: lista de etapas (jugables individualmente).

func _init(p: Dictionary = {}) -> void:
	super._init(p)

func _build() -> void:
	var race := RaceRepo.get_by_id(int(payload.get("race_id", -1)))
	if race.is_empty():
		return
	title = "%s %s" % [race.get("name", ""), race.get("edition", "")]
	subtitle = "%s · %d etapas" % [race.get("country", ""), RaceRepo.get_stage_ids(int(race["id"])).size()]

	var scroll := add_scroll()
	for sid in RaceRepo.get_stage_ids(int(race["id"])):
		var srow := StageRepo.get_by_id(int(sid))
		if srow.is_empty():
			continue
		var stage := Stage.from_row(srow)
		var card := UIUtil.panel()
		scroll.add_child(card)
		var box := UIUtil.vbox(8)
		card.add_child(box)
		var head := UIUtil.hbox(10)
		box.add_child(head)
		var titles := UIUtil.vbox(0)
		titles.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		titles.add_child(UIUtil.label(str(srow.get("name", "")), 15, Palette.TEXT))
		titles.add_child(UIUtil.label("%s · %.0f km" % [
			Terrain.STAGE_TYPES.get(srow.get("type", "flat"), srow.get("type")),
			float(srow.get("distance", 0.0))], 12, Palette.MUTED))
		head.add_child(titles)
		var play := UIUtil.button("▶", 36)
		play.custom_minimum_size = Vector2(48, 36)
		play.pressed.connect(func(): _play(srow))
		head.add_child(play)
		var chart := ProfileChart.new(stage)
		box.add_child(chart)

func _play(row: Dictionary) -> void:
	var seed := int(Time.get_ticks_msec() % 1000000000)
	var res := RaceSim.run_stage(row, seed)
	res["seed"] = seed
	SignalBus.navigation_requested.emit("results", {"results": res})

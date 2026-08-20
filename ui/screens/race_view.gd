class_name RaceView
extends BaseScreen
## Pantalla de carrera en vivo (PRD §17-24): perfil, grupos, feed y controles.

var _state: RaceState
var _stage: Stage
var _seed_int: int
var _timer: Timer
var _running: bool = false
var _shown_events: int = 0

var _km_label: Label
var _time_label: Label
var _chart: ProfileChart
var _groups_box: VBoxContainer
var _feed_box: VBoxContainer
var _feed_scroll: ScrollContainer

func _init(p: Dictionary = {}) -> void:
	show_back = true
	title = "Carrera"
	super._init(p)

func _build() -> void:
	_stage = Stage.from_row(StageRepo.get_by_id(int(payload.get("stage_id", -1))))
	var rows := RaceSim.build_rows(GameState.participants)
	_seed_int = RNG.hash_string(GameState.seed)
	_state = RaceState.new()
	_state.setup(_stage, rows["rider_rows"], rows["team_rows"], _seed_int)

	title = _stage.name
	subtitle = "seed %s · %s" % [GameState.seed, GameState.mode]

	_build_top_bar()
	_build_body()
	_start()

func _build_top_bar() -> void:
	var bar := UIUtil.hbox(8)
	content.add_child(bar)

	_km_label = UIUtil.label("0 km", 16, Palette.TEXT)
	_km_label.custom_minimum_size = Vector2(90, 0)
	bar.add_child(_km_label)

	_time_label = UIUtil.label("0' 00\"", 16, Palette.TEXT)
	_time_label.custom_minimum_size = Vector2(110, 0)
	bar.add_child(_time_label)

	var sep := UIUtil.label("|", 16, Palette.MUTED)
	bar.add_child(sep)

	var mode_label := UIUtil.label("MODO: %s" % GameState.mode.to_upper(), 13, Palette.YELLOW)
	bar.add_child(mode_label)

	bar.add_child(UIUtil.label("SEED: %s" % GameState.seed, 13, Palette.MUTED))

	var spacer := Control.new()
	spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	bar.add_child(spacer)

	var pause := UIUtil.button("⏸", 38)
	pause.pressed.connect(func(): _set_running(false))
	bar.add_child(pause)
	var play := UIUtil.button("▶", 38)
	play.pressed.connect(func(): _set_running(true))
	bar.add_child(play)
	var jump := UIUtil.button("⏭ Fin", 38)
	jump.pressed.connect(func(): _finish_now())
	bar.add_child(jump)

func _build_body() -> void:
	var body := UIUtil.hbox(10)
	body.size_flags_vertical = Control.SIZE_EXPAND_FILL
	content.add_child(body)

	# Zona central.
	var center := UIUtil.vbox(8)
	center.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	body.add_child(center)

	_chart = ProfileChart.new(_stage)
	_chart.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_chart.custom_minimum_size = Vector2(0, 200)
	center.add_child(_chart)

	center.add_child(UIUtil.label("GRUPOS", 12, Palette.BLUE))
	_groups_box = UIUtil.vbox(4)
	center.add_child(_groups_box)

	# Panel derecho: feed.
	var right := UIUtil.vbox(6)
	right.custom_minimum_size = Vector2(360, 0)
	body.add_child(right)
	right.add_child(UIUtil.label("RACE FEED", 12, Palette.ORANGE))
	_feed_scroll = ScrollContainer.new()
	_feed_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_feed_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	right.add_child(_feed_scroll)
	_feed_box = UIUtil.vbox(6)
	_feed_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_feed_scroll.add_child(_feed_box)

func _start() -> void:
	if GameState.speed == "instant":
		_finish_now()
		return
	_timer = Timer.new()
	_timer.wait_time = _interval()
	_timer.timeout.connect(_tick)
	add_child(_timer)
	_timer.start()
	_running = true

func _interval() -> float:
	match GameState.speed:
		"fast":
			return 0.3
		"very_fast":
			return 0.08
		_:
			return 0.9

func _set_running(v: bool) -> void:
	_running = v
	if _timer != null:
		if v:
			_timer.start()
		else:
			_timer.stop()

func _tick() -> void:
	if not _running:
		return
	_step()
	if _state.finished and _timer != null:
		_timer.stop()

func _step() -> void:
	var snap := _state.step()
	_apply_snapshot(snap)
	if _state.finished:
		_on_finished()

func _finish_now() -> void:
	if _timer != null:
		_timer.stop()
	while not _state.finished:
		var snap := _state.step()
		_apply_snapshot(snap)
	_on_finished()

func _apply_snapshot(snap: Dictionary) -> void:
	_km_label.text = "%.0f km" % float(snap.get("km", 0.0))
	_time_label.text = UIUtil.fmt_time(float(snap.get("elapsed", 0.0)))
	_chart.set_marker(float(snap.get("km", 0.0)))
	_refresh_groups(snap.get("groups", []))
	_refresh_feed(snap.get("events", []))

func _refresh_groups(gs: Array) -> void:
	UIUtil.clear(_groups_box)
	for g in gs:
		var row := UIUtil.hbox(8)
		_groups_box.add_child(row)
		var name := UIUtil.label(str(g.get("name", "")), 14, Palette.TEXT)
		name.custom_minimum_size = Vector2(120, 0)
		row.add_child(name)
		var count := UIUtil.label("%d corredores" % int(g.get("rider_count", 0)), 12, Palette.MUTED)
		count.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		row.add_child(count)
		var gap := UIUtil.label(UIUtil.fmt_gap(float(g.get("gap", 0.0))), 13, Palette.YELLOW)
		row.add_child(gap)
		# Colores de equipos.
		var riders: Array = g.get("riders", [])
		for r in riders.slice(0, 4):
			var dot := ColorRect.new()
			dot.color = r.get("color", Palette.MUTED)
			dot.custom_minimum_size = Vector2(6, 6)
			row.add_child(dot)

func _refresh_feed(events: Array) -> void:
	if events.size() <= _shown_events:
		return
	var new_events: Array = []
	for i in range(_shown_events, events.size()):
		new_events.append(events[i])
	_shown_events = events.size()
	for e in new_events:
		_feed_box.add_child(_feed_entry(e))

func _feed_entry(e: Dictionary) -> Control:
	var box := UIUtil.vbox(2)
	var meta: Dictionary = EventLog.TYPE_META.get(str(e.get("type", "info")), {"icon": "•", "color": "muted"})
	var head := UIUtil.hbox(6)
	head.add_child(UIUtil.label(str(meta.get("icon", "•")), 13, Palette.TEXT))
	var title := UIUtil.label(str(e.get("title", "")), 13, Palette.TEXT)
	head.add_child(title)
	var km_label := UIUtil.label("km %.0f" % float(e.get("km", 0.0)), 11, Palette.MUTED)
	km_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	km_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	head.add_child(km_label)
	box.add_child(head)
	var text := str(e.get("text", ""))
	if text != "":
		var t := UIUtil.label(text, 12, Palette.MUTED)
		t.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		box.add_child(t)
	return box

func _on_finished() -> void:
	_running = false
	var results := _state.get_results()
	results["seed"] = GameState.seed
	# Guardar en histórico.
	HistoryRepo.save_simulation({
		"date": Time.get_datetime_string_from_system(),
		"seed": GameState.seed,
		"mode": GameState.mode,
		"ref_type": "stage",
		"ref_id": int(payload.get("stage_id", -1)),
		"results_json": JSON.stringify(results),
		"classifications_json": JSON.stringify({
			"gc": results.get("gc", []),
			"points": results.get("points", []),
			"mountain": results.get("mountain", []),
		}),
		"events_json": JSON.stringify(results.get("events", [])),
		"decisions_json": "[]",
	})
	SignalBus.navigation_requested.emit("results", {"results": results})

class_name MatchSetupScreen
extends BaseScreen
## Configuración de la partida (PRD §13): control, velocidad, dados, seed.

var _mode: OptionButton
var _team: OptionButton
var _speed: OptionButton
var _dice: OptionButton
var _seed_input: LineEdit
var _show_seed: CheckBox

func _init(p: Dictionary = {}) -> void:
	title = "Configuración de partida"
	super._init(p)

func _build() -> void:
	var scroll := add_scroll()

	_mode = OptionButton.new()
	_mode.add_item("Modo Espectador")
	_mode.add_item("Controlar un equipo")
	_mode.item_selected.connect(func(i): _refresh_team())
	scroll.add_child(UIUtil.form_row("Control", _mode))

	_team = OptionButton.new()
	_team.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_team.visible = false
	scroll.add_child(UIUtil.form_row("Tu equipo", _team))

	_speed = OptionButton.new()
	for s in ["Normal", "Rápido", "Muy rápido", "Resolución instantánea"]:
		_speed.add_item(s)
	_speed.selected = 1
	scroll.add_child(UIUtil.form_row("Velocidad", _speed))

	_dice = OptionButton.new()
	_dice.add_item("Dados animados")
	_dice.add_item("Dados instantáneos")
	scroll.add_child(UIUtil.form_row("Dados", _dice))

	_show_seed = CheckBox.new()
	_show_seed.button_pressed = true
	_show_seed.text = "Mostrar seed"
	scroll.add_child(UIUtil.form_row("Seed", _show_seed))

	_seed_input = LineEdit.new()
	_seed_input.placeholder_text = "Introducir seed (opcional)"
	_seed_input.custom_minimum_size = Vector2(0, 40)
	scroll.add_child(UIUtil.form_row("", _seed_input))

	var go := UIUtil.button("Iniciar", 46)
	go.pressed.connect(func(): _start())
	scroll.add_child(go)

	_refresh_team()

func _refresh_team() -> void:
	_team.clear()
	for p in GameState.participants:
		var t := TeamRepo.get_by_id(int(p.get("team_id", -1)))
		if not t.is_empty():
			_team.add_item(str(t.get("name", "")))
			_team.set_item_metadata(_team.item_count - 1, int(t.get("id", -1)))
	_team.visible = _mode.selected == 1

func _start() -> void:
	GameState.mode = "control" if _mode.selected == 1 else "spectator"
	if GameState.mode == "control" and _team.item_count > 0:
		GameState.player_team_id = int(_team.get_item_metadata(_team.selected))
	else:
		GameState.player_team_id = -1
	var speeds := ["normal", "fast", "very_fast", "instant"]
	GameState.speed = speeds[_speed.selected]
	GameState.dice_animated = _dice.selected == 0
	GameState.show_seed = _show_seed.button_pressed

	var seed_text := _seed_input.text.strip_edges()
	if seed_text != "":
		GameState.seed = seed_text
	elif Config.default_seed != "":
		GameState.seed = Config.default_seed
	else:
		GameState.seed = str(int(Time.get_ticks_msec() % 1000000000))

	if payload.has("race_id"):
		# Carrera: resolución instantánea de la GC completa.
		var race := Race.from_row(RaceRepo.get_by_id(int(payload.get("race_id", -1))))
		var seed_i := RNG.hash_string(GameState.seed)
		var res := RaceSim.run_race_with(race, GameState.participants, seed_i)
		res["seed"] = GameState.seed
		HistoryRepo.save_simulation({
			"date": Time.get_datetime_string_from_system(),
			"seed": GameState.seed,
			"mode": GameState.mode,
			"ref_type": "race",
			"ref_id": int(payload.get("race_id", -1)),
			"results_json": JSON.stringify(res),
			"classifications_json": JSON.stringify({"gc": res.get("gc", [])}),
			"events_json": "[]",
			"decisions_json": "[]",
		})
		SignalBus.navigation_requested.emit("results", {"results": res, "race": true})
	else:
		SignalBus.navigation_requested.emit("race_view", payload)

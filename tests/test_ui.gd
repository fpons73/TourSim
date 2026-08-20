extends Node
## Smoke test de UI: instancia la app y navega por pantallas clave.

const App = preload("res://ui/app.gd")

func _ready() -> void:
	var app: Control = App.new()
	add_child(app)
	await _frames(2)

	SignalBus.navigation_requested.emit("stage_library", {"mode": "run"})
	await _frames(2)

	var stages := StageRepo.get_all()
	var res := RaceSim.run_stage(stages[0], 1234)
	res["seed"] = 1234
	SignalBus.navigation_requested.emit("results", {"results": res})
	await _frames(2)

	SignalBus.navigation_requested.emit("race_library", {"mode": "run"})
	await _frames(2)

	var race: Dictionary = RaceRepo.get_all()[0]
	var rres := RaceSim.run_race(Race.from_row(race), 999)
	SignalBus.navigation_requested.emit("results", {"results": rres, "race": true})
	await _frames(2)

	SignalBus.navigation_requested.emit("team_library", {})
	await _frames(2)
	SignalBus.navigation_requested.emit("team_detail", {"team_id": 1})
	await _frames(2)
	SignalBus.navigation_requested.emit("rider_library", {})
	await _frames(2)
	SignalBus.navigation_requested.emit("rider_sheet", {"rider_id": 1})
	await _frames(2)
	SignalBus.navigation_requested.emit("settings", {})
	await _frames(2)
	SignalBus.navigation_requested.emit("history", {})
	await _frames(2)

	SignalBus.navigation_requested.emit("stage_editor", {})
	await _frames(2)
	SignalBus.navigation_requested.emit("stage_editor", {"stage_id": 1})
	await _frames(2)
	SignalBus.navigation_requested.emit("race_editor", {})
	await _frames(2)
	SignalBus.navigation_requested.emit("team_editor", {"team_id": 1})
	await _frames(2)
	SignalBus.navigation_requested.emit("rider_editor", {"rider_id": 1})
	await _frames(2)

	SignalBus.navigation_requested.emit("participants", {"stage_id": 1})
	await _frames(2)
	SignalBus.navigation_requested.emit("match_setup", {"stage_id": 1})
	await _frames(2)

	# Race view con resolución instantánea.
	GameState.participants = _make_participants()
	GameState.mode = "spectator"
	GameState.seed = "testseed"
	GameState.speed = "instant"
	SignalBus.navigation_requested.emit("race_view", {"stage_id": 1})
	await _frames(5)

	# Race view en modo control (equipo 1).
	GameState.mode = "control"
	GameState.player_team_id = 1
	SignalBus.navigation_requested.emit("race_view", {"stage_id": 1})
	await _frames(5)

	SignalBus.navigation_requested.emit("home", {})
	await _frames(2)

	print("UI TEST OK")
	get_tree().quit()

func _frames(n: int) -> void:
	for i in n:
		await get_tree().process_frame

func _make_participants() -> Array:
	var out: Array = []
	var teams := TeamRepo.get_all().slice(0, 5)
	for t in teams:
		var riders := TeamRepo.get_riders(int(t["id"])).slice(0, 8)
		var ids: Array = []
		for r in riders:
			ids.append(int(r["id"]))
		out.append({"team_id": int(t["id"]), "rider_ids": ids})
	return out

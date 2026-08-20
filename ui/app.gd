extends Control
## Host de pantallas: gestiona la navegación de la aplicación.

const HomeScreen = preload("res://ui/screens/home_screen.gd")
const MenuScreen = preload("res://ui/screens/menu_screen.gd")
const StageLibrary = preload("res://ui/screens/stage_library.gd")
const RaceLibrary = preload("res://ui/screens/race_library.gd")
const RaceDetail = preload("res://ui/screens/race_detail.gd")
const TeamLibrary = preload("res://ui/screens/team_library.gd")
const TeamDetail = preload("res://ui/screens/team_detail.gd")
const RiderLibrary = preload("res://ui/screens/rider_library.gd")
const RiderSheet = preload("res://ui/screens/rider_sheet.gd")
const ResultsScreen = preload("res://ui/screens/results_screen.gd")
const SettingsScreen = preload("res://ui/screens/settings_screen.gd")
const HistoryScreen = preload("res://ui/screens/history_screen.gd")
const StageEditor = preload("res://ui/screens/stage_editor.gd")
const RaceEditor = preload("res://ui/screens/race_editor.gd")
const TeamEditor = preload("res://ui/screens/team_editor.gd")
const RiderEditor = preload("res://ui/screens/rider_editor.gd")
const PlaceholderScreen = preload("res://ui/screens/placeholder_screen.gd")

var _stack: Array = []
var _current: Control = null

func _ready() -> void:
	SignalBus.navigation_requested.connect(_on_nav)
	SignalBus.back_requested.connect(_go_back)
	_push("home", {})

func _on_nav(destination: String, payload: Variant) -> void:
	_push(destination, payload)

func _push(destination: String, payload: Variant) -> void:
	var screen := _make_screen(destination, payload)
	if screen == null:
		return
	if _current != null:
		_current.queue_free()
	add_child(screen)
	_stack.append({"dest": destination, "payload": payload})
	_current = screen

func _go_back() -> void:
	if _stack.size() <= 1:
		return
	_stack.pop_back()
	var top: Dictionary = _stack[_stack.size() - 1]
	if _current != null:
		_current.queue_free()
	_current = _make_screen(top.get("dest", "home"), top.get("payload", {}))
	add_child(_current)

func _make_screen(destination: String, payload: Variant) -> Control:
	var p: Dictionary = payload if payload is Dictionary else {}
	match destination:
		"home":
			return HomeScreen.new(p)
		"run_menu":
			return MenuScreen.new({
				"title": "Correr",
				"subtitle": "Elige qué quieres correr",
				"items": [
					{"title": "Correr una etapa", "desc": "Biblioteca de etapas", "dest": "stage_library", "payload": {"mode": "run"}},
					{"title": "Correr una carrera", "desc": "Biblioteca de carreras", "dest": "race_library", "payload": {"mode": "run"}},
				],
			})
		"create_menu":
			return MenuScreen.new({
				"title": "Crear",
				"subtitle": "Crea contenido nuevo",
				"items": [
					{"title": "Crear etapa", "desc": "Stage Editor", "dest": "stage_editor", "payload": {}},
					{"title": "Crear carrera", "desc": "Race Editor", "dest": "race_editor", "payload": {}},
					{"title": "Crear equipo", "desc": "Team Editor", "dest": "team_editor", "payload": {}},
					{"title": "Crear corredor", "desc": "Rider Editor", "dest": "rider_editor", "payload": {}},
				],
			})
		"edit_menu":
			return MenuScreen.new({
				"title": "Editar",
				"subtitle": "Gestiona el contenido",
				"items": [
					{"title": "Editar etapas", "desc": "Duplicar, editar y eliminar etapas", "dest": "stage_library", "payload": {"mode": "manage"}},
					{"title": "Editar carreras", "desc": "Gestionar carreras", "dest": "race_library", "payload": {"mode": "manage"}},
					{"title": "Editar equipos", "desc": "Colores, roles y plantilla", "dest": "team_library", "payload": {"mode": "manage"}},
					{"title": "Editar corredores", "desc": "Atributos y datos", "dest": "rider_library", "payload": {}},
				],
			})
		"stage_library":
			return StageLibrary.new(p)
		"race_library":
			return RaceLibrary.new(p)
		"race_detail":
			return RaceDetail.new(p)
		"team_library":
			return TeamLibrary.new(p)
		"team_detail":
			return TeamDetail.new(p)
		"rider_library":
			return RiderLibrary.new(p)
		"rider_sheet":
			return RiderSheet.new(p)
		"results":
			return ResultsScreen.new(p)
		"settings":
			return SettingsScreen.new(p)
		"history":
			return HistoryScreen.new(p)
		"stage_editor":
			return StageEditor.new(p)
		"race_editor":
			return RaceEditor.new(p)
		"team_editor":
			return TeamEditor.new(p)
		"rider_editor":
			return RiderEditor.new(p)
		_:
			return PlaceholderScreen.new({"title": destination})

	return null

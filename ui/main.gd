extends Control
## Menú principal — pantalla inicial de la aplicación (PRD §6).

var _sections := [
	{"key": "run", "title": "Correr", "desc": "Etapa o carrera"},
	{"key": "create", "title": "Crear", "desc": "Etapa o carrera"},
	{"key": "edit", "title": "Editar", "desc": "Etapas, carreras, equipos y corredores"},
	{"key": "history", "title": "Histórico", "desc": "Resultados y estadísticas"},
	{"key": "settings", "title": "Configuración", "desc": "Idioma, sonido, tema, seed"},
]

func _ready() -> void:
	_build_ui()

func _build_ui() -> void:
	var bg := ColorRect.new()
	bg.color = Palette.BG
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(bg)

	var center := VBoxContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	center.custom_minimum_size = Vector2(520, 0)
	center.add_theme_constant_override("separation", 12)
	add_child(center)

	var title := Label.new()
	title.text = "PRO CYCLING REPLAY MANAGER"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 30)
	title.add_theme_color_override("font_color", Palette.YELLOW)
	center.add_child(title)

	var subtitle := Label.new()
	subtitle.text = "Simulador táctico / Replay Manager"
	subtitle.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	subtitle.add_theme_color_override("font_color", Palette.MUTED)
	center.add_child(subtitle)

	var spacer := Control.new()
	spacer.custom_minimum_size = Vector2(0, 20)
	center.add_child(spacer)

	for s in _sections:
		var btn := Button.new()
		btn.text = "%s   —   %s" % [s.title, s.desc]
		btn.custom_minimum_size = Vector2(0, 46)
		btn.pressed.connect(_on_section.bind(s.key))
		center.add_child(btn)

	var footer := Label.new()
	footer.text = "Godot 4.x  ·  V3.0"
	footer.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	footer.add_theme_color_override("font_color", Palette.MUTED)
	footer.add_theme_font_size_override("font_size", 12)
	footer.vertical_alignment = VERTICAL_ALIGNMENT_BOTTOM
	footer.custom_minimum_size = Vector2(0, 24)
	center.add_child(footer)

func _on_section(key: String) -> void:
	print("[MainMenu] Sección: ", key)
	SignalBus.navigation_requested.emit(key, {})

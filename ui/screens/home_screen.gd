class_name HomeScreen
extends BaseScreen
## Menú principal (PRD §6).

func _init(p: Dictionary = {}) -> void:
	show_back = false
	title = "PRO CYCLING REPLAY MANAGER"
	subtitle = "Simulador táctico / Replay Manager  ·  V3.0"
	super._init(p)

func _build() -> void:
	var sections := [
		{"key": "run_menu", "title": "Correr", "desc": "Correr una etapa o una carrera", "color": Palette.GREEN},
		{"key": "create_menu", "title": "Crear", "desc": "Nueva etapa o nueva carrera", "color": Palette.BLUE},
		{"key": "edit_menu", "title": "Editar", "desc": "Etapas, carreras, equipos y corredores", "color": Palette.ORANGE},
		{"key": "history", "title": "Histórico", "desc": "Resultados y estadísticas", "color": Palette.VIOLET},
		{"key": "settings", "title": "Configuración", "desc": "Idioma, sonido, tema, seed", "color": Palette.MUTED},
	]
	for s in sections:
		var btn := Button.new()
		btn.custom_minimum_size = Vector2(0, 64)
		btn.text = ""
		btn.pressed.connect(func(k = s.key): SignalBus.navigation_requested.emit(k, {}))
		content.add_child(btn)

		var row := UIUtil.hbox(12)
		row.mouse_filter = Control.MOUSE_FILTER_IGNORE
		btn.add_child(row)
		row.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		var bar := ColorRect.new()
		bar.color = s.color
		bar.custom_minimum_size = Vector2(6, 0)
		bar.size_flags_vertical = Control.SIZE_EXPAND_FILL
		row.add_child(bar)
		var texts := UIUtil.vbox(0)
		texts.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		texts.add_child(UIUtil.label(s.title, 20, Palette.TEXT))
		texts.add_child(UIUtil.label(s.desc, 12, Palette.MUTED))
		row.add_child(texts)
		row.add_child(UIUtil.label("›", 22, Palette.MUTED))

	var footer := UIUtil.label("Godot 4.x  ·  Pro Cycling Replay Manager V3.0", 12, Palette.MUTED, HORIZONTAL_ALIGNMENT_CENTER)
	content.add_child(footer)

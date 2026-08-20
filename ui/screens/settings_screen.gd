class_name SettingsScreen
extends BaseScreen
## Configuración (PRD §6, §13). Versión básica.

func _init(p: Dictionary = {}) -> void:
	title = "Configuración"
	subtitle = "Preferencias de la aplicación"
	super._init(p)

func _build() -> void:
	var box := UIUtil.vbox(10)
	content.add_child(box)

	box.add_child(_toggle("Sonido", "sound_enabled"))
	box.add_child(_toggle("Animaciones", "animations_enabled"))
	box.add_child(_toggle("Dados animados", "dice_animated"))
	box.add_child(_toggle("Mostrar seed", "show_seed"))

	box.add_child(UIUtil.spacer(6))
	box.add_child(UIUtil.label("Seed por defecto (vacío = aleatoria)", 13, Palette.MUTED))
	var seed_input := LineEdit.new()
	seed_input.text = Config.default_seed
	seed_input.placeholder_text = "aleatoria"
	seed_input.custom_minimum_size = Vector2(0, 40)
	seed_input.text_changed.connect(func(t): Config.default_seed = t)
	box.add_child(seed_input)

	box.add_child(UIUtil.spacer(6))
	box.add_child(UIUtil.label("Idioma", 13, Palette.MUTED))
	var lang := OptionButton.new()
	lang.custom_minimum_size = Vector2(0, 40)
	lang.add_item("Español")
	lang.add_item("English")
	lang.selected = 0 if Config.language == "es" else 1
	lang.item_selected.connect(func(i): Config.language = "es" if i == 0 else "en")
	box.add_child(lang)

	var save := UIUtil.button("Guardar configuración", 44)
	save.pressed.connect(func(): Config.save())
	box.add_child(save)

	var io := UIUtil.button("Importar / Exportar datos", 44)
	io.pressed.connect(func(): SignalBus.navigation_requested.emit("data_io", {}))
	box.add_child(io)

func _toggle(text: String, key: String) -> Control:
	var row := UIUtil.hbox(10)
	var lab := UIUtil.label(text, 15, Palette.TEXT)
	lab.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(lab)
	var cb := CheckBox.new()
	cb.button_pressed = bool(Config.get(key))
	cb.toggled.connect(func(v): Config.set(key, v))
	row.add_child(cb)
	return row

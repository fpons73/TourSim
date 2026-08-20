class_name BaseScreen
extends Control
## Pantalla base: fondo, cabecera (título + volver) y contenedor de contenido.

var payload: Dictionary = {}
var show_back: bool = true
var title: String = ""
var subtitle: String = ""

var content: VBoxContainer

func _init(p: Dictionary = {}) -> void:
	payload = p

func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_build_structure()
	_build()

func _build_structure() -> void:
	var bg := ColorRect.new()
	bg.color = Palette.BG
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(bg)

	var margin := MarginContainer.new()
	margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	margin.add_theme_constant_override("margin_left", 28)
	margin.add_theme_constant_override("margin_right", 28)
	margin.add_theme_constant_override("margin_top", 20)
	margin.add_theme_constant_override("margin_bottom", 20)
	add_child(margin)

	var col := UIUtil.vbox(6)
	margin.add_child(col)

	# Cabecera.
	var header := UIUtil.hbox(12)
	col.add_child(header)
	if show_back:
		var back := Button.new()
		back.text = "← Volver"
		back.custom_minimum_size = Vector2(0, 40)
		back.pressed.connect(func(): SignalBus.back_requested.emit())
		header.add_child(back)
	var titles := UIUtil.vbox(0)
	titles.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header.add_child(titles)
	var t := UIUtil.label(title if title != "" else "", 24, Palette.TEXT)
	titles.add_child(t)
	if subtitle != "":
		titles.add_child(UIUtil.label(subtitle, 13, Palette.MUTED))

	content = UIUtil.vbox(10)
	content.size_flags_vertical = Control.SIZE_EXPAND_FILL
	col.add_child(content)

func _build() -> void:
	pass

## Prepara un ScrollContainer con el contenido dentro.
func add_scroll() -> VBoxContainer:
	var scroll := ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	content.add_child(scroll)
	var inner := UIUtil.vbox(8)
	inner.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.add_child(inner)
	return inner

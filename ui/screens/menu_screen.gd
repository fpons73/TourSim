class_name MenuScreen
extends BaseScreen
## Menú genérico con una lista de opciones navegables.

func _init(p: Dictionary = {}) -> void:
	title = str(p.get("title", ""))
	subtitle = str(p.get("subtitle", ""))
	super._init(p)

func _build() -> void:
	var items: Array = payload.get("items", [])
	for it in items:
		var btn := Button.new()
		btn.custom_minimum_size = Vector2(0, 56)
		btn.pressed.connect(func(): SignalBus.navigation_requested.emit(it.get("dest", "home"), it.get("payload", {})))
		content.add_child(btn)
		var row := UIUtil.hbox(10)
		row.mouse_filter = Control.MOUSE_FILTER_IGNORE
		btn.add_child(row)
		row.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		var texts := UIUtil.vbox(0)
		texts.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		texts.add_child(UIUtil.label(str(it.get("title", "")), 17, Palette.TEXT))
		if it.has("desc") and str(it.get("desc", "")) != "":
			texts.add_child(UIUtil.label(str(it.get("desc", "")), 12, Palette.MUTED))
		row.add_child(texts)
		row.add_child(UIUtil.label("›", 22, Palette.MUTED))

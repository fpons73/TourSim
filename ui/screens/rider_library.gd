class_name RiderLibrary
extends BaseScreen
## Biblioteca de corredores con búsqueda (PRD §30).

var _list: VBoxContainer
var _search: LineEdit

func _init(p: Dictionary = {}) -> void:
	title = "Corredores"
	subtitle = "%d corredores" % RiderRepo.count()
	super._init(p)

func _build() -> void:
	var top := UIUtil.hbox(8)
	content.add_child(top)
	_search = LineEdit.new()
	_search.placeholder_text = "Buscar corredor por nombre o nacionalidad..."
	_search.custom_minimum_size = Vector2(0, 40)
	_search.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_search.text_changed.connect(func(_t): _reload())
	top.add_child(_search)
	var new_btn := UIUtil.button("+ Nuevo", 40)
	new_btn.pressed.connect(func(): SignalBus.navigation_requested.emit("rider_editor", {}))
	top.add_child(new_btn)
	_list = add_scroll()
	_reload()

func _reload() -> void:
	UIUtil.clear(_list)
	var text := _search.text.strip_edges() if _search != null else ""
	var rows: Array
	if text == "":
		rows = RiderRepo.get_all().slice(0, 200)
	else:
		rows = RiderRepo.search(text).slice(0, 200)
	for row in rows:
		_list.add_child(_rider_row(row))

func _rider_row(row: Dictionary) -> Control:
	var btn := Button.new()
	btn.custom_minimum_size = Vector2(0, 38)
	btn.pressed.connect(func(): SignalBus.navigation_requested.emit("rider_sheet", {"rider_id": int(row["id"])}))
	var row_ui := UIUtil.hbox(10)
	row_ui.mouse_filter = Control.MOUSE_FILTER_IGNORE
	btn.add_child(row_ui)
	row_ui.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var name := UIUtil.label(str(row.get("name", "")), 14, Palette.TEXT)
	name.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row_ui.add_child(name)
	row_ui.add_child(UIUtil.label(str(row.get("nationality", "")), 12, Palette.MUTED))
	row_ui.add_child(UIUtil.label("›", 16, Palette.MUTED))
	return btn

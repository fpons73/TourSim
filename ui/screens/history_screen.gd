class_name HistoryScreen
extends BaseScreen
## Histórico de simulaciones (PRD §32): consulta y gestión.

var _list: VBoxContainer

func _init(p: Dictionary = {}) -> void:
	title = "Histórico"
	subtitle = "%d simulaciones guardadas" % HistoryRepo.count()
	super._init(p)

func _build() -> void:
	_list = add_scroll()
	_reload()

func _reload() -> void:
	UIUtil.clear(_list)
	var sims := HistoryRepo.list_all()
	if sims.is_empty():
		_list.add_child(UIUtil.label("Aún no hay simulaciones guardadas. Corre una etapa o carrera para generarlas.", 14, Palette.MUTED))
		return
	for s in sims:
		_list.add_child(_card(s))

func _card(s: Dictionary) -> Control:
	var card := UIUtil.panel()
	var box := UIUtil.hbox(10)
	card.add_child(box)
	var info := UIUtil.vbox(0)
	info.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var ref_type := str(s.get("ref_type", "stage"))
	info.add_child(UIUtil.label("%s · %s" % [ref_type.to_upper(), str(s.get("date", ""))], 14, Palette.TEXT))
	info.add_child(UIUtil.label("seed %s · modo %s" % [str(s.get("seed", "")), str(s.get("mode", ""))], 12, Palette.MUTED))
	box.add_child(info)
	var view := UIUtil.button("Ver", 36)
	view.pressed.connect(func(): _view(s))
	box.add_child(view)
	var dele := UIUtil.button("Eliminar", 36)
	dele.pressed.connect(func():
		HistoryRepo.delete(int(s.get("id", -1)))
		_reload())
	box.add_child(dele)
	return card

func _view(s: Dictionary) -> void:
	var raw = s.get("results_json")
	var parsed = JSON.parse_string(str(raw)) if raw != null and raw != "" else null
	if not (parsed is Dictionary):
		return
	SignalBus.navigation_requested.emit("results", {
		"results": parsed,
		"race": str(s.get("ref_type", "stage")) == "race",
	})

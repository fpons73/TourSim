class_name RaceLibrary
extends BaseScreen
## Biblioteca de carreras (PRD §8).

var _list: VBoxContainer

func _init(p: Dictionary = {}) -> void:
	var mode: String = p.get("mode", "run")
	title = "Carreras"
	subtitle = "Selecciona una carrera para comenzar" if mode == "run" else "Gestiona tus carreras"
	super._init(p)

func _build() -> void:
	_list = add_scroll()
	_reload()

func _reload() -> void:
	UIUtil.clear(_list)
	var races := RaceRepo.get_all()
	if races.is_empty():
		_list.add_child(UIUtil.label("No hay carreras todavía. Crea una desde el menú «Crear».", 14, Palette.MUTED))
		return
	for row in races:
		_list.add_child(_make_card(row))

func _make_card(row: Dictionary) -> Control:
	var race := Race.from_row(row)
	var stages := race.stages()
	var card := UIUtil.panel()
	var box := UIUtil.vbox(8)
	card.add_child(box)

	var head := UIUtil.hbox(10)
	box.add_child(head)
	var titles := UIUtil.vbox(0)
	titles.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var name := str(row.get("name", ""))
	if str(row.get("edition", "")) != "":
		name += " " + str(row.get("edition", ""))
	titles.add_child(UIUtil.label(name, 17, Palette.TEXT))
	var meta := "%d etapas · %.0f km · %s" % [
		race.stage_count(), race.total_distance(), str(row.get("country", ""))]
	titles.add_child(UIUtil.label(meta, 12, Palette.MUTED))
	head.add_child(titles)

	# Mini lista de etapas.
	if not stages.is_empty():
		var et := UIUtil.label(" · ".join(_stage_labels(stages)), 11, Palette.MUTED)
		et.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		box.add_child(et)

	var actions := UIUtil.hbox(8)
	box.add_child(actions)
	var mode: String = payload.get("mode", "run")
	if mode == "run":
		var start := UIUtil.button("▶ Comenzar", 38)
		start.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		start.pressed.connect(func(): _start(race))
		actions.add_child(start)
		var view := UIUtil.button("Ver etapas", 38)
		view.pressed.connect(func(): SignalBus.navigation_requested.emit("race_detail", {"race_id": int(row["id"])}))
		actions.add_child(view)
	else:
		var edit := UIUtil.button("Editar", 38)
		edit.pressed.connect(func(): SignalBus.navigation_requested.emit("race_editor", {"race_id": int(row["id"])}))
		actions.add_child(edit)
		var dup := UIUtil.button("Duplicar", 38)
		dup.pressed.connect(func(): RaceRepo.duplicate_race(int(row["id"])); _reload())
		actions.add_child(dup)
		var dele := UIUtil.button("Eliminar", 38)
		dele.pressed.connect(func(): RaceRepo.delete(int(row["id"])); _reload())
		actions.add_child(dele)
	return card

func _stage_labels(stages: Array) -> Array:
	var out: Array = []
	for s in stages:
		out.append("%s (%s)" % [s.name, Terrain.STAGE_TYPES.get(s.type, s.type)])
	return out

func _start(race: Race) -> void:
	SignalBus.navigation_requested.emit("participants", {"race_id": int(race.id)})

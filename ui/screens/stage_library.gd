class_name StageLibrary
extends BaseScreen
## Biblioteca de etapas (PRD §7). Modo "run" (jugar) o "manage" (editar/duplicar/eliminar).

var _list: VBoxContainer

func _init(p: Dictionary = {}) -> void:
	var mode: String = p.get("mode", "run")
	title = "Etapas"
	subtitle = "Selecciona una etapa para jugar" if mode == "run" else "Gestiona tus etapas"
	super._init(p)

func _build() -> void:
	_list = add_scroll()
	_reload()

func _reload() -> void:
	UIUtil.clear(_list)
	var stages := StageRepo.get_all()
	if stages.is_empty():
		_list.add_child(UIUtil.label("No hay etapas todavía. Crea una desde el menú «Crear».", 14, Palette.MUTED))
		return
	for row in stages:
		_list.add_child(_make_card(row))

func _make_card(row: Dictionary) -> Control:
	var stage := Stage.from_row(row)
	var card := UIUtil.panel()
	var box := UIUtil.vbox(8)
	card.add_child(box)

	# Título + meta.
	var head := UIUtil.hbox(10)
	box.add_child(head)
	var titles := UIUtil.vbox(0)
	titles.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	titles.add_child(UIUtil.label(str(row.get("name", "")), 17, Palette.TEXT))
	var meta := "%s · %s · %s" % [
		str(Terrain.STAGE_TYPES.get(row.get("type", "flat"), row.get("type"))),
		"%.0f km" % float(row.get("distance", 0.0)),
		UIUtil.difficulty_stars(UIUtil.stage_difficulty(str(row.get("type", "flat")))),
	]
	titles.add_child(UIUtil.label(meta, 12, Palette.MUTED))
	head.add_child(titles)
	if str(row.get("locked", 0)) == "1":
		head.add_child(UIUtil.label("🔒", 16, Palette.MUTED))

	# Perfil.
	var chart := ProfileChart.new(stage)
	box.add_child(chart)

	# Acciones.
	var actions := UIUtil.hbox(8)
	box.add_child(actions)
	var mode: String = payload.get("mode", "run")
	if mode == "run":
		var play := UIUtil.button("▶ Jugar", 38)
		play.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		play.pressed.connect(func(): _play(row))
		actions.add_child(play)
	else:
		var edit := UIUtil.button("Editar", 38)
		edit.pressed.connect(func(): SignalBus.navigation_requested.emit("stage_editor", {"stage_id": int(row["id"])}))
		actions.add_child(edit)
		var dup := UIUtil.button("Duplicar", 38)
		dup.pressed.connect(func(): StageRepo.duplicate_stage(int(row["id"])); _reload())
		actions.add_child(dup)
		var dele := UIUtil.button("Eliminar", 38)
		dele.pressed.connect(func(): StageRepo.delete(int(row["id"])); _reload())
		actions.add_child(dele)
	return card

func _play(row: Dictionary) -> void:
	SignalBus.navigation_requested.emit("participants", {"stage_id": int(row["id"])})

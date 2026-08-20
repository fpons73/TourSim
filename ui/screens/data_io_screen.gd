class_name DataIOScreen
extends BaseScreen
## Importación/exportación de datos (JSON/CSV) — PRD §37.

var _status: Label

func _init(p: Dictionary = {}) -> void:
	title = "Importar / Exportar"
	subtitle = "Datos en JSON y CSV"
	super._init(p)

func _build() -> void:
	var scroll := add_scroll()
	scroll.add_child(UIUtil.label("EXPORTAR", 12, Palette.GREEN))

	var exp_json := UIUtil.button("Exportar todo (JSON) → user://export.json", 42)
	exp_json.pressed.connect(func(): _msg(DataIO.export_json("user://export.json", true)))
	scroll.add_child(exp_json)

	var exp_riders := UIUtil.button("Exportar corredores (CSV) → user://riders.csv", 42)
	exp_riders.pressed.connect(func(): _msg(DataIO.export_riders_csv("user://riders.csv")))
	scroll.add_child(exp_riders)

	var exp_teams := UIUtil.button("Exportar equipos (CSV) → user://teams.csv", 42)
	exp_teams.pressed.connect(func(): _msg(DataIO.export_teams_csv("user://teams.csv")))
	scroll.add_child(exp_teams)

	scroll.add_child(UIUtil.spacer(8))
	scroll.add_child(UIUtil.label("IMPORTAR", 12, Palette.ORANGE))

	var imp_json := UIUtil.button("Importar todo (JSON) desde user://import.json", 42)
	imp_json.pressed.connect(func(): _msg(DataIO.import_json("user://import.json", true)))
	scroll.add_child(imp_json)

	var imp_riders := UIUtil.button("Importar corredores (CSV) desde user://riders.csv", 42)
	imp_riders.pressed.connect(func(): _msg(DataIO.import_riders_csv("user://riders.csv") > 0))
	scroll.add_child(imp_riders)

	scroll.add_child(UIUtil.spacer(8))
	scroll.add_child(UIUtil.label("Los archivos se leen/escriben en el directorio de datos del usuario (user://).", 11, Palette.MUTED))

	_status = UIUtil.label("", 13, Palette.YELLOW)
	scroll.add_child(_status)

func _msg(ok: bool) -> void:
	_status.text = "Operación completada." if ok else "Operación fallida."

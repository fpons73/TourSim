class_name HistoryScreen
extends BaseScreen
## Histórico de simulaciones (PRD §32). Versión básica.

func _init(p: Dictionary = {}) -> void:
	title = "Histórico"
	subtitle = "Simulaciones guardadas"
	super._init(p)

func _build() -> void:
	var scroll := add_scroll()
	var sims := HistoryRepo.list_all()
	if sims.is_empty():
		scroll.add_child(UIUtil.label("Aún no hay simulaciones guardadas. Corre una etapa o carrera para generarlas.", 14, Palette.MUTED))
		return
	for s in sims:
		scroll.add_child(UIUtil.label("%s · seed %s · modo %s" % [
			str(s.get("date", "")), str(s.get("seed", "")), str(s.get("mode", ""))], 13, Palette.TEXT))

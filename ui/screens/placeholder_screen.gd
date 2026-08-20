class_name PlaceholderScreen
extends BaseScreen
## Pantalla provisional para funcionalidades aún no implementadas.

func _init(p: Dictionary = {}) -> void:
	super._init(p)

func _build() -> void:
	content.add_child(UIUtil.label("Sección «%s»" % title, 18, Palette.TEXT))
	content.add_child(UIUtil.label("Esta funcionalidad estará disponible en un próximo hito.", 14, Palette.MUTED))

class_name UIUtil
extends RefCounted
## Helpers de construcción de UI programática.

static func label(text: String, size: int = 15, color: Color = Palette.TEXT, align: int = HORIZONTAL_ALIGNMENT_LEFT) -> Label:
	var l := Label.new()
	l.text = text
	l.add_theme_font_size_override("font_size", size)
	l.add_theme_color_override("font_color", color)
	l.horizontal_alignment = align
	return l

static func button(text: String, min_h: float = 40.0) -> Button:
	var b := Button.new()
	b.text = text
	b.custom_minimum_size = Vector2(0, min_h)
	return b

static func hbox(sep: int = 8) -> HBoxContainer:
	var h := HBoxContainer.new()
	h.add_theme_constant_override("separation", sep)
	return h

static func vbox(sep: int = 8) -> VBoxContainer:
	var v := VBoxContainer.new()
	v.add_theme_constant_override("separation", sep)
	return v

static func spacer(h: float) -> Control:
	var c := Control.new()
	c.custom_minimum_size = Vector2(0, h)
	return c

static func panel() -> PanelContainer:
	return PanelContainer.new()

static func fill(node: Control) -> void:
	node.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

static func clear(node: Node) -> void:
	for c in node.get_children():
		c.queue_free()

## Formatea segundos como "3h 24' 12\"" o "24' 12\"".
static func fmt_time(seconds: float) -> String:
	var s := int(roundi(seconds))
	if s < 0:
		return "-" + fmt_time(-s)
	var h := s / 3600
	var m := (s % 3600) / 60
	var sec := s % 60
	if h > 0:
		return "%dh %02d' %02d\"" % [h, m, sec]
	return "%d' %02d\"" % [m, sec]

## Formatea una diferencia (gap) como "+02:14".
static func fmt_gap(seconds: float) -> String:
	if seconds < 1.0:
		return "—"
	var s := int(roundi(seconds))
	var h := s / 3600
	var m := (s % 3600) / 60
	var sec := s % 60
	if h > 0:
		return "+%d:%02d:%02d" % [h, m, sec]
	return "+%02d:%02d" % [m, sec]

## Estrellas de dificultad (0..5) a partir de un índice.
static func difficulty_stars(idx: int) -> String:
	return "★".repeat(maxi(1, mini(5, idx))) + "☆".repeat(maxi(0, 5 - maxi(1, mini(5, idx))))

## Dificultad estimada de una etapa según tipo.
static func stage_difficulty(stype: String) -> int:
	match stype:
		"prologue":
			return 1
		"flat":
			return 2
		"flat_hilly", "crosswind", "cobbles":
			return 3
		"medium_mountain", "itt":
			return 4
		"mountain", "ttt":
			return 5
	return 3

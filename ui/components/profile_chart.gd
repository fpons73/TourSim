class_name ProfileChart
extends Control
## Dibuja el perfil de altitud de una etapa.

var stage: Stage = null
var line_color: Color = Palette.BLUE
var fill_alpha: float = 0.15

func _init(s: Stage = null) -> void:
	stage = s
	custom_minimum_size = Vector2(200, 56)

func set_stage(s: Stage) -> void:
	stage = s
	queue_redraw()

func _draw() -> void:
	if stage == null or stage.sections.is_empty():
		return
	var w := size.x
	var h := size.y
	var n := 64
	var points := PackedVector2Array()
	var max_alt := 0.0
	for i in n + 1:
		var km := stage.distance * float(i) / float(n)
		var alt := Stage.altitude_at(stage, km)
		points.append(Vector2(km, alt))
		max_alt = maxf(max_alt, alt)
	max_alt = maxf(max_alt, 1.0)
	for i in points.size():
		points[i] = Vector2(
			points[i].x / maxf(stage.distance, 1.0) * w,
			h - 4.0 - (points[i].y / max_alt) * (h - 8.0)
		)
	# Relleno bajo la curva.
	var fill := PackedVector2Array()
	fill.append(Vector2(0, h))
	fill.append_array(points)
	fill.append(Vector2(w, h))
	draw_colored_polygon(fill, Color(line_color, fill_alpha))
	draw_polyline(points, line_color, 2.0, true)

class_name ProfileChart
extends Control
## Dibuja el perfil de altitud de una etapa.

var stage: Stage = null
var line_color: Color = Palette.BLUE
var fill_alpha: float = 0.15
var marker_km: float = -1.0

func _init(s: Stage = null) -> void:
	stage = s
	custom_minimum_size = Vector2(200, 56)

func set_stage(s: Stage) -> void:
	stage = s
	queue_redraw()

func set_marker(km: float) -> void:
	marker_km = km
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

	# Marcador de posición.
	if marker_km >= 0.0:
		var x := clampf(marker_km / maxf(stage.distance, 1.0), 0.0, 1.0) * w
		draw_line(Vector2(x, 0), Vector2(x, h), Color(Palette.YELLOW, 0.9), 2.0)
		draw_circle(Vector2(x, 8.0), 4.0, Palette.YELLOW)

class_name ParticipantsScreen
extends BaseScreen
## Selección de participantes (PRD §11): equipos y corredores por equipo.

var _checks: Dictionary = {}       # team_id -> CheckBox
var _rider_count: SpinBox

func _init(p: Dictionary = {}) -> void:
	title = "Seleccionar participantes"
	subtitle = "Elige equipos y corredores"
	super._init(p)

func _build() -> void:
	var controls := UIUtil.hbox(8)
	content.add_child(controls)
	var all_btn := UIUtil.button("Todos", 38)
	all_btn.pressed.connect(func(): _set_all(true))
	controls.add_child(all_btn)
	var none_btn := UIUtil.button("Ninguno", 38)
	none_btn.pressed.connect(func(): _set_all(false))
	controls.add_child(none_btn)
	var wt_btn := UIUtil.button("Solo WorldTour", 38)
	wt_btn.pressed.connect(func(): _set_worldtour())
	controls.add_child(wt_btn)

	_rider_count = SpinBox.new()
	_rider_count.min_value = 1
	_rider_count.max_value = 30
	_rider_count.value = 8
	_rider_count.suffix = " corredores/equipo"
	controls.add_child(_rider_count)

	var scroll := add_scroll()
	var teams := TeamRepo.get_all()
	for row in teams:
		var h := UIUtil.hbox(8)
		scroll.add_child(h)
		var cb := CheckBox.new()
		cb.button_pressed = str(row.get("category", "")) == "WorldTour"
		h.add_child(cb)
		var t := Team.from_row(row)
		var swatch := ColorRect.new()
		swatch.color = t.color_primary
		swatch.custom_minimum_size = Vector2(8, 18)
		h.add_child(swatch)
		var name := UIUtil.label(str(row.get("name", "")), 13, Palette.TEXT)
		name.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		h.add_child(name)
		h.add_child(UIUtil.label("%d" % TeamRepo.rider_count(int(row["id"])), 12, Palette.MUTED))
		_checks[int(row["id"])] = cb

	var go := UIUtil.button("Continuar", 46)
	go.pressed.connect(func(): _continue())
	content.add_child(go)

func _set_all(v: bool) -> void:
	for cb in _checks.values():
		cb.button_pressed = v

func _set_worldtour() -> void:
	var teams := TeamRepo.get_all()
	for row in teams:
		_checks[int(row["id"])].button_pressed = str(row.get("category", "")) == "WorldTour"

func _continue() -> void:
	var participants: Array = []
	var n := int(_rider_count.value)
	for tid in _checks.keys():
		if _checks[tid].button_pressed:
			var riders := TeamRepo.get_riders(int(tid))
			riders.sort_custom(func(a, b): return _overall(b) < _overall(a))
			var ids: Array = []
			for i in mini(n, riders.size()):
				ids.append(int(riders[i]["id"]))
			if not ids.is_empty():
				participants.append({"team_id": int(tid), "rider_ids": ids})
	if participants.is_empty():
		return
	GameState.participants = participants
	SignalBus.navigation_requested.emit("match_setup", payload)

func _overall(row: Dictionary) -> float:
	var s := 0.0
	for a in Terrain.ATTRS:
		s += float(row.get(a, 50))
	return s / Terrain.ATTRS.size()

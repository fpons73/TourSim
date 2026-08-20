class_name EventLog
extends RefCounted
## Registro de eventos de carrera (Race Feed).

# Tipos y colores/iconos asociados (PRD §22, §26).
const TYPE_META := {
	"attack":   {"icon": "🟡", "color": "red"},
	"breakaway":{"icon": "🟢", "color": "green"},
	"incident": {"icon": "🔴", "color": "red"},
	"sprint":   {"icon": "🏁", "color": "yellow"},
	"mountain": {"icon": "⛰", "color": "violet"},
	"split":    {"icon": "🟠", "color": "orange"},
	"finish":   {"icon": "🏆", "color": "yellow"},
	"info":     {"icon": "🔵", "color": "blue"},
}

var events: Array = []   # de Dictionary {km, type, title, text, riders}

func add(km: float, type: String, title: String, text: String, riders: Array = []) -> void:
	events.append({
		"km": km, "type": type, "title": title, "text": text,
		"riders": riders, "time": events.size(),
	})

func get_all() -> Array:
	return events

func count() -> int:
	return events.size()

func last(n: int) -> Array:
	var out: Array = []
	var start := maxi(0, events.size() - n)
	for i in range(start, events.size()):
		out.append(events[i])
	return out

func to_json() -> String:
	return JSON.stringify(events)

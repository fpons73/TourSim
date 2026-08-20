class_name Team
extends RefCounted
## Modelo runtime de un equipo.

var id: int = -1
var name: String = ""
var abbr: String = ""
var country: String = ""
var category: String = ""
var color_primary: Color = Color.WHITE
var color_secondary: Color = Color.WHITE
var riders: Array = []          # de Rider

static func from_row(row: Dictionary) -> Team:
	var t := Team.new()
	t.id = int(row.get("id", -1))
	t.name = str(row.get("name", ""))
	t.abbr = str(row.get("abbr", ""))
	t.country = str(row.get("country", ""))
	t.category = str(row.get("category", ""))
	t.color_primary = _hex_to_color(row.get("color_primary"))
	t.color_secondary = _hex_to_color(row.get("color_secondary"))
	return t

static func _hex_to_color(hex) -> Color:
	var s := str(hex if hex != null else "#FFFFFF")
	if s.begins_with("#"):
		s = s.substr(1)
	if s.length() >= 6:
		var r := s.substr(0, 2).hex_to_int()
		var g := s.substr(2, 2).hex_to_int()
		var b := s.substr(4, 2).hex_to_int()
		return Color(float(r) / 255.0, float(g) / 255.0, float(b) / 255.0)
	return Color.WHITE

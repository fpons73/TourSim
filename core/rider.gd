class_name Rider
extends RefCounted
## Modelo runtime de un corredor (datos estáticos + estado dinámico de carrera).

var id: int = -1
var name: String = ""
var nationality: String = ""
var team_id: int = -1
var team_abbr: String = ""
var team_color: Color = Color.WHITE
var team_color2: Color = Color.WHITE
var birth_date: String = ""
var specialty: String = ""
var attrs: Dictionary = {}          # 14 atributos (fla, mnt, ...)

# Estado dinámico
var fatigue: float = 0.0            # 0..~100
var time: float = 0.0               # tiempo acumulado (segundos)
var gap: float = 0.0                # diferencia con el líder (segundos)
var group_id: int = -1
var status: String = "OK"           # OK | dropped | crashed | abandono | winner
var finished: bool = false
var stage_points: int = 0           # puntos de la etapa (sprint/montaña)
var role: String = ""               # líder, sprinter, escalador, gregario...

static func from_row(row: Dictionary) -> Rider:
	var r := Rider.new()
	r.id = int(row.get("id", -1))
	r.name = str(row.get("name", ""))
	r.nationality = str(row.get("nationality", ""))
	r.team_id = int(row.get("team_id", -1))
	r.birth_date = str(row.get("birth_date", ""))
	r.specialty = str(row.get("specialty", ""))
	for a in Terrain.ATTRS:
		r.attrs[a] = int(row.get(a, 50))
	return r

func attr(key: String) -> int:
	return int(attrs.get(key, 50))

## Atributo relevante para un terreno dado.
func terrain_attr(terrain: String) -> int:
	var a: String = Terrain.ATTR_FOR.get(terrain, "fla")
	return attr(a)

## Edad aproximada a fecha de referencia (año de temporada 2026).
func age(ref_year: int = 2026) -> int:
	if birth_date == "":
		return 0
	var parts := birth_date.split("/")
	if parts.size() >= 3:
		var y := int(parts[2]) if parts[2].is_valid_int() else 0
		if y > 0:
			return maxi(0, ref_year - y)
	return 0

## Rendimiento base en una sección (0..1) considerando fatiga.
func performance(terrain: String) -> float:
	var base := float(terrain_attr(terrain)) / 99.0
	var fatigue_penalty := (fatigue / 100.0) * 0.35
	return clampf(base * (1.0 - fatigue_penalty), 0.05, 1.0)

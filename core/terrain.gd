class_name Terrain
extends RefCounted
## Constantes y mapeos de terreno/tipos de etapa para el Simulation Core.

const ATTRS := ["fla", "mnt", "mm", "hil", "ttr", "prl", "cob", "spr",
	"acc", "dhi", "att", "sta", "res", "rec"]

const ATTR_LABEL := {
	"fla": "Llano", "mnt": "Montaña", "mm": "Media Montaña", "hil": "Colina",
	"ttr": "Crono", "prl": "Prólogo", "cob": "Pavés", "spr": "Sprint",
	"acc": "Aceleración", "dhi": "Descenso", "att": "Ataque",
	"sta": "Aguante", "res": "Resistencia", "rec": "Recuperación",
}

const ATTR_GROUPS := {
	"Terreno": ["fla", "mm", "mnt", "hil", "cob"],
	"Especialidades": ["spr", "acc", "att", "dhi", "ttr", "prl"],
	"Físico": ["sta", "res", "rec"],
}

# Atributo relevante según el terreno de una sección.
const ATTR_FOR := {
	"flat": "fla", "hill": "hil", "medium_mountain": "mm", "mountain": "mnt",
	"descent": "dhi", "cobbles": "cob", "crosswind": "fla",
	"itt": "ttr", "ttt": "ttr", "prologue": "prl",
}

const TERRAIN_LABEL := {
	"flat": "Llano", "hill": "Colina", "medium_mountain": "Media Montaña",
	"mountain": "Montaña", "descent": "Descenso", "cobbles": "Pavés",
	"crosswind": "Viento cruzado", "itt": "Crono", "ttt": "CRE", "prologue": "Prólogo",
}

const STAGE_TYPES := {
	"flat": "Llana",
	"flat_hilly": "Llana con cotas",
	"medium_mountain": "Media Montaña",
	"mountain": "Montaña",
	"itt": "Contrarreloj individual",
	"ttt": "Contrarreloj por equipos",
	"crosswind": "Viento cruzado",
	"cobbles": "Pavés",
	"prologue": "Prólogo",
}

# Intensidad base por terreno (carga de fatiga / esfuerzo).
const INTENSITY := {
	"flat": 1.0, "hill": 1.6, "medium_mountain": 2.1, "mountain": 2.7,
	"descent": 0.7, "cobbles": 2.0, "crosswind": 1.8,
	"itt": 2.4, "ttt": 2.2, "prologue": 2.0,
}

# Terrenos de subida (para puntos de montaña / splitting).
const CLIMB_TERRAINS := ["hill", "medium_mountain", "mountain"]

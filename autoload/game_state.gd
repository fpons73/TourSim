extends Node
## GameState — estado de la partida en curso (partida = etapa o carrera).

var mode: String = "spectator"       # spectator | control
var player_team_id: int = -1
var speed: String = "normal"         # paused | normal | fast | very_fast | instant
var dice_animated: bool = true

var seed: String = ""                # seed real usada (mostrada en UI)
var race_id: int = -1                # -1 => etapa suelta
var stage_id: int = -1
var stage_index: int = 0             # etapa actual dentro de la carrera

var participants: Array = []         # [{ team_id, rider_ids: [..], roles: {..} }]
var current_race: Dictionary = {}    # snapshot de la carrera (nombre, edición, etc.)

# Estado de simulación en vivo (poblado por el Simulation Core)
var race_state: Object = null

func reset() -> void:
	mode = "spectator"
	player_team_id = -1
	seed = ""
	race_id = -1
	stage_id = -1
	stage_index = 0
	participants = []
	current_race = {}
	race_state = null
	speed = "normal"
	dice_animated = true

func is_controlling() -> bool:
	return mode == "control" and player_team_id >= 0

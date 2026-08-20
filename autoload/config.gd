extends Node
## Config — preferencias de la aplicación (se cargan/guardan en la tabla settings).

const SETTINGS_KEY := "app_config"

var language := "es"
var sound_enabled := true
var animations_enabled := true
var simulation_speed := "normal"   # paused | normal | fast | very_fast | instant
var dice_animated := true
var theme_variant := "dark"
var accessibility_scale := 1.0
var default_seed := ""             # vacío => aleatoria
var show_seed := true

func to_dict() -> Dictionary:
	return {
		"language": language,
		"sound_enabled": sound_enabled,
		"animations_enabled": animations_enabled,
		"simulation_speed": simulation_speed,
		"dice_animated": dice_animated,
		"theme_variant": theme_variant,
		"accessibility_scale": accessibility_scale,
		"default_seed": default_seed,
		"show_seed": show_seed,
	}

func from_dict(d: Dictionary) -> void:
	if d.is_empty():
		return
	language = d.get("language", language)
	sound_enabled = d.get("sound_enabled", sound_enabled)
	animations_enabled = d.get("animations_enabled", animations_enabled)
	simulation_speed = d.get("simulation_speed", simulation_speed)
	dice_animated = d.get("dice_animated", dice_animated)
	theme_variant = d.get("theme_variant", theme_variant)
	accessibility_scale = d.get("accessibility_scale", accessibility_scale)
	default_seed = d.get("default_seed", default_seed)
	show_seed = d.get("show_seed", show_seed)

func save() -> void:
	DataStore.set_setting(SETTINGS_KEY, to_dict())

func load() -> void:
	from_dict(DataStore.get_setting(SETTINGS_KEY, {}))

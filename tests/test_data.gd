extends Node
## Test de humo del Data Layer. Se ejecuta: godot --headless res://tests/test_data.tscn

func _ready() -> void:
	print("DataStore ready: ", DataStore.is_ready())
	print("Teams: ", TeamRepo.count())
	print("Riders: ", RiderRepo.count())
	print("Stages: ", StageRepo.count())
	print("Races: ", RaceRepo.count())

	var team := TeamRepo.get_by_id(1)
	print("Team id=1: ", team.get("name"), " | ", team.get("abbr"), " | ", team.get("color_primary"))
	print("Riders de UAE: ", TeamRepo.rider_count(1))

	var rider := RiderRepo.get_by_id(1)
	print("Rider id=1: ", rider.get("name"), " (", rider.get("nationality"), ") sprint=", rider.get("spr"))

	print("Top 3 sprint:")
	for r in RiderRepo.get_top_by("spr", 3):
		print("  - ", r.get("name"), " -> ", r.get("spr"))

	var cat_riders := TeamRepo.get_by_category("WorldTour")
	print("Equipos WorldTour: ", cat_riders.size())

	var search := TeamRepo.search("uae")
	print("Search 'uae': ", search.size(), " -> ", search[0].get("name") if not search.is_empty() else "-")

	var settings_ok := true
	DataStore.set_setting("test_key", {"a": 1})
	var got = DataStore.get_setting("test_key", {})
	settings_ok = (got is Dictionary) and (int(got.get("a", 0)) == 1)
	print("Settings roundtrip: ", settings_ok, " (", got, ")")

	var stage_id := StageRepo.create({"name": "Test Stage", "type": "mountain", "distance": 150.0})
	print("Stage create: ", stage_id, " count=", StageRepo.count())
	var dup_id := StageRepo.duplicate_stage(stage_id)
	print("Stage duplicate: ", dup_id, " name=", StageRepo.get_by_id(dup_id).get("name"))
	StageRepo.delete(stage_id)
	StageRepo.delete(dup_id)

	var race_id := RaceRepo.create({"name": "Test Race", "edition": "2026"})
	RaceRepo.set_stage_ids(race_id, [])
	print("Race create: ", race_id, " count=", RaceRepo.count())
	var race_dup := RaceRepo.duplicate_race(race_id)
	print("Race duplicate: ", race_dup, " name=", RaceRepo.get_by_id(race_dup).get("name"))
	RaceRepo.delete(race_id)
	RaceRepo.delete(race_dup)

	var ok_export := DataIO.export_json("user://test_export.json", false)
	print("DataIO export: ", ok_export)

	TeamRepo.set_roles(1, {"1": "lider", "2": "sprinter"})
	var roles = TeamRepo.get_roles(1)
	print("Team roles roundtrip: ", roles.get("1", "") == "lider")

	print("DATA TEST OK")
	get_tree().quit()

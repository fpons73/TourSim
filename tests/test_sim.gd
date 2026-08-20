extends Node
## Test del Simulation Core: resuelve una etapa y verifica determinismo.

func _ready() -> void:
	var team_rows := TeamRepo.get_all()
	var rider_rows := RiderRepo.get_all()

	var s := Stage.new()
	s.name = "Test Montaña"
	s.type = "mountain"
	s.distance = 180.0
	s.finish = "Alpe d'Huez"
	s.sections = Stage.StageProfile.build("mountain", 180.0)

	var st := RaceState.new()
	st.setup(s, rider_rows, team_rows, 12345)
	var res := st.resolve_to_end()

	print("Winner: ", res["winner_name"])
	print("Eventos: ", st.events.count())
	print("Grupos finales: ", st.groups.size())
	for i in mini(10, res["gc"].size()):
		print("%d. %-28s +%.0fs" % [res["gc"][i]["pos"], res["gc"][i]["name"], res["gc"][i]["gap"]])
	print("Montaña top3: ", _names(res["mountain"], 3))
	print("Jóvenes top3: ", _names(res["young"], 3))

	var st2 := RaceState.new()
	st2.setup(s, rider_rows, team_rows, 12345)
	var res2 := st2.resolve_to_end()
	print("Determinismo (misma seed): ", res["winner_id"] == res2["winner_id"])

	var st3 := RaceState.new()
	st3.setup(s, rider_rows, team_rows, 99999)
	var res3 := st3.resolve_to_end()
	print("Winner seed 99999: ", res3["winner_name"])

	# Etapa llana con sprint.
	var flat := Stage.new()
	flat.name = "Test Llana"
	flat.type = "flat"
	flat.distance = 170.0
	flat.finish = "Champs-Elysées"
	flat.sections = Stage.StageProfile.build("flat", 170.0)
	var sf := RaceState.new()
	sf.setup(flat, rider_rows, team_rows, 42)
	var rf := sf.resolve_to_end()
	print("Winner llana: ", rf["winner_name"])

	# Contrarreloj individual.
	var itt := Stage.new()
	itt.name = "CRI Test"
	itt.type = "itt"
	itt.distance = 35.0
	itt.sections = Stage.StageProfile.build("itt", 35.0)
	var si := RaceState.new()
	si.setup(itt, rider_rows, team_rows, 7)
	var ri := si.resolve_to_end()
	print("Winner CRI: ", ri["winner_name"])

	# Contrarreloj por equipos.
	var ttt := Stage.new()
	ttt.name = "CRE Test"
	ttt.type = "ttt"
	ttt.distance = 40.0
	ttt.sections = Stage.StageProfile.build("ttt", 40.0)
	var stt := RaceState.new()
	stt.setup(ttt, rider_rows, team_rows, 7)
	var rtt := stt.resolve_to_end()
	print("Winner CRE: ", rtt["winner_name"], " | top equipo: ", rtt["teams"][0]["name"])

	# Test de decisiones (modo control de equipo).
	var decision_seen := false
	for sd in range(0, 30):
		var stc := RaceState.new()
		stc.setup(flat, rider_rows, team_rows, sd, 1)
		var g := 0
		while stc.pending_decision.is_empty() and not stc.finished and g < 50:
			stc.step()
			g += 1
		if not stc.pending_decision.is_empty():
			stc.apply_decision("respond")
			decision_seen = true
			print("Decision (seed %d): %s ataca -> respondido" % [sd, stc.decisions_log[0]["attacker"]])
			break
	print("Decision system works: ", decision_seen)

	print("SIM TEST OK")
	get_tree().quit()

func _names(ranking: Array, n: int) -> String:
	var out: Array = []
	for i in mini(n, ranking.size()):
		out.append(ranking[i]["name"])
	return ", ".join(out)

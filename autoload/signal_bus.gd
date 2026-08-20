extends Node
## SignalBus — señales globales de la aplicación (Presentation <-> Simulation).

# Navegación
signal navigation_requested(destination: String, payload: Variant)
signal back_requested

# Selección
signal stage_selected(stage_id: int)
signal race_selected(race_id: int)
signal rider_selected(rider_id: int)
signal team_selected(team_id: int)

# Simulación
signal simulation_started
signal simulation_step(km: float, gap: float)
signal simulation_finished(results: Dictionary)
signal decision_required(decision: Dictionary)
signal decision_made(choice: Dictionary)

# Eventos / feed
signal race_event(event: Dictionary)
signal classification_updated
signal dice_rolled(value: int, label: String)

# Datos
signal data_changed(entity: String)

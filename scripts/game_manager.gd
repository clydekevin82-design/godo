extends Node

signal tower_activated(tower_id: int)
signal story_beat(message: String)
signal world_state_changed(state: WorldState)

enum WorldState {
	INITIAL, # Before any towers
	POWER_RESTORED, # Tower 1 - Lightning increases
	SIGNAL_CALIBRATED, # Tower 2 - Hearing your own voice
	STORM_PAUSED, # Tower 3 - Truth revealed
	CONTAINMENT_KNOWN # Tower 4 - Stakes shift
}

var current_state := WorldState.INITIAL
var towers_activated := 0
var player_position := Vector3.ZERO

func _ready() -> void:
	show_story_beat("MISSION BRIEFING:\nRestore weather-control array.\nStabilize environment.\n\nWeather anomaly detected 72 hours ago.\nYou are cleared for field deployment.")

func activate_tower(tower_id: int) -> void:
	if towers_activated >= tower_id:
		return # Already activated
	
	towers_activated = tower_id
	tower_activated.emit(tower_id)
	
	match tower_id:
		1:
			_tower_1_power_reboot()
		2:
			_tower_2_signal_calibration()
		3:
			_tower_3_climate_control()
		4:
			_tower_4_containment_lock()

func _tower_1_power_reboot() -> void:
	current_state = WorldState.POWER_RESTORED
	world_state_changed.emit(current_state)
	await get_tree().create_timer(2.0).timeout
	show_story_beat("TOWER 1: ONLINE\n\nPower restored.\nStorm activity increasing.\n\n...Something feels wrong.")

func _tower_2_signal_calibration() -> void:
	current_state = WorldState.SIGNAL_CALIBRATED
	world_state_changed.emit(current_state)
	await get_tree().create_timer(2.0).timeout
	show_story_beat("TOWER 2: ONLINE\n\nSignal calibration complete.\nStorm frequency reduced.\n\n[STATIC] ...can you hear me...\n[Your voice?]")
	await get_tree().create_timer(4.0).timeout
	show_story_beat("[Static continues]\n\"...it wasn't an accident...\"\n\"...you know what you did...\"")

func _tower_3_climate_control() -> void:
	current_state = WorldState.STORM_PAUSED
	world_state_changed.emit(current_state)
	await get_tree().create_timer(2.0).timeout
	show_story_beat("TOWER 3: ONLINE\n\nClimate stabilization engaged.\nStorm paused.\n\nThe world is smaller than you thought.")
	await get_tree().create_timer(3.0).timeout
	show_story_beat("Wait.\n\nThis facility...\n\nThose aren't weather sensors.\n\nThey're pointing inward.")

func _tower_4_containment_lock() -> void:
	current_state = WorldState.CONTAINMENT_KNOWN
	world_state_changed.emit(current_state)
	await get_tree().create_timer(2.0).timeout
	show_story_beat("TOWER 4: ONLINE\n\nCONTAINMENT PROTOCOL ACTIVE\n\nThis was never about weather.\n\nYou didn't break the system.\n\nYou ACTIVATED it.")
	await get_tree().create_timer(4.0).timeout
	show_story_beat("The storm isn't a malfunction.\n\nIt's a barrier.\n\nAnd you just opened it.")

func show_story_beat(message: String) -> void:
	story_beat.emit(message)

func update_player_position(pos: Vector3) -> void:
	player_position = pos

func should_lightning_hunt() -> bool:
	return current_state == WorldState.CONTAINMENT_KNOWN

func get_lightning_frequency() -> float:
	match current_state:
		WorldState.INITIAL:
			return 1.0
		WorldState.POWER_RESTORED:
			return 2.5 # Much more frequent
		WorldState.SIGNAL_CALIBRATED:
			return 0.5 # Quieter
		WorldState.STORM_PAUSED:
			return 0.1 # Almost none
		WorldState.CONTAINMENT_KNOWN:
			return 3.0 # Aggressive
	return 1.0

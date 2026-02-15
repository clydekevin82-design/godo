extends Node

@onready var audio_player: AudioStreamPlayer = $AudioStreamPlayer

var distortion_level := 0.0
var base_pitch := 1.0

func _ready() -> void:
	# Connect to game manager
	var game_manager = get_node("/root/Main/GameManager")
	if game_manager:
		game_manager.world_state_changed.connect(_on_world_state_changed)
		game_manager.tower_activated.connect(_on_tower_activated)

func _process(_delta: float) -> void:
	# Gradually increase distortion over time
	if distortion_level > 0:
		_apply_audio_distortion()

func _on_world_state_changed(state: int) -> void:
	var game_manager = get_node("/root/Main/GameManager")
	if not game_manager:
		return
	
	match state:
		game_manager.WorldState.POWER_RESTORED:
			distortion_level = 0.15
			_play_static_burst()
		game_manager.WorldState.SIGNAL_CALIBRATED:
			distortion_level = 0.35
			_play_voice_distortion()
		game_manager.WorldState.STORM_PAUSED:
			distortion_level = 0.0 # Brief clarity
			await get_tree().create_timer(5.0).timeout
			distortion_level = 0.6
		game_manager.WorldState.CONTAINMENT_KNOWN:
			distortion_level = 0.85
			_play_warning_tone()

func _on_tower_activated(_tower_id: int) -> void:
	# Play mechanical sound on tower activation
	_play_mechanical_sound()

func _apply_audio_distortion() -> void:
	# Modulate pitch based on distortion
	var _pitch_variation = randf_range(-0.1, 0.1) * distortion_level
	AudioServer.set_bus_effect_enabled(0, 0, distortion_level > 0.1)

func _play_static_burst() -> void:
	# Placeholder for static sound
	pass

func _play_voice_distortion() -> void:
	# Placeholder for distorted voice (your own voice recording)
	pass

func _play_warning_tone() -> void:
	# Placeholder for warning alarm
	pass

func _play_mechanical_sound() -> void:
	# Placeholder for mechanical activation sound
	pass

func get_distortion_level() -> float:
	return distortion_level

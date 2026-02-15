extends Node3D

@export var min_lightning_interval := 3.0
@export var max_lightning_interval := 12.0
@export var lightning_flash_duration := 0.15
@export var thunder_delay_min := 0.5
@export var thunder_delay_max := 3.0

@onready var sun: DirectionalLight3D = $"../Sun"
@onready var environment: WorldEnvironment = $"../WorldEnvironment"
@onready var lightning_light: OmniLight3D = $LightningLight
@onready var buried_structure: Node3D = $"../BuriedStructure"
@onready var game_manager = $"../GameManager"

var _time_until_lightning := 0.0
var _flash_timer := 0.0
var _is_flashing := false
var _original_sun_energy := 0.0
var _player_ref: CharacterBody3D = null

func _ready() -> void:
	_original_sun_energy = sun.light_energy
	_time_until_lightning = randf_range(min_lightning_interval, max_lightning_interval)
	lightning_light.visible = false
	
	if buried_structure:
		buried_structure.visible = false
	
	if game_manager:
		game_manager.world_state_changed.connect(_on_world_state_changed)

func _process(delta: float) -> void:
	# Update player reference for hunting mode
	if not _player_ref:
		_player_ref = get_tree().get_first_node_in_group("player")
	
	if _is_flashing:
		_flash_timer -= delta
		if _flash_timer <= 0.0:
			_end_flash()
	else:
		_time_until_lightning -= delta
		if _time_until_lightning <= 0.0:
			_trigger_lightning()

func _trigger_lightning() -> void:
	_is_flashing = true
	_flash_timer = lightning_flash_duration
	
	# Flash the environment
	sun.light_energy = _original_sun_energy * 4.0
	
	# Reveal buried structure during flash
	if buried_structure and game_manager.current_state >= game_manager.WorldState.POWER_RESTORED:
		buried_structure.visible = true
	
	# Position lightning light
	var strike_position := _get_strike_position()
	lightning_light.global_position = strike_position
	lightning_light.visible = true
	
	# Schedule thunder sound
	var thunder_delay := randf_range(thunder_delay_min, thunder_delay_max)
	await get_tree().create_timer(thunder_delay).timeout
	_play_thunder()

func _get_strike_position() -> Vector3:
	# In hunting mode, strike near player
	if game_manager and game_manager.should_lightning_hunt() and _player_ref:
		var player_pos = _player_ref.global_position
		var offset = Vector3(
			randf_range(-20.0, 20.0),
			randf_range(15.0, 25.0),
			randf_range(-20.0, 20.0)
		)
		return player_pos + offset
	else:
		# Random strikes
		return Vector3(
			randf_range(-80.0, 80.0),
			randf_range(15.0, 25.0),
			randf_range(-80.0, 80.0)
		)

func _end_flash() -> void:
	_is_flashing = false
	sun.light_energy = _original_sun_energy
	lightning_light.visible = false
	
	# Hide structure again when flash ends
	if buried_structure:
		buried_structure.visible = false
	
	# Update interval based on game state
	var frequency_multiplier = game_manager.get_lightning_frequency() if game_manager else 1.0
	var base_min = min_lightning_interval / frequency_multiplier
	var base_max = max_lightning_interval / frequency_multiplier
	_time_until_lightning = randf_range(base_min, base_max)

func _play_thunder() -> void:
	# Thunder sound placeholder
	pass

func _on_world_state_changed(state: int) -> void:
	match state:
		game_manager.WorldState.STORM_PAUSED:
			# Briefly clear the storm
			_clear_storm()
			await get_tree().create_timer(5.0).timeout
			_restore_storm()

func _clear_storm() -> void:
	var snow = get_node_or_null("../Snow")
	if snow:
		snow.emitting = false
	environment.environment.fog_density = 0.002

func _restore_storm() -> void:
	var snow = get_node_or_null("../Snow")
	if snow:
		snow.emitting = true
	environment.environment.fog_density = 0.015

extends Node3D

@export var tower_id := 1
@export var activation_distance := 5.0
@export var interaction_key := KEY_E
@export var auto_position_on_terrain := true

@onready var activation_light: OmniLight3D = $ActivationLight
@onready var prompt_label: Label3D = $PromptLabel

var is_activated := false
var player_in_range := false
var player_ref: CharacterBody3D = null
var puzzle_ui: Control = null

func _ready() -> void:
	activation_light.visible = false
	prompt_label.visible = false
	
	# Position on terrain if enabled
	if auto_position_on_terrain:
		await get_tree().create_timer(0.5).timeout # Wait for terrain generation
		_position_on_terrain()
	
	# Connect to game manager
	var game_manager = get_node("/root/Main/GameManager")
	if game_manager:
		game_manager.tower_activated.connect(_on_tower_activated)
	
	# Get puzzle UI reference
	puzzle_ui = get_node("/root/Main/UI/PuzzleUI")
	if puzzle_ui:
		puzzle_ui.puzzle_completed.connect(_on_puzzle_completed)

func _position_on_terrain() -> void:
	var terrain = get_node_or_null("/root/Main/TerrainGenerator")
	if terrain and terrain.has_method("get_terrain_height_at"):
		var current_pos = global_position
		var terrain_height = terrain.get_terrain_height_at(current_pos.x, current_pos.z)
		global_position.y = terrain_height + 4.0 # Tower height offset

func _process(_delta: float) -> void:
	if is_activated:
		return
	
	# Check player distance
	if player_ref:
		var distance = global_position.distance_to(player_ref.global_position)
		player_in_range = distance < activation_distance
		prompt_label.visible = player_in_range
		
		if player_in_range and Input.is_key_pressed(interaction_key) and not puzzle_ui.is_active:
			start_puzzle()

func _on_body_entered(body: Node3D) -> void:
	if body.is_in_group("player"):
		player_ref = body

func _on_body_exited(body: Node3D) -> void:
	if body.is_in_group("player"):
		player_ref = null
		player_in_range = false
		prompt_label.visible = false

func start_puzzle() -> void:
	if is_activated or not puzzle_ui:
		return
	
	# Determine puzzle type based on tower
	var puzzle_type: int
	match tower_id:
		1:
			puzzle_type = puzzle_ui.PuzzleType.FUSE_REPLACEMENT
		2:
			puzzle_type = puzzle_ui.PuzzleType.SIGNAL_DISH
		3:
			puzzle_type = puzzle_ui.PuzzleType.FREQUENCY_DIAL
		4:
			puzzle_type = puzzle_ui.PuzzleType.POWER_ROUTING
		_:
			puzzle_type = puzzle_ui.PuzzleType.FUSE_REPLACEMENT
	
	puzzle_ui.show_puzzle(puzzle_type)

func _on_puzzle_completed() -> void:
	activate()

func activate() -> void:
	if is_activated:
		return
	
	is_activated = true
	activation_light.visible = true
	prompt_label.visible = false
	
	# Notify game manager
	var game_manager = get_node("/root/Main/GameManager")
	if game_manager:
		game_manager.activate_tower(tower_id)
	
	# Visual feedback
	var tween = create_tween()
	tween.tween_property(activation_light, "light_energy", 8.0, 0.5)
	tween.tween_property(activation_light, "light_energy", 3.0, 1.0)

func _on_tower_activated(activated_id: int) -> void:
	if activated_id == tower_id:
		is_activated = true
		activation_light.visible = true

extends CharacterBody3D

@export var mouse_sensitivity := 0.0018
@export var walk_speed := 5.4
@export var sprint_speed := 7.2
@export var jump_velocity := 4.8
@export var gravity := 14.0

@onready var head: Node3D = $Head

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	add_to_group("player")
	
	# Position on terrain
	await get_tree().create_timer(0.6).timeout
	_position_on_terrain()

func _position_on_terrain() -> void:
	var terrain = get_node_or_null("/root/Main/TerrainGenerator")
	if terrain and terrain.has_method("get_terrain_height_at"):
		var current_pos = global_position
		var terrain_height = terrain.get_terrain_height_at(current_pos.x, current_pos.z)
		global_position.y = terrain_height + 2.0

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		rotate_y(-event.relative.x * mouse_sensitivity)
		head.rotate_x(-event.relative.y * mouse_sensitivity)
		head.rotation.x = clamp(head.rotation.x, deg_to_rad(-87), deg_to_rad(87))
	elif event.is_action_pressed("ui_cancel"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	elif event is InputEventMouseButton and event.pressed and Input.mouse_mode != Input.MOUSE_MODE_CAPTURED:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y -= gravity * delta
	elif Input.is_action_just_pressed("jump"):
		velocity.y = jump_velocity

	var input_vector := Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
	var move_dir := (global_basis * Vector3(input_vector.x, 0, input_vector.y)).normalized()
	var speed := sprint_speed if Input.is_key_pressed(KEY_SHIFT) else walk_speed
	velocity.x = move_dir.x * speed
	velocity.z = move_dir.z * speed

	move_and_slide()
	
	# Update game manager with position
	var game_manager = get_node_or_null("/root/Main/GameManager")
	if game_manager:
		game_manager.update_player_position(global_position)

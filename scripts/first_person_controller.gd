extends CharacterBody3D

@export var mouse_sensitivity := 0.0018
@export var walk_speed := 5.4
@export var sprint_speed := 7.2
@export var jump_velocity := 4.8
@export var gravity := 14.0
@export var footprint_interval := 0.24
@export var footprint_mesh: Mesh
@export var footprint_material: Material
@export var max_footprints := 180

@onready var head: Node3D = $Head

var _footprint_timer := 0.0
var _last_left := false
var _footprints: Array[Node3D] = []

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

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

	_track_footprints(delta, move_dir)

func _track_footprints(delta: float, move_dir: Vector3) -> void:
	if not is_on_floor() or move_dir.length() < 0.15:
		_footprint_timer = footprint_interval
		return

	_footprint_timer -= delta
	if _footprint_timer > 0.0:
		return

	_footprint_timer = footprint_interval
	var side := 0.16 if _last_left else -0.16
	_last_left = not _last_left

	var footprint := MeshInstance3D.new()
	footprint.mesh = footprint_mesh
	if footprint_material:
		footprint.material_override = footprint_material

	var local_offset := Vector3(side, -0.79, 0)
	var base_position := global_transform.origin + global_basis * local_offset
	footprint.global_position = Vector3(base_position.x, 0.02, base_position.z)
	footprint.rotate_y(rotation.y + randf_range(-0.12, 0.12))
	get_tree().current_scene.add_child(footprint)

	_footprints.append(footprint)
	if _footprints.size() > max_footprints:
		var oldest := _footprints.pop_front()
		if is_instance_valid(oldest):
			oldest.queue_free()

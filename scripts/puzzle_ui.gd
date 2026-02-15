extends Control

signal puzzle_completed

enum PuzzleType {
	FUSE_REPLACEMENT, # Tower 1 - Click 4 fuses in correct order
	SIGNAL_DISH, # Tower 2 - Rotate dish to align with signal
	FREQUENCY_DIAL, # Tower 3 - Rotate dial to match frequency
	POWER_ROUTING # Tower 4 - Connect power nodes in sequence
}

@export var puzzle_type := PuzzleType.FUSE_REPLACEMENT
@export var difficulty := 1

@onready var puzzle_panel: Panel = $PuzzlePanel
@onready var title_label: Label = $PuzzlePanel/TitleLabel
@onready var puzzle_container: Control = $PuzzlePanel/PuzzleContainer
@onready var close_button: Button = $PuzzlePanel/CloseButton

var is_active := false
var puzzle_state := {}

func _ready() -> void:
	visible = false
	close_button.pressed.connect(_on_close_pressed)
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func show_puzzle(type: PuzzleType) -> void:
	puzzle_type = type
	visible = true
	is_active = true
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	_setup_puzzle()

func hide_puzzle() -> void:
	visible = false
	is_active = false
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	_clear_puzzle()

func _setup_puzzle() -> void:
	_clear_puzzle()
	
	match puzzle_type:
		PuzzleType.FUSE_REPLACEMENT:
			_setup_fuse_puzzle()
		PuzzleType.SIGNAL_DISH:
			_setup_dish_puzzle()
		PuzzleType.FREQUENCY_DIAL:
			_setup_frequency_puzzle()
		PuzzleType.POWER_ROUTING:
			_setup_routing_puzzle()

func _clear_puzzle() -> void:
	for child in puzzle_container.get_children():
		child.queue_free()
	puzzle_state.clear()

func _setup_fuse_puzzle() -> void:
	title_label.text = "FUSE PANEL - Replace Damaged Fuses"
	
	var grid = GridContainer.new()
	grid.columns = 2
	grid.add_theme_constant_override("h_separation", 20)
	grid.add_theme_constant_override("v_separation", 20)
	puzzle_container.add_child(grid)
	
	puzzle_state.fuses_fixed = []
	puzzle_state.correct_order = [0, 2, 1, 3] # Order matters
	puzzle_state.current_index = 0
	
	for i in range(4):
		var fuse_btn = Button.new()
		fuse_btn.text = "FUSE %d\n[DAMAGED]" % (i + 1)
		fuse_btn.custom_minimum_size = Vector2(150, 100)
		fuse_btn.add_theme_color_override("font_color", Color.RED)
		fuse_btn.pressed.connect(_on_fuse_pressed.bind(i))
		grid.add_child(fuse_btn)

func _on_fuse_pressed(fuse_id: int) -> void:
	if fuse_id != puzzle_state.correct_order[puzzle_state.current_index]:
		# Wrong order - reset
		puzzle_state.current_index = 0
		_setup_fuse_puzzle()
		return
	
	puzzle_state.current_index += 1
	
	var btn = puzzle_container.get_child(0).get_child(fuse_id)
	btn.text = "FUSE %d\n[FIXED]" % (fuse_id + 1)
	btn.add_theme_color_override("font_color", Color.GREEN)
	btn.disabled = true
	
	if puzzle_state.current_index >= 4:
		await get_tree().create_timer(0.5).timeout
		_complete_puzzle()

func _setup_dish_puzzle() -> void:
	title_label.text = "SIGNAL ALIGNMENT - Rotate Dish to Target"
	
	var vbox = VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 20)
	puzzle_container.add_child(vbox)
	
	var signal_label = Label.new()
	signal_label.text = "Signal Strength: 0%"
	signal_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(signal_label)
	
	var progress = ProgressBar.new()
	progress.custom_minimum_size = Vector2(300, 30)
	progress.max_value = 100
	vbox.add_child(progress)
	
	var hbox = HBoxContainer.new()
	hbox.add_theme_constant_override("separation", 10)
	vbox.add_child(hbox)
	
	var left_btn = Button.new()
	left_btn.text = "← Rotate Left"
	left_btn.custom_minimum_size = Vector2(140, 50)
	left_btn.pressed.connect(_on_dish_rotate.bind(-15))
	hbox.add_child(left_btn)
	
	var right_btn = Button.new()
	right_btn.text = "Rotate Right →"
	right_btn.custom_minimum_size = Vector2(140, 50)
	right_btn.pressed.connect(_on_dish_rotate.bind(15))
	hbox.add_child(right_btn)
	
	puzzle_state.target_angle = 180 # Target position
	puzzle_state.current_angle = 0

func _on_dish_rotate(delta_angle: float) -> void:
	puzzle_state.current_angle += delta_angle
	puzzle_state.current_angle = fmod(puzzle_state.current_angle, 360)
	
	var diff = abs(puzzle_state.current_angle - puzzle_state.target_angle)
	if diff > 180:
		diff = 360 - diff
	
	var signal_strength = 100 - (diff / 180.0 * 100.0)
	
	var vbox = puzzle_container.get_child(0)
	var label = vbox.get_child(0)
	var progress = vbox.get_child(1)
	
	label.text = "Signal Strength: %d%%" % int(signal_strength)
	progress.value = signal_strength
	
	if signal_strength > 95:
		await get_tree().create_timer(0.5).timeout
		_complete_puzzle()

func _setup_frequency_puzzle() -> void:
	title_label.text = "FREQUENCY CALIBRATION - Match Target Signal"
	
	var vbox = VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 20)
	puzzle_container.add_child(vbox)
	
	var target_label = Label.new()
	target_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(target_label)
	
	var current_label = Label.new()
	current_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(current_label)
	
	var slider = HSlider.new()
	slider.custom_minimum_size = Vector2(300, 30)
	slider.min_value = 0
	slider.max_value = 100
	slider.step = 1
	slider.value_changed.connect(_on_frequency_changed)
	vbox.add_child(slider)
	
	puzzle_state.target_frequency = randi_range(30, 70)
	puzzle_state.current_frequency = 0
	
	target_label.text = "TARGET: %.1f MHz" % puzzle_state.target_frequency
	current_label.text = "CURRENT: %.1f MHz" % puzzle_state.current_frequency

func _on_frequency_changed(value: float) -> void:
	puzzle_state.current_frequency = value
	
	var vbox = puzzle_container.get_child(0)
	var current_label = vbox.get_child(1)
	current_label.text = "CURRENT: %.1f MHz" % value
	
	if abs(value - puzzle_state.target_frequency) < 2:
		current_label.add_theme_color_override("font_color", Color.GREEN)
		await get_tree().create_timer(1.0).timeout
		_complete_puzzle()
	else:
		current_label.add_theme_color_override("font_color", Color.WHITE)

func _setup_routing_puzzle() -> void:
	title_label.text = "POWER ROUTING - Connect Nodes in Sequence"
	
	var grid = GridContainer.new()
	grid.columns = 3
	grid.add_theme_constant_override("h_separation", 15)
	grid.add_theme_constant_override("v_separation", 15)
	puzzle_container.add_child(grid)
	
	puzzle_state.nodes_connected = []
	puzzle_state.correct_sequence = [0, 3, 6, 7, 4, 1, 2, 5, 8]
	puzzle_state.current_step = 0
	
	for i in range(9):
		var node_btn = Button.new()
		node_btn.text = "NODE %d" % i
		node_btn.custom_minimum_size = Vector2(90, 90)
		node_btn.pressed.connect(_on_node_pressed.bind(i))
		grid.add_child(node_btn)

func _on_node_pressed(node_id: int) -> void:
	if node_id != puzzle_state.correct_sequence[puzzle_state.current_step]:
		# Wrong node - reset
		puzzle_state.current_step = 0
		_setup_routing_puzzle()
		return
	
	puzzle_state.current_step += 1
	
	var btn = puzzle_container.get_child(0).get_child(node_id)
	btn.text = "✓ %d" % puzzle_state.current_step
	btn.add_theme_color_override("font_color", Color.GREEN)
	btn.disabled = true
	
	if puzzle_state.current_step >= 9:
		await get_tree().create_timer(0.5).timeout
		_complete_puzzle()

func _complete_puzzle() -> void:
	puzzle_completed.emit()
	hide_puzzle()

func _on_close_pressed() -> void:
	hide_puzzle()

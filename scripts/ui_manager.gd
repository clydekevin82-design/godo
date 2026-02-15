extends CanvasLayer

@onready var story_panel: Panel = $StoryPanel
@onready var story_label: Label = $StoryPanel/MarginContainer/StoryLabel
@onready var objective_label: Label = $ObjectiveLabel
@onready var fade_rect: ColorRect = $FadeRect

var current_objective := "Locate Tower 1 - Power Reboot"

func _ready() -> void:
	story_panel.visible = false
	objective_label.text = current_objective
	fade_rect.visible = false
	
	# Connect to game manager
	var game_manager = get_node("/root/Main/GameManager")
	if game_manager:
		game_manager.story_beat.connect(_on_story_beat)
		game_manager.tower_activated.connect(_on_tower_activated)

func _on_story_beat(message: String) -> void:
	story_label.text = message
	story_panel.visible = true
	
	# Auto-hide after reading
	await get_tree().create_timer(6.0).timeout
	
	var tween = create_tween()
	tween.tween_property(story_panel, "modulate:a", 0.0, 1.0)
	await tween.finished
	story_panel.visible = false
	story_panel.modulate.a = 1.0

func _on_tower_activated(tower_id: int) -> void:
	match tower_id:
		1:
			current_objective = "Locate Tower 2 - Signal Calibration"
		2:
			current_objective = "Locate Tower 3 - Climate Control"
		3:
			current_objective = "Locate Tower 4 - Containment Lock"
		4:
			current_objective = "Survive."
	
	objective_label.text = current_objective

func show_fade(duration: float = 2.0) -> void:
	fade_rect.visible = true
	fade_rect.modulate.a = 0.0
	var tween = create_tween()
	tween.tween_property(fade_rect, "modulate:a", 1.0, duration)

func hide_fade(duration: float = 2.0) -> void:
	var tween = create_tween()
	tween.tween_property(fade_rect, "modulate:a", 0.0, duration)
	await tween.finished
	fade_rect.visible = false

extends Control

@onready var resume_button = $Panel/MarginContainer/VBoxContainer/ResumeButton
@onready var main_panel = $Panel
@onready var controls_button = $Panel/MarginContainer/VBoxContainer/SettingsButton
@onready var back_button = $Panel/MarginContainer/VBoxContainer/CloseButton

var scene_tree: SceneTree

func _ready() -> void:
	scene_tree = get_tree()
	process_mode = Node.PROCESS_MODE_ALWAYS
	hide()
	
	resume_button.pressed.connect(_on_resume_button_pressed)
	controls_button.pressed.connect(_on_controls_button_pressed)
	back_button.pressed.connect(_on_back_button_pressed)

func _on_controls_button_pressed() -> void:
	get_tree().paused = false
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	GameplaySettings.previous_scene = get_tree().current_scene.scene_file_path
	GameplaySettings.save_player_state()
	get_tree().change_scene_to_file("res://scenes/settings_page.tscn")
	
func _on_back_button_pressed() -> void:
	scene_tree.paused = false
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	scene_tree.change_scene_to_file("res://scenes/node_2d.tscn")
	
func _on_resume_button_pressed() -> void:
	get_tree().paused = false
	hide()
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("esc"):
		toggle_pause()
		
func toggle_pause() -> void:
	if get_tree().paused:
		get_tree().paused = false
		hide()
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	else:
		get_tree().paused = true
		show()
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

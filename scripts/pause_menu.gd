extends Control

@onready var resume_button = $Panel/MarginContainer/VBoxContainer/ResumeButton
@onready var main_panel = $Panel
@onready var controls_panel = $ControlsPanel
@onready var controls_button = $Panel/MarginContainer/VBoxContainer/SettingsButton
@onready var back_button = $ControlsPanel/Panel/MarginContainer/ScrollContainer/VBoxContainer/Panel/MarginContainer3/HBoxContainer/BackButton


func _ready() -> void:
	
	process_mode = Node.PROCESS_MODE_ALWAYS
	hide()
	
	resume_button.pressed.connect(_on_resume_button_pressed)
	controls_button.pressed.connect(_on_controls_button_pressed)
	back_button.pressed.connect(_on_back_button_pressed)

func _on_controls_button_pressed() -> void:
	main_panel.hide()
	controls_panel.show()
	
func _on_back_button_pressed() -> void:
	controls_panel.hide()
	main_panel.show()
	
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

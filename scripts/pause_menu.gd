extends Control

@onready var resume_button = $Panel/MarginContainer/VBoxContainer/ResumeButton

func _ready() -> void:
	
	process_mode = Node.PROCESS_MODE_ALWAYS
	hide()
	
	resume_button.pressed.connect(_on_resume_button_pressed)

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

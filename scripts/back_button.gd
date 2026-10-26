extends Button

func _ready() -> void:
	pressed.connect(_on_back_button_pressed)

func _on_back_button_pressed() -> void:
	if GameplaySettings.previous_scene != "":
		get_tree().change_scene_to_file(GameplaySettings.previous_scene)
	else:
		get_tree().change_scene_to_file("res://scenes/node_2d.tscn")

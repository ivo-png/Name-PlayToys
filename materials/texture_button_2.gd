extends TextureButton

func _ready() -> void:
	pivot_offset = size / 2
	
	# Подключаем все необходимые сигналы мыши
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)
	button_down.connect(_on_button_down)
	button_up.connect(_on_button_up)
	pressed.connect(_on_pressed)

func _on_mouse_entered() -> void:
	var tween = create_tween()
	tween.tween_property(self, "scale", Vector2(1.03, 1.03), 0.1).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)

func _on_mouse_exited() -> void:
	var tween = create_tween()
	tween.tween_property(self, "scale", Vector2(1.0, 1.0), 0.1).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)

func _on_button_down() -> void:
	var tween = create_tween()
	tween.tween_property(self, "scale", Vector2(1.06, 1.06), 0.05).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)

func _on_button_up() -> void:
	var tween = create_tween()
	if is_hovered():
		tween.tween_property(self, "scale", Vector2(1.03, 1.03), 0.05).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	else:
		tween.tween_property(self, "scale", Vector2(1.0, 1.0), 0.05).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)

func _on_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/main.tscn")

extends TextureButton

func _ready() -> void:
	# Настраиваем центр масштабирования кнопки, чтобы она росла из середины
	pivot_offset = size / 2
	
	# Подключаем сигналы мыши и нажатия
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)
	button_down.connect(_on_button_down)
	pressed.connect(_on_pressed)

func _on_mouse_entered() -> void:
	# При наведении плавно увеличиваем на 3%
	var tween = create_tween()
	tween.tween_property(self, "scale", Vector2(1.03, 1.03), 0.1).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)

func _on_mouse_exited() -> void:
	# Возвращаем размер к 100%, когда мышь уходит
	var tween = create_tween()
	tween.tween_property(self, "scale", Vector2(1.0, 1.0), 0.1).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)

func _on_button_down() -> void:
	# При физическом клике увеличиваем до 6%
	var tween = create_tween()
	tween.tween_property(self, "scale", Vector2(1.06, 1.06), 0.05).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)

func _on_pressed() -> void:
	# Команда Godot, которая полностью закрывает игру и выключает приложение
	get_tree().quit()

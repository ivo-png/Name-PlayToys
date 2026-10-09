extends TextureButton

func _ready() -> void:
	# Настраиваем центр масштабирования кнопки, чтобы она росла из середины
	pivot_offset = size / 2
	
	# Подключаем все необходимые сигналы мыши
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)
	button_down.connect(_on_button_down)
	button_up.connect(_on_button_up)

func _on_mouse_entered() -> void:
	# При наведении курсора плавно УВЕЛИЧИВАЕМ кнопку на 3% (масштаб 1.03)
	var tween = create_tween()
	tween.tween_property(self, "scale", Vector2(1.03, 1.03), 0.1).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)

func _on_mouse_exited() -> void:
	# Возвращаем размер обратно к исходным 100% (масштаб 1.0), когда мышь уходит с кнопки
	var tween = create_tween()
	tween.tween_property(self, "scale", Vector2(1.0, 1.0), 0.1).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)

func _on_button_down() -> void:
	# При нажатии кнопка становится ЕЩЕ ЧУТЬ БОЛЬШЕ — увеличивается до 6% (масштаб 1.06)
	var tween = create_tween()
	tween.tween_property(self, "scale", Vector2(1.06, 1.06), 0.05).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)

func _on_button_up() -> void:
	var tween = create_tween()
	# Если после клика мышь всё еще над кнопкой — плавно возвращаем её к размеру наведения (1.03)
	if is_hovered():
		tween.tween_property(self, "scale", Vector2(1.03, 1.03), 0.05).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	# Если игрок нажал, увел курсор в сторону и там отпустил — возвращаем обычный размер (1.0)
	else:
		tween.tween_property(self, "scale", Vector2(1.0, 1.0), 0.05).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)

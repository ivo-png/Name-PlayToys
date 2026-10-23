extends Control

@export var sensitivity_slider: HSlider
@export var fov_slider: HSlider
@onready var sensitivity_value: Label = $"ColorRect/VBoxContainer/GlobalMargin/Pages/Геймплей/MarginContainer/VBoxContainer/Panel/MarginContainer/VBoxContainer/SensitivitValue"
@onready var fov_value: Label = $"ColorRect/VBoxContainer/GlobalMargin/Pages/Геймплей/MarginContainer/VBoxContainer/Panel2/MarginContainer/VBoxContainer/FovValue"

var player: CharacterBody3D


func _ready() -> void:
	player = get_tree().get_first_node_in_group("player") as CharacterBody3D

	sensitivity_slider.set_value_no_signal(GameplaySettings.mouse_sensitivity)
	fov_slider.set_value_no_signal(GameplaySettings.camera_fov)

	sensitivity_slider.value_changed.connect(_on_sensitivity_changed)
	fov_slider.value_changed.connect(_on_fov_changed)
	sensitivity_value.text = "Чувствительность мыши: " + str(roundi(sensitivity_slider.value)) + "%"
	fov_value.text = "Дальность обзора: " + str(roundi(fov_slider.value)) + "%"

	_apply_settings_to_player()


func _apply_settings_to_player() -> void:
	if player == null:
		return

	player.set_mouse_sensitivity(GameplaySettings.mouse_sensitivity * 0.00005)
	player.set_camera_fov(GameplaySettings.camera_fov)


func _on_sensitivity_changed(value: float) -> void:
	GameplaySettings.mouse_sensitivity = value
	sensitivity_value.text = "Чувствительность мыши: " + str(roundi(value)) + "%"
	_apply_settings_to_player()


func _on_fov_changed(value: float) -> void:
	GameplaySettings.camera_fov = value
	fov_value.text = "Дальность обзора: " + str(roundi(value)) + "%"
	_apply_settings_to_player()

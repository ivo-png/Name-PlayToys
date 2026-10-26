extends Node

var mouse_sensitivity: float = 20.0
var camera_fov: float = 75.0
var previous_scene: String = ""

var has_saved_player_state: bool = false

var saved_player_position: Vector3 = Vector3.ZERO
var saved_player_rotation: Vector3 = Vector3.ZERO

var saved_camera_position: Vector3 = Vector3.ZERO
var saved_camera_rotation: Vector3 = Vector3.ZERO
const SETTINGS_PATH: String = "user://settings.cfg"
const PLAYER_SAVE_PATH: String = "user://player_save.cfg"

func _ready() -> void:
	load_settings()
	load_player_state()
	

func save_settings() -> void:
	var config := ConfigFile.new()

	config.set_value("gameplay", "mouse_sensitivity", mouse_sensitivity)
	config.set_value("gameplay", "camera_fov", camera_fov)

	var error := config.save(SETTINGS_PATH)

	if error != OK:
		push_error("Не удалось сохранить настройки. Код ошибки: " + str(error))


func load_settings() -> void:
	var config := ConfigFile.new()

	var error := config.load(SETTINGS_PATH)

	if error != OK:
		if error != ERR_FILE_NOT_FOUND:
			push_warning("Не удалось загрузить настройки. Код ошибки: " + str(error))
		return

	mouse_sensitivity = float(
		config.get_value("gameplay", "mouse_sensitivity", 50.0)
	)

	camera_fov = float(
		config.get_value("gameplay", "camera_fov", 75.0)
	)

func save_player_state() -> void:
	var player = get_tree().get_first_node_in_group("player") as CharacterBody3D

	if player == null:
		push_warning("Игрок не найден. Позиция не сохранена.")
		return

	var camera_pivot = player.get_node_or_null("CollisionShape3D/CameraPivot") as Node3D

	if camera_pivot == null:
		push_warning("CameraPivot не найден. Позиция не сохранена.")
		return

	saved_player_position = player.global_position
	saved_player_rotation = player.global_rotation

	saved_camera_position = camera_pivot.position
	saved_camera_rotation = camera_pivot.rotation

	var config := ConfigFile.new()

	config.set_value("player", "position", saved_player_position)
	config.set_value("player", "rotation", saved_player_rotation)
	config.set_value("camera", "position", saved_camera_position)
	config.set_value("camera", "rotation", saved_camera_rotation)

	var error := config.save(PLAYER_SAVE_PATH)

	if error != OK:
		push_error("Не удалось сохранить позицию игрока. Код ошибки: " + str(error))
		return

	has_saved_player_state = true
	

func load_player_state() -> void:
	var config := ConfigFile.new()

	var error := config.load(PLAYER_SAVE_PATH)

	if error != OK:
		if error != ERR_FILE_NOT_FOUND:
			push_warning("Не удалось загрузить позицию игрока. Код ошибки: " + str(error))

		has_saved_player_state = false
		return

	saved_player_position = config.get_value(
		"player", "position", Vector3.ZERO
	)

	saved_player_rotation = config.get_value(
		"player", "rotation", Vector3.ZERO
	)

	saved_camera_position = config.get_value(
		"camera", "position", Vector3.ZERO
	)

	saved_camera_rotation = config.get_value(
		"camera", "rotation", Vector3.ZERO
	)

	has_saved_player_state = true


	

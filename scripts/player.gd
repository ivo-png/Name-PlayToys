extends CharacterBody3D

const SPEED = 3
const JUMP = 5.2
const GRAVITY = 15.0
const SPRINT_SPEED = 4.5

const MAX_STAMINA = 100.0
const STAMINA_DRAIN = 20.0
const STAMINA_REGEN = 15.0

const BOB_SPEED = 13.0
const BOB_AMOUNT = 0.03

@onready var camera_pivot = $CollisionShape3D/CameraPivot
@onready var stamina_bar = $CanvasLayer/StaminaBar
@onready var camera = $CollisionShape3D/CameraPivot/Camera3D

var mouse_sensitivity = 0.001
var camera_rotation_x = 0.0
var stamina = MAX_STAMINA
var exhausted = false
var bob_time = 0.0
var rotation_velocity = 0.0
var rotation_smoothness = 3.0
var camera_fov = 75.0


func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

	mouse_sensitivity = GameplaySettings.mouse_sensitivity * 0.00005
	camera_fov = GameplaySettings.camera_fov
	camera.fov = camera_fov

	if GameplaySettings.has_saved_player_state:
		global_position = GameplaySettings.saved_player_position
		global_rotation = GameplaySettings.saved_player_rotation

		camera_pivot.position = GameplaySettings.saved_camera_position
		camera_pivot.rotation = GameplaySettings.saved_camera_rotation

		camera_rotation_x = camera_pivot.rotation.x

		GameplaySettings.has_saved_player_state = false

	if stamina_bar and stamina_bar.has_method("set_ratio"):
		stamina_bar.set_ratio(stamina / MAX_STAMINA, exhausted)


func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		rotation_velocity = -event.relative.x * mouse_sensitivity * 3

		camera_rotation_x += event.relative.y * mouse_sensitivity
		camera_rotation_x = clamp(camera_rotation_x, -0.8, 1)

		camera_pivot.rotation.x = camera_rotation_x


func _physics_process(delta: float) -> void:
	rotate_y(rotation_velocity)
	rotation_velocity = lerp(rotation_velocity, 0.0, rotation_smoothness * delta)

	var moving_vec = Vector3()

	if Input.is_action_pressed("move_forwards"):
		moving_vec.z += 1

	if Input.is_action_pressed("move_backwards"):
		moving_vec.z -= 1

	if Input.is_action_pressed("move_right"):
		moving_vec.x -= 1

	if Input.is_action_pressed("move_left"):
		moving_vec.x += 1

	var is_moving = moving_vec.length() > 0
	moving_vec = moving_vec.normalized()
	var current_speed = SPEED

	if is_moving and is_on_floor():
		bob_time += delta * BOB_SPEED
		camera_pivot.position.y = sin(bob_time) * BOB_AMOUNT
	else:
		bob_time = 0.0
		camera_pivot.position.y = 0.0

	if Input.is_action_pressed("sprint") and is_moving and stamina > 0 and not exhausted:
		current_speed = SPRINT_SPEED
		stamina -= STAMINA_DRAIN * delta
		if stamina <= 0.0:
			exhausted = true
	else:
		stamina += STAMINA_REGEN * delta
		if exhausted and stamina >= MAX_STAMINA:
			exhausted = false

	stamina = clamp(stamina, 0.0, MAX_STAMINA)

	if stamina_bar and stamina_bar.has_method("set_ratio"):
		stamina_bar.set_ratio(stamina / MAX_STAMINA, exhausted)

	moving_vec *= current_speed

	velocity.x = (transform.basis * moving_vec).x
	velocity.z = (transform.basis * moving_vec).z

	if not is_on_floor():
		velocity.y -= GRAVITY * delta

	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP

	move_and_slide()


func set_camera_fov(value: float) -> void:
	camera.fov = value


func set_mouse_sensitivity(value: float) -> void:
	mouse_sensitivity = value

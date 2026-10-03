
extends CharacterBody3D


const SPEED = 3
const JUMP = 5
const GRAVITY = 14.0
const SPRINT_SPEED = 4.5

const MAX_STAMINA = 100.0
const STAMINA_DRAIN = 20.0
const STAMINA_REGEN = 15.0

const BOB_SPEED = 12.0
const BOB_AMOUNT = 0.05

@onready var camera_pivot = $CollisionShape3D/CameraPivot
@onready var stamina_bar = $CanvasLayer/StaminaBar


var mouse_sensitivity = 0.001
var camera_rotation_x = 0.0
var stamina = MAX_STAMINA
var bob_time = 0.0
var rotation_velocity = 0.0
var rotation_smoothness = 3.0


func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

	stamina_bar.max_value = 100
	stamina_bar.value = stamina


func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		rotation_velocity = -event.relative.x * mouse_sensitivity * 3

		camera_rotation_x += event.relative.y * mouse_sensitivity
		camera_rotation_x = clamp(camera_rotation_x, -0.5, 0.5)

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

	if Input.is_action_pressed("sprint") and is_moving and stamina > 0:
		current_speed = SPRINT_SPEED
		stamina -= STAMINA_DRAIN * delta
	else:
		stamina += STAMINA_REGEN * delta

	stamina = clamp(stamina, 0.0, MAX_STAMINA)
	stamina_bar.value = stamina

	moving_vec *= current_speed

	velocity.x = (transform.basis * moving_vec).x
	velocity.z = (transform.basis * moving_vec).z

	if not is_on_floor():
		velocity.y -= GRAVITY * delta

	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP

	move_and_slide()

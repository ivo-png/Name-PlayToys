extends Button

@export var action_name: String = "jump"

var wainting_for_key = false


func _ready() -> void:
	pressed.connect(_on_pressed)
	update_key_text()


func _on_pressed() -> void:
	wainting_for_key = true
	text = "[ ... ]"


func update_key_text() -> void:
	var events = InputMap.action_get_events(action_name)

	if events.size() > 0:
		var key_event = events[0] as InputEventKey
		
		if key_event:
			text = "[ " + key_event.as_text_physical_keycode() + " ]"


func is_key_used(key_code: int) -> bool:
	var actions = InputMap.get_actions()

	for action in actions:
		if action == action_name:
			continue

		var events = InputMap.action_get_events(action)

		for event in events:
			if event is InputEventKey:
				if event.physical_keycode == key_code:
					return true

	return false


func _input(event: InputEvent) -> void:
	if not wainting_for_key:
		return
	
	if event is InputEventKey and event.pressed:
		if is_key_used(event.physical_keycode):
			text = "[ Уже используется ]"
			wainting_for_key = false
			return
		
		var new_key = InputEventKey.new()
		new_key.physical_keycode = event.physical_keycode
		
		InputMap.action_erase_events(action_name)
		InputMap.action_add_event(action_name, new_key)
		
		text = "[ " + event.as_text_physical_keycode() + " ]"
		wainting_for_key = false

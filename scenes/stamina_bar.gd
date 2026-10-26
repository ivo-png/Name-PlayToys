class_name StaminaBar
extends AnimatedSprite2D

@export var frames_dir := "res://ui/stamina/"
@export var frames_prefix := "stamina_"
@export var frames_count := 576
@export var bottom_margin := 90.0
@export var bar_scale := 1.0
@export var auto_hide := true
@export var hide_delay := 1.0
@export var open_time := 0.6
@export var close_time := 0.6

const OPEN_START := 0
const OPEN_END := 35
const DRAIN_START := 60
const DRAIN_END := 277
const REFILL_START := 294
const REFILL_END := 515
const CLOSE_START := 540
const LAST := 575

enum State { HIDDEN, OPENING, VISIBLE, CLOSING }

var state := State.HIDDEN
var use_fallback := false

var _tween: Tween
var _drain_table := PackedFloat32Array()
var _refill_table := PackedFloat32Array()
var _ratio := 1.0
var _exhausted := false
var _idle := 0.0
var _blink := 0.0


func _ready() -> void:
	z_index = 100
	modulate = Color(1, 1, 1, 1)
	_build_tables()
	var ok := _build_frames()
	if ok == true:
		animation = "all"
		pause()
		frame = OPEN_START
		visible = false
		print("StaminaBar: загружено кадров ", sprite_frames.get_frame_count("all"), ", auto_hide = ", auto_hide)
		if auto_hide == false:
			show_bar()
	else:
		use_fallback = true
		visible = true
		push_warning("StaminaBar: кадры не найдены, включена запасная шкала")
	_place()
	get_viewport().size_changed.connect(_place)

func _base_size() -> Vector2:
	if sprite_frames != null and sprite_frames.has_animation("all") \
			and sprite_frames.get_frame_count("all") > 0:
		return sprite_frames.get_frame_texture("all", 0).get_size()
	return Vector2(600, 22)   

func _s(t: float) -> float:
	return t * t * (3.0 - 2.0 * t)


func _build_tables() -> void:
	var n_d := DRAIN_END - DRAIN_START + 1
	for k in n_d:
		var t := float(k) / float(n_d - 1)
		_drain_table.append(1.0 - (_s(t) * 0.35 + t * 0.65))
	var n_r := REFILL_END - REFILL_START + 1
	for k in n_r:
		var t := float(k) / float(n_r - 1)
		_refill_table.append(t * 0.7 + _s(t) * 0.3)


func _build_frames() -> bool:
	var sf := SpriteFrames.new()
	sf.add_animation("all")
	sf.set_animation_loop("all", false)
	sf.set_animation_speed("all", 60.0)
	for i in frames_count:
		var path := "%s%s%04d.png" % [frames_dir, frames_prefix, i]
		var exists := ResourceLoader.exists(path)
		if exists == false:
			push_error("StaminaBar: нет файла " + path)
			return false
		var tex := load(path) as Texture2D
		if tex == null:
			push_error("StaminaBar: не загрузился " + path)
			return false
		sf.add_frame("all", tex)
	sprite_frames = sf
	return true


func _place() -> void:
	var vp := get_viewport_rect().size
	var base := Vector2(600, 22)  
	if sprite_frames != null and sprite_frames.has_animation("all") \
			and sprite_frames.get_frame_count("all") > 0:
		base = sprite_frames.get_frame_texture("all", 0).get_size()

	var s := 0.6                  
	scale = Vector2.ONE * s
	var half := base * s * 0.5

	var left_margin := 15.0       #
	var bottom_gap := 60.0        

	var x := left_margin + half.x
	var y := vp.y - bottom_gap - half.y
	position = Vector2(x, y)


func _set_f(i: int) -> void:
	if sprite_frames == null:
		return
	var count := sprite_frames.get_frame_count("all")
	if count <= 0:
		return
	frame = clampi(i, 0, count - 1)


func is_ready() -> bool:
	if use_fallback == true:
		return true
	return state == State.VISIBLE


func set_ratio(ratio: float, exhausted: bool) -> void:
	_ratio = clampf(ratio, 0.0, 1.0)
	_exhausted = exhausted
	if use_fallback == true:
		queue_redraw()
		return
	_apply_ratio()


func _closest(table: PackedFloat32Array, r: float) -> int:
	var best := 0
	var best_d := 999.0
	for i in table.size():
		var d := absf(table[i] - r)
		if d < best_d:
			best_d = d
			best = i
	return best


func _apply_ratio() -> void:
	if state != State.VISIBLE:
		return
	if _exhausted == true:
		_set_f(REFILL_START + _closest(_refill_table, _ratio))
	else:
		_set_f(DRAIN_START + _closest(_drain_table, _ratio))


func _process(delta: float) -> void:
	if use_fallback == true:
		_blink += delta
		if _exhausted == true:
			queue_redraw()
		return
	if auto_hide == false:
		return
	var full := false
	if _ratio >= 0.999 and _exhausted == false:
		full = true
	if state == State.VISIBLE:
		if full == true:
			_idle += delta
			if _idle >= hide_delay:
				hide_bar()
		else:
			_idle = 0.0
	elif state == State.HIDDEN:
		if full == false:
			show_bar()
	elif state == State.CLOSING:
		if full == false:
			show_bar()


func show_bar() -> void:
	if use_fallback == true:
		return
	if state == State.OPENING or state == State.VISIBLE:
		return
	_kill_tween()
	state = State.OPENING
	visible = true
	_set_f(OPEN_START)
	_tween = create_tween()
	_tween.tween_method(_tween_frame, float(OPEN_START), float(OPEN_END), open_time)
	_tween.finished.connect(_on_open_finished)


func _on_open_finished() -> void:
	state = State.VISIBLE
	_idle = 0.0
	_apply_ratio()


func hide_bar() -> void:
	if use_fallback == true:
		return
	if state != State.VISIBLE:
		return
	_kill_tween()
	state = State.CLOSING
	_set_f(CLOSE_START)
	_tween = create_tween()
	_tween.tween_method(_tween_frame, float(CLOSE_START), float(LAST), close_time)
	_tween.finished.connect(_on_close_finished)


func _on_close_finished() -> void:
	state = State.HIDDEN
	visible = false


func _tween_frame(v: float) -> void:
	_set_f(int(round(v)))


func _kill_tween() -> void:
	if _tween != null and _tween.is_valid():
		_tween.kill()


func _draw() -> void:
	if use_fallback == true:
		var w := 600.0
		var h := 22.0
		var back := Rect2(-w * 0.5, -h * 0.5, w, h)
		draw_rect(back, Color(0.05, 0.12, 0.22, 0.9))
		var col := Color(0.2, 0.7, 0.9, 1.0)
		if _exhausted == true:
			var phase := int(_blink * 8.0) % 2
			if phase == 1:
				col = Color(0.07, 0.18, 0.3, 1.0)
		draw_rect(Rect2(-w * 0.5, -h * 0.5, w * _ratio, h), col)
		draw_rect(back, Color(0.3, 0.6, 0.9, 1.0), false, 2.0)

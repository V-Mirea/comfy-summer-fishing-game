extends Node2D

signal bubble_hit(result: String)

const START_SCALE: float = 0.2

var lifetime: float = 1.0
var max_scale: float = 1.0
var perfect_start: float = 0.0
var perfect_end: float = 1.0
var good_start: float = 0.0
var good_end: float = 1.0

var elapsed_lifetime: float = 0.0
var resolved: bool = false

func _ready() -> void:
	scale = Vector2.ONE * START_SCALE
	$Area2D.input_event.connect(_on_area_input)

func _process(delta: float) -> void:
	if resolved:
		return

	elapsed_lifetime += delta

	var progress := elapsed_lifetime / lifetime
	scale = Vector2.ONE * lerp(START_SCALE, max_scale, progress)

	if elapsed_lifetime >= lifetime:
		_resolve("miss")

func _on_area_input(_viewport, event: InputEvent, _shape_idx: int) -> void:
	if resolved:
		return
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		_handle_click()

func _handle_click() -> void:
	var progress := elapsed_lifetime / lifetime
	_resolve(_classify(progress))

func _classify(progress: float) -> String:
	if progress >= perfect_start and progress <= perfect_end:
		return "perfect"
	if progress >= good_start and progress <= good_end:
		return "good"
	return "bad"

func _resolve(result: String) -> void:
	resolved = true
	print("Bubble resolved: ", result, " at progress ", elapsed_lifetime / lifetime)
	bubble_hit.emit(result)
	queue_free()

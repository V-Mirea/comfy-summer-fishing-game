extends Node2D

signal bubble_hit(result: String)

const RING_START_SCALE: float = 3.0
const POP_FRAME_DURATION: float = 0.05

@export var timing_ring: Sprite2D
@export var bubble_sprite: AnimatedSprite2D
@export var bubble_scale: float = 2.0

@export_group("Zone Colors")
@export var color_bad: Color = Color(0.853, 0.82, 0.792, 1.0)
@export var color_good: Color = Color(0.427, 0.371, 1.0, 1.0)
@export var color_perfect: Color = Color(0.816, 0.063, 0.0, 1.0)

var lifetime: float = 1.0
var perfect_start: float = 0.0
var perfect_end: float = 1.0
var good_start: float = 0.0

var elapsed_lifetime: float = 0.0
var resolved: bool = false
var popping: bool = false
var pop_frame: int = 3
var pop_timer: float = 0.0

#TODO, lets have a bubble spawning animation

func _ready() -> void:
	timing_ring.scale = Vector2.ONE * RING_START_SCALE
	bubble_sprite.scale = Vector2.ONE * bubble_scale
	$Area2D/CollisionShape2D.shape.radius = 22.0 * bubble_scale
	bubble_sprite.play("idle")

func _process(delta: float) -> void:
	if popping:
		_process_pop(delta)
		return

	if resolved:
		return

	elapsed_lifetime += delta
	var progress := elapsed_lifetime / lifetime

	var ring_scale = lerp(RING_START_SCALE, bubble_scale, progress)
	timing_ring.scale = Vector2.ONE * ring_scale
	timing_ring.frame = clampi(int(progress * 3), 0, 2)
	timing_ring.modulate = _get_zone_color(progress)

	if elapsed_lifetime >= lifetime:
		_resolve("miss")

func _process_pop(delta: float) -> void:
	pop_timer += delta
	if pop_timer >= POP_FRAME_DURATION:
		pop_timer -= POP_FRAME_DURATION
		pop_frame += 1
		if pop_frame > 6:
			queue_free()
			return
		timing_ring.frame = pop_frame

func _classify(progress: float) -> String:
	if progress >= perfect_start and progress <= perfect_end:
		return "perfect"
	if progress >= good_start and progress < perfect_start:
		return "good"
	return "bad"

func _get_zone_color(progress: float) -> Color:
	if progress < good_start:
		# bad -> good transition
		# maybe we could pull it out because i basically just c/p this over and over but just to lerp the colors to smoothen it
		var t := progress / good_start if good_start > 0.0 else 1.0 
		return color_bad.lerp(color_good, t)
	elif progress < perfect_start:
		# good -> perfect transition
		var zone_length := perfect_start - good_start
		var t := (progress - good_start) / zone_length if zone_length > 0.0 else 1.0
		return color_good.lerp(color_perfect, t)
	elif progress <= perfect_end:
		return color_perfect
	else:
		# perfect -> bad transition
		var zone_length := 1.0 - perfect_end
		var t := (progress - perfect_end) / zone_length if zone_length > 0.0 else 1.0
		return color_perfect.lerp(color_bad, t)

func _resolve(result: String) -> void:
	resolved = true
	bubble_hit.emit(result)

	if result == "miss":
		queue_free() #or should we just go to process pop and pop normally? animation wise
		return

	bubble_sprite.visible = false
	timing_ring.modulate = Color.WHITE
	timing_ring.scale = Vector2.ONE
	pop_frame = 3
	timing_ring.frame = pop_frame
	pop_timer = 0.0
	popping = true


func _on_area_2d_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if resolved:
		return
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		_handle_click()

func _handle_click() -> void:
	var progress := elapsed_lifetime / lifetime
	_resolve(_classify(progress))

extends Node2D

class_name BubbleManager

signal pattern_complete(score_data: Dictionary)
@export var BubbleScene: PackedScene
@export var spawn_area: Control

@export_group("Hit Windows")
@export var good_start: float = 0.45
@export var perfect_start: float = 0.95
@export var perfect_end: float = 1.1

var perfects: int = 0
var goods: int = 0
var bads: int = 0
var misses: int = 0
var bubbles_remaining: int = 0
var is_playing: bool = false
var lifetime: float = 1.0

func _ready() -> void:
	pass

func start_pattern(pattern: Array[BubbleStep], passedLifetime: float = 1.0) -> void:
	if is_playing:
		push_warning("Spawner asked to start a pattern while one is already playing.")
		return
	
	# Reset counters
	perfects = 0
	goods = 0
	bads = 0
	misses = 0

	# Survive partially-loaded data (e.g. null entries from an export
	# deserialization issue) so the minigame can never hard-freeze.
	var steps := pattern.filter(func(step): return step != null)
	bubbles_remaining = steps.size()
	lifetime = passedLifetime
	is_playing = true

	if steps.is_empty():
		push_warning("start_pattern called with no valid steps; resolving immediately.")
		_finish_pattern()
		return

	var offset := _calculate_spawn_offset(steps)
	for entry in steps:
		 #remove the await if we want to have an overall time schedule, but awaiting lets us define specific delays in between bubbles
		 # therefore, if a player clisk a bubble early, te next one still shows up at a good defined delay
		 # TODO: playtest required to see which one feels better
		_schedule_bubble(entry, offset)

func _calculate_spawn_offset(steps: Array) -> Vector2:
	if spawn_area == null:
		push_warning("No spawn_area set on BubbleManager; using origin.")
		return Vector2.ZERO

	var rect := spawn_area.get_rect()
	var radius := 44.0 # 22px base radius * 2.0 bubble_scale

	# find bounding box of all step positions
	var first_pos: Vector2 = steps[0].position
	var min_x: float = first_pos.x
	var max_x: float = first_pos.x
	var min_y: float = first_pos.y
	var max_y: float = first_pos.y
	for step in steps:
		min_x = minf(min_x, step.position.x)
		max_x = maxf(max_x, step.position.x)
		min_y = minf(min_y, step.position.y)
		max_y = maxf(max_y, step.position.y)

	# valid origin range so all bubbles + radius stay inside spawn rect
	var origin_min_x := rect.position.x - min_x + radius
	var origin_max_x := rect.position.x + rect.size.x - max_x - radius
	var origin_min_y := rect.position.y - min_y + radius
	var origin_max_y := rect.position.y + rect.size.y - max_y - radius

	# clamp if pattern is too large for area
	if origin_min_x > origin_max_x:
		origin_min_x = (origin_min_x + origin_max_x) / 2.0
		origin_max_x = origin_min_x
	if origin_min_y > origin_max_y:
		origin_min_y = (origin_min_y + origin_max_y) / 2.0
		origin_max_y = origin_min_y
	#TODO: maybe change it to be a sum of multiple rects, and bump up/around bubbles to fit in the bounding boxes

	var origin_x := randf_range(origin_min_x, origin_max_x)
	var origin_y := randf_range(origin_min_y, origin_max_y)
	return Vector2(origin_x, origin_y)

func _schedule_bubble(entry: BubbleStep, offset: Vector2) -> void:
	await get_tree().create_timer(entry.delay).timeout

	if not is_playing:
		return

	var bubble = BubbleScene.instantiate()
	bubble.position = entry.position + offset
	bubble.lifetime = lifetime
	bubble.perfect_start = perfect_start
	bubble.perfect_end = perfect_end
	bubble.good_start = good_start

	bubble.bubble_hit.connect(_on_bubble_hit)

	add_child(bubble)

func _on_bubble_hit(result: String) -> void:
	match result:
		"perfect":
			perfects += 1
		"good":
			goods += 1
		"bad":
			bads += 1
		"miss":
			misses += 1
	
	bubbles_remaining -= 1
	print("Bubble resolved (", result, "). Remaining: ", bubbles_remaining)
	
	if bubbles_remaining <= 0:
		_finish_pattern()

func _finish_pattern() -> void:
	is_playing = false
	var score_data = {
		"perfects": perfects,
		"goods": goods,
		"bads": bads,
		"misses": misses,
		"total": perfects + goods + bads + misses,
	}
	pattern_complete.emit(score_data)

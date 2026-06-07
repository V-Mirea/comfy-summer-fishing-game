extends Node2D

class_name BubbleManager

signal pattern_complete(score_data: Dictionary)
@export var BubbleScene: PackedScene

# anything clicked outside good is a 'bad'. perfect muST be contained in good window. fractions of the lifetime
@export_group("Hit Windows")
@export var perfect_start: float = 0.45
@export var perfect_end: float = 0.65
@export var good_start: float = 0.25
@export var good_end: float = 0.85
@export var max_scale: float = 1.0

var perfects: int = 0
var goods: int = 0
var bads: int = 0
var misses: int = 0
var bubbles_remaining: int = 0
var is_playing: bool = false

func _ready() -> void:
	pass

func start_pattern(pattern: Array[BubbleStep]) -> void:
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
	is_playing = true

	if steps.is_empty():
		push_warning("start_pattern called with no valid steps; resolving immediately.")
		_finish_pattern()
		return

	for entry in steps:
		_schedule_bubble(entry)

func _schedule_bubble(entry: BubbleStep) -> void:
	await get_tree().create_timer(entry.delay).timeout

	if not is_playing:
		return

	var bubble = BubbleScene.instantiate()
	bubble.position = entry.position
	bubble.lifetime = entry.lifetime
	bubble.max_scale = max_scale
	bubble.perfect_start = perfect_start
	bubble.perfect_end = perfect_end
	bubble.good_start = good_start
	bubble.good_end = good_end

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

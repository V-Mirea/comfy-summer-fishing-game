class_name DayTint
extends CanvasModulate

# tints the whole scene by time of day. instance day_tint.tscn at the root of a
# world scene. anything under a CanvasLayer (the UI) won't get tinted.

const TINT_MORNING := Color(0.72, 0.78, 0.92)
const TINT_MIDDAY := Color(1, 1, 1)
const TINT_EVENING := Color(0.95, 0.78, 0.62) 

const MIDDAY_HOUR := 12 * 60 # 12pm
const EVENING_HOUR := 19 * 60 # 7pm

const FADE_TIME := 1.5

var last_target: Color

func _ready() -> void:
	TimeManager.time_changed.connect(_on_time_changed)
	TimeManager.phase_changed.connect(_on_phase_changed)
	_snap_to(TimeManager.minutes)

func _on_time_changed(minutes: int) -> void:
	var target := _tint_for(minutes)
	if target == last_target:
		return 
	last_target = target
	apply_tint(target, FADE_TIME)

func _on_phase_changed(_phase: TimeManager.Phase) -> void:
	_snap_to(TimeManager.minutes) 

func _snap_to(minutes: int) -> void:
	last_target = _tint_for(minutes)
	color = last_target

func _tint_for(minutes: int) -> Color:
	if minutes < MIDDAY_HOUR:
		return TINT_MORNING
	elif minutes < EVENING_HOUR:
		return TINT_MIDDAY
	return TINT_EVENING

# fade_time > 0 to crossfade instead of snapping
func apply_tint(target: Color, fade_time: float = 0.0) -> void:
	if fade_time <= 0.0:
		color = target
	else:
		create_tween().tween_property(self, "color", target, fade_time)

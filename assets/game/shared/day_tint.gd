class_name DayTint
extends CanvasModulate

# tints the whole scene by time of day. instance day_tint.tscn at the root of a
# world scene. anything under a CanvasLayer (the UI) won't get tinted.

const TINT_MORNING := Color(0.72, 0.78, 0.92) # dim, cool
const TINT_AFTERNOON := Color(1, 1, 1) # no tint

func _ready() -> void:
	# hook this up to the time manager once it exists, something like
	# TimeManager.phase_changed.connect(...) then apply_tint per phase.
	# stays at whatever color it's set to in the editor til then
	pass

# fade_time > 0 to crossfade instead of snapping
func apply_tint(target: Color, fade_time: float = 0.0) -> void:
	if fade_time <= 0.0:
		color = target
	else:
		create_tween().tween_property(self, "color", target, fade_time)

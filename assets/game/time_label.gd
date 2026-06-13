extends Label

func _ready():
	TimeManager.time_changed.connect(_on_time_changed)
	TimeManager.phase_changed.connect(_on_phase_changed)
	_on_time_changed(TimeManager.minutes)
	_on_phase_changed(TimeManager.phase)

func _on_time_changed(minutes: int):
	var hour := minutes / 60
	var minute := minutes % 60
	var suffix := "AM" if hour < 12 else "PM"
	var hour12 := hour % 12
	if hour12 == 0:
		hour12 = 12 # midnight/noon read as 12, not 0
	text = "%d:%02d %s" % [hour12, minute, suffix]

func _on_phase_changed(phase: TimeManager.Phase):
	# only show during fishing/selling. hidden in buying + main menu (both OFF), potnetially more if we need to
	visible = phase != TimeManager.Phase.OFF

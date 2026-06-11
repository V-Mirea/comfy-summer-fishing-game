extends Resource
class_name DialogueLine

@export var text: String
@export var required_flags: Array[PlayerData.GameEvent] = []    # ALL must be true
@export var excluded_flags: Array[PlayerData.GameEvent] = []    # NONE must be true

# Used for dynamic checks that cannot be expressed as an event
@export var extra_condition: DialogueCondition = null

func is_available() -> bool:
	for flag in required_flags:
		if not PlayerManager.has_event_triggered(flag):
			return false
	for flag in excluded_flags:
		if PlayerManager.has_event_triggered(flag):
			return false
	if extra_condition != null:
		return extra_condition.evaluate()
	return true

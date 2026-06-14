extends Resource
class_name DialogueLine

@export var text: String
@export var portrait: Texture2D
@export var required_flags: Array[PlayerData.GameEvent] = []    # ALL must be true
@export var excluded_flags: Array[PlayerData.GameEvent] = []    # NONE must be true

# The text of the button needed clicked to reach this line.
# A blank value with no sibling dialogue lines will result in no button displayed, just a continue option
@export var button_text: String 
# List of possible dialogue lines that can come next
@export var next_lines: Array[DialogueLine]
# A list of scripts that will execute when the line is said
# They need to be of type DialogueScript
@export var dialogue_scripts: Array[Resource]
		
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

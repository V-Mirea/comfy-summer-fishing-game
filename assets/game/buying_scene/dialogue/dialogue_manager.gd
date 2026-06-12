extends Node
class_name DialogueManager

@export var dialogue_lines: Array[DialogueLine]

func get_dialogue() -> DialogueLine:
	for i in range(dialogue_lines.size() - 1, -1, -1):
		if dialogue_lines[i].is_available():
			return dialogue_lines[i]
	return null # TODO: get random line that matches flags

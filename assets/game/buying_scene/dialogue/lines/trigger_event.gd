extends DialogueScript
class_name TriggerEvent

@export var event: PlayerData.GameEvent

func execute():
	PlayerManager.trigger_event(event)

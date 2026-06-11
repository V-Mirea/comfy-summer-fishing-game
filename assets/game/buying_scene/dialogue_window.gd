extends CanvasLayer

@export var dialogue_label: Label
@export var dialogue_manager: DialogueManager
	
func close_window():
	get_tree().paused = false
	visible = false
	
func _input(event):
	if event.is_action_pressed("ui_cancel") and visible:
		get_viewport().set_input_as_handled()
		close_window()

func _on_exit_button_pressed():
	close_window()

func _on_open_dialogue_box():
	get_tree().paused = true
	visible = true
	
	dialogue_label.text = dialogue_manager.get_dialogue().text

func _on_confirm_button_pressed():
	PlayerManager.trigger_event(PlayerData.GameEvent.MET_LOUIS)
	close_window()

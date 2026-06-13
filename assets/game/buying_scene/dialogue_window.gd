extends CanvasLayer

@export var dialogue_label: Label
@export var button_container: Container
@export var dialogue_manager: DialogueManager

var current_line: DialogueLine

func _input(event):
	if visible and event.is_action_pressed("ui_close_dialog"):
		close_window()
		get_viewport().set_input_as_handled()

func close_window():
	visible = false
	get_tree().paused = false
		
func start_conversation():
	# we set make the panel visible after conversation has started
	# so if it is already visible, it means we're already in a conversation and should not proceed
	if visible:
		return
	
	current_line = dialogue_manager.get_dialogue()
	if current_line == null:
		printerr("Tried to start a conversation with no dialogue available in manager")
		return
	
	if !current_line.dialogue_scripts.is_empty():
		for script in current_line.dialogue_scripts:
			(script as DialogueScript).execute()
	
	dialogue_label.text = current_line.text
	create_response_buttons()
	
func continue_conversation(next_line: DialogueLine):
	current_line = next_line
	
	if !current_line.dialogue_scripts.is_empty():
		for script in current_line.dialogue_scripts:
			current_line.execute()
	
	dialogue_label.text = current_line.text
	create_response_buttons()
	
func create_response_buttons():
	for button in button_container.get_children():
		button.queue_free()
	
	if current_line.next_lines.is_empty():
		var option_button = Button.new()
		option_button.text = "End conversation"
		option_button.pressed.connect(close_window)
		button_container.add_child(option_button)
	else:
		for possible_line in current_line.next_lines:
			if possible_line.button_text.is_empty():
				if current_line.next_lines.size() > 1:
					push_warning("Ran into dialogue option with multiple possible next lines but at least one option has no button text", current_line)
					# TODO: this should never occur but figure out how to handle it
				else:
					# create a generic 'continue' button
					var option_button = Button.new()
					option_button.text = "-->"
					option_button.pressed.connect(continue_conversation.bind(possible_line))
					button_container.add_child(option_button)
			else:
				var option_button = Button.new()
				option_button.text = possible_line.button_text
				option_button.pressed.connect(continue_conversation.bind(possible_line))
				button_container.add_child(option_button)

func _on_exit_button_pressed():
	close_window()

func _on_open_dialogue_box():
	start_conversation()
	get_tree().paused = true
	visible = true

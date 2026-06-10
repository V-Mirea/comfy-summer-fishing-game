extends CanvasLayer


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	
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

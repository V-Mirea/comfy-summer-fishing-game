extends Control

signal action_requested(action: String) 

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_button_menu_pressed():
	action_requested.emit("main_menu")


func _on_button_fish_pressed():
	action_requested.emit("fish")

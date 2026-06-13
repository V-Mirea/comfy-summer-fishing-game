extends Node2D

signal transition_requested(state: Global.State) 

# Called when the node enters the scene tree for the first time.
func _ready():
	TimeManager.set_phase_off() 


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_button_menu_pressed():
	transition_requested.emit(Global.State.MAIN_MENU)

func _on_exit_area_body_entered(body):
	if body is CharacterBody2D:
		transition_requested.emit(Global.State.FISHING)

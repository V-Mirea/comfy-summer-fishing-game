extends Control

signal transition_requested(action: Global.State)

# Called when the node enters the scene tree for the first time.
func _ready():
	TimeManager.set_phase_off() 


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_button_play_pressed():
	transition_requested.emit(Global.State.FISHING)

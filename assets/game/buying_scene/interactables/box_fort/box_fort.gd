extends StaticBody2D

signal open_dialogue_box

var player_in_range = false

func _unhandled_input(event):
	if player_in_range and event.is_action_pressed("interact"):
		open_dialogue_box.emit()

func _on_interaction_area_player_entered():
	player_in_range = true


func _on_interaction_area_player_exited():
	player_in_range = false

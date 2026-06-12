extends Area2D

signal player_entered
signal player_exited

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _on_body_entered(body):
	if body is CharacterBody2D:
		player_entered.emit()

func _on_body_exited(body):
	if body is CharacterBody2D:
		player_exited.emit()

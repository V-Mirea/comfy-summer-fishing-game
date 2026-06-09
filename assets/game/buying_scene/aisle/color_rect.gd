extends ColorRect

var original_color

# Called when the node enters the scene tree for the first time.
func _ready():
	original_color = color


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_interaction_area_player_entered():
	color = Color(0.0, 151.798, 24.984, 1.0)


func _on_interaction_area_player_exited():
	color = original_color

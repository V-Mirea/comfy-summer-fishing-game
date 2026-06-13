extends Sprite2D

@export var sprite_variations: Array[Texture2D]

# Called when the node enters the scene tree for the first time.
func _ready():
	material = material.duplicate()
	
	# make the shader unique so a change in one customer doesn't affect the others
	material = material.duplicate() 
	if sprite_variations.is_empty():
		printerr("Loaded a variation sprite with no possible sprites configured. Using the default texture.")
	else:
		texture = sprite_variations.pick_random()

func _on_interaction_area_player_entered():
	material.set("shader_parameter/width", 8)

func _on_interaction_area_player_exited():
	material.set("shader_parameter/width", 0)

extends AnimatedSprite2D
class_name VariationSprite

@export var sprite_variations: Array[SpriteFrames]

# Called when the node enters the scene tree for the first time.
func _ready():
	# make the shader unique so a change in one customer doesn't affect the others
	material = material.duplicate() 
	if sprite_variations.is_empty():
		printerr("Loaded a variation sprite with no possible sprites configured")
	else:
		sprite_frames = sprite_variations.pick_random()

func _on_state_changed(state: Customer.State):
	match state:
		Customer.State.ENTERING:
			play("walk_up")
		Customer.State.SHOPPING:
			play("idle")
		Customer.State.LEAVING:
			play("walk_down")

func _on_customer_toggle_outline(toggled_on):
	if toggled_on:
		material.set("shader_parameter/width", 4)
	else:
		material.set("shader_parameter/width", 0)

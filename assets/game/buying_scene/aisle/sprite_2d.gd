extends Sprite2D

@export var interactable_sprite: Texture2D

var default_sprite: Texture2D

# Called when the node enters the scene tree for the first time.
func _ready():
	default_sprite = texture


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_interaction_area_player_entered():
	texture = interactable_sprite


func _on_interaction_area_player_exited():
	texture = default_sprite

extends StaticBody2D

signal shop_opened(upgrades_sold: Upgrade.UpgradeType)

@export var upgrades_sold: Upgrade.UpgradeType
@export var display_tag_image: Texture2D # this needs to be exported on the aisle so that it can be changed when used in other scenes
@export var display_tag: Sprite2D

# using this to update the outline shader with the image's transparency value. otherwise it just ignores it
var _alpha: float = 1.0
var alpha: float:
	get: return _alpha
	set(value):
		_alpha = value
		modulate.a = value
		var mat := $Sprite2D.material as ShaderMaterial #probably bad to reference a child by name but this was annoying to figure out and im tired
		mat.set_shader_parameter("modulate_color", modulate)

var player_in_range = false

# Called when the node enters the scene tree for the first time.
func _ready():
	display_tag.texture = display_tag_image

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _unhandled_input(event):
	if player_in_range and event.is_action_pressed("interact"):
		shop_opened.emit(upgrades_sold)
		
func _on_interact_button_pressed():
	if player_in_range:
		shop_opened.emit(upgrades_sold)

func _on_player_entered_interaction_area():
	player_in_range = true

func _on_player_exited_interaction_area():
	player_in_range = false

func _on_transparency_area_body_entered(body):
	if body is CharacterBody2D:
		alpha = .3

func _on_transparency_area_body_exited(body):
	if body is CharacterBody2D:
		alpha = 1

extends StaticBody2D

signal shop_opened(upgrades_sold: Upgrade.UpgradeType)

@export var upgrades_sold: Upgrade.UpgradeType

var player_in_range = false

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _unhandled_input(event):
	if player_in_range and event.is_action_pressed("interact"):
		shop_opened.emit(upgrades_sold)

func _on_player_entered_interaction_area():
	player_in_range = true

func _on_player_exited_interaction_area():
	player_in_range = false

func _on_transparency_area_body_entered(body):
	if body is CharacterBody2D:
		modulate.a = .3

func _on_transparency_area_body_exited(body):
	if body is CharacterBody2D:
		modulate.a = 1

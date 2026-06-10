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
	if player_in_range and event.is_action_pressed("ui_select"):
		shop_opened.emit(upgrades_sold)

func _on_player_entered():
	player_in_range = true


func _on_player_exited():
	player_in_range = false

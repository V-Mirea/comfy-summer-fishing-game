extends ItemList


# Called when the node enters the scene tree for the first time.
func _ready():
	PlayerManager.selling_fish_changed.connect(_on_fish_for_sale_changed)
	refresh_list(PlayerManager.fish_to_sell)


func refresh_list(fish_to_sell: Array[Fish]):
	clear()
	for fish in fish_to_sell:
		add_item("%s (%d)" % [fish.species.display_name, fish.quality], null, false)


func _on_fish_for_sale_changed(fish_to_sell: Array[Fish]):
	refresh_list(fish_to_sell)

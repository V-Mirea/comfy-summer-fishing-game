extends ItemList


# Called when the node enters the scene tree for the first time.
func _ready():
	PlayerManager.selling_fish_changed.connect(_on_fish_for_sale_changed)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_fish_for_sale_changed(fish_to_sell: Array[Fish]):
	clear()
	for fish in fish_to_sell:
		add_item("    %s - QUALITY: %d    " % [fish.species.display_name, fish.quality], null, false)

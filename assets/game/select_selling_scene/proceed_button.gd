extends TextureButton


# Called when the node enters the scene tree for the first time.
func _ready():
	PlayerManager.selling_fish_changed.connect(_on_select_selling_list_changed)
	disable()

func enable():
	modulate = modulate.lightened(1)
	disabled = false
	
func disable():
	modulate = modulate.darkened(0.5)
	disabled = true

func _on_select_selling_list_changed(fish_to_sell: Array[Fish]):
	if fish_to_sell:
		enable()
	else:
		disable()

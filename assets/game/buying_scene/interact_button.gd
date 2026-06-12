extends TextureButton


# Called when the node enters the scene tree for the first time.
func _ready():
	if not DisplayServer.is_touchscreen_available():
		hide()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

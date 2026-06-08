extends Label


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	PlayerManager.money_changed.connect(func(newValue) -> void:
		text = newValue
	)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

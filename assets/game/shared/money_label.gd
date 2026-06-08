extends Label


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	PlayerManager.money_changed.connect(func(newValue) -> void:
		#text = newValue  ## this was erroring because it wasnt connected to anything. im using a local money label script for the selling screen currently and we can hook this up later
		pass
	)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

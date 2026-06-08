extends Label


# Called when the node enters the scene tree for the first time.
func _ready():
	PlayerManager.money_changed.connect(_on_money_changed)
	_on_money_changed(PlayerManager.data.money)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _on_money_changed(newAmount: int):
	text = "$%d" % newAmount

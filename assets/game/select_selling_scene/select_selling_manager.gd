extends Control

signal transition_requested(state: Global.State)

@export var caught_list: ItemList
@export var selling_list: ItemList
@export var proceed_button: TextureButton
@export var slots_label: Label

func _ready():
	_refresh_lists()
	caught_list.item_clicked.connect(_on_caught_item_clicked)
	selling_list.item_clicked.connect(_on_selling_item_clicked)
	proceed_button.pressed.connect(_on_proceed)

func _on_caught_item_clicked(index: int, _at_position: Vector2, mouse_button_index: int):
	if mouse_button_index != MOUSE_BUTTON_LEFT:
		return
	if PlayerManager.fish_to_sell.size() >= PlayerManager.max_sell_slots:
		return
	var fish = PlayerManager.data.fish_inventory[index]
	PlayerManager.remove_fish(fish)
	PlayerManager.add_selling_fish(fish)
	_refresh_lists()

func _on_selling_item_clicked(index: int, _at_position: Vector2, mouse_button_index: int):
	if mouse_button_index != MOUSE_BUTTON_LEFT:
		return
	var fish = PlayerManager.fish_to_sell[index]
	PlayerManager.remove_selling_fish(fish)
	PlayerManager.add_fish(fish)
	_refresh_lists()

func _refresh_lists():
	caught_list.clear()
	var caught_fish = PlayerManager.data.fish_inventory
	for fish in caught_fish:
		caught_list.add_item("%s - QUALITY: %d" % [fish.species.display_name, fish.quality])

	selling_list.clear()
	var selling_fish = PlayerManager.fish_to_sell
	for fish in selling_fish:
		selling_list.add_item("%s - QUALITY: %d" % [fish.species.display_name, fish.quality])

	slots_label.text = "%d / %d fish selected" % [selling_fish.size(), PlayerManager.max_sell_slots]
	#proceed_button.disabled = selling_fish.is_empty()

func _on_proceed():
	transition_requested.emit(Global.State.SELLING)

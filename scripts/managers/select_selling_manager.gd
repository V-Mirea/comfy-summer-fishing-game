extends Control

signal transition_requested(state: Global.State)

@export var caught_list: ItemList
@export var selling_list: ItemList
@export var proceed_button: Button
@export var slots_label: Label

var caught_fish: Array = []
var selling_fish: Array = []

func _ready():
	caught_fish = PlayerManager.get_all_fish().duplicate()
	selling_fish = []
	_refresh_lists()
	caught_list.item_clicked.connect(_on_caught_item_clicked)
	selling_list.item_clicked.connect(_on_selling_item_clicked)
	proceed_button.pressed.connect(_on_proceed)

func _on_caught_item_clicked(index: int, _at_position: Vector2, mouse_button_index: int):
	if mouse_button_index != MOUSE_BUTTON_LEFT:
		return
	if selling_fish.size() >= PlayerManager.max_sell_slots:
		return
	var fish = caught_fish[index]
	caught_fish.remove_at(index)
	selling_fish.append(fish)
	_refresh_lists()

func _on_selling_item_clicked(index: int, _at_position: Vector2, mouse_button_index: int):
	if mouse_button_index != MOUSE_BUTTON_LEFT:
		return
	var fish = selling_fish[index]
	selling_fish.remove_at(index)
	caught_fish.append(fish)
	_refresh_lists()

func _refresh_lists():
	caught_list.clear()
	for fish in caught_fish:
		caught_list.add_item("%s - QUALITY: %d" % [fish.species.display_name, fish.quality])

	selling_list.clear()
	for fish in selling_fish:
		selling_list.add_item("%s - QUALITY: %d" % [fish.species.display_name, fish.quality])

	slots_label.text = "%d / %d fish selected" % [selling_fish.size(), PlayerManager.max_sell_slots]
	proceed_button.disabled = selling_fish.is_empty()

func _on_proceed():
	PlayerManager.fish_to_sell = selling_fish.duplicate()
	for fish in selling_fish:
		PlayerManager.remove_fish(fish)
	transition_requested.emit(Global.State.SELLING)

extends Node

signal money_changed(new_amount: int)
signal fish_added(fish: Fish)
signal fish_removed(fish: Fish)
signal inventory_changed()
signal upgrade_changed(upgrade_id: String, new_level: int)

const SAVE_PATH := "user://player_data.tres" #i think this is right? we'll have to figure this out but seems simple enough

var data: PlayerData

#base funct

func _ready() -> void:
	data = load_from_disk()
	if data == null:
		data = PlayerData.new()

#persistent data info

func add_fish(fish: Fish) -> void:
	data.fish_inventory.append(fish)
	fish_added.emit(fish)
	inventory_changed.emit()

func remove_fish(fish: Fish) -> void:
	var idx := data.fish_inventory.find(fish)
	if idx >= 0:
		data.fish_inventory.remove_at(idx)
		fish_removed.emit(fish)
		inventory_changed.emit()

#eventually have functionality to sort this? or would we do that from a consumer perspective
func get_all_fish() -> Array[Fish]:
	return data.fish_inventory

func sell_fish(fish: Fish) -> void:
	add_money(fish.price)
	remove_fish(fish)

func sell_all_fish() -> void:
	var total := 0
	for f in data.fish_inventory:
		total += f.price
	data.fish_inventory.clear()
	add_money(total)
	inventory_changed.emit()

func add_money(amount: int) -> void:
	data.money += amount
	money_changed.emit(data.money)

func spend_money(amount: int) -> bool:
	if data.money < amount:
		return false
	data.money -= amount
	money_changed.emit(data.money)
	return true

func get_upgrade_level(upgrade_id: String) -> int:
	return data.upgrades.get(upgrade_id, 0)

func set_upgrade_level(upgrade_id: String, level: int) -> void:
	data.upgrades[upgrade_id] = level
	upgrade_changed.emit(upgrade_id, level)
	
#save functionality

func save_to_disk() -> void:
	ResourceSaver.save(data, SAVE_PATH)

func load_from_disk() -> PlayerData:
	if ResourceLoader.exists(SAVE_PATH):
		return ResourceLoader.load(SAVE_PATH) as PlayerData
	return null

func has_save() -> bool:
	return ResourceLoader.exists(SAVE_PATH)

func new_game() -> void:
	data = PlayerData.new()

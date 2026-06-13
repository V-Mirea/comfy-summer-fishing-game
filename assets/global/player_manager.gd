extends Node

signal money_changed(new_amount: int)
signal fish_added(fish: Fish)
signal fish_removed(fish: Fish)
signal selling_fish_changed(fish_to_sell: Array[Fish])
signal inventory_changed()
signal upgrade_changed(upgrade_type: Upgrade.UpgradeType, new_level: int)

const SAVE_PATH := "user://player_data.tres" #i think this is right? we'll have to figure this out but seems simple enough
const BASE_SELL_SLOTS: int = 20
const SLOTS_PER_LEVEL: int = 1
const MAX_SELL_SLOTS_CAP: int = 20

var data: PlayerData
var fish_to_sell: Array[Fish] = []

var max_sell_slots: int:
	get:
		return mini(BASE_SELL_SLOTS + get_upgrade_level(Upgrade.UpgradeType.SHOP_LEVEL) * SLOTS_PER_LEVEL, MAX_SELL_SLOTS_CAP)

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

func add_selling_fish(fish: Fish):
	fish_to_sell.append(fish)
	selling_fish_changed.emit(fish_to_sell)

func remove_selling_fish(fish: Fish):
	var idx := fish_to_sell.find(fish)
	if idx >= 0:
		fish_to_sell.remove_at(idx)
		selling_fish_changed.emit(fish_to_sell)

func sell_fish(fish: Fish, price: int = -1) -> void:
	var money_received
	if price == -1:
		money_received = fish.price
	else:
		money_received = price
	
	add_money(money_received)
	remove_selling_fish(fish)

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

func get_upgrade_level(type: Upgrade.UpgradeType) -> int:
	return data.upgrades.get(type, 0) #i mean, do we need this? or can we just do data.upgrades.get from the consumer. maybe we keep this just in case for calcs later, safest option

func set_upgrade_level(type: Upgrade.UpgradeType, level: int) -> void:
	data.upgrades[type] = level
	upgrade_changed.emit(type, level)
	
	trigger_event(PlayerData.GameEvent.BOUGHT_UPGRADE) ## test event
	
func trigger_event(event: PlayerData.GameEvent):
	data.events_triggered[event] = null # value is meaningless. we will just be checking that key exists
	
func has_event_triggered(event: PlayerData.GameEvent) -> bool:
	return data.events_triggered.has(event)
	
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

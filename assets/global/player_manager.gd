extends Node

signal money_changed(new_amount: int)
signal fish_added(fish: Fish)
signal fish_removed(fish: Fish)
signal selling_fish_changed(fish_to_sell: Array[Fish])
signal inventory_changed()
signal upgrade_changed(upgrade_type: Upgrade.UpgradeType, new_level: int)

const SAVE_PATH := "user://player_data.tres" #i think this is right? we'll have to figure this out but seems simple enough
const BASE_SELL_SLOTS: int = 5
const SLOTS_PER_LEVEL: int = 1
const MAX_SELL_SLOTS_CAP: int = 8

# not sure if we should hold these here? 
const PERFECT_POINTS: float = 2.0
const GOOD_POINTS: float = 1.0
const BAD_POINTS: float = 0.0
const MISS_POINTS: float = -1.0
const MISS_THRESHOLD_RATIO: float = 0.2

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
	
func get_fishing_roll_chance() -> float:
	var bait_level := get_upgrade_level(Upgrade.UpgradeType.BAIT)
	return .2 + (bait_level/5 * .2)
	
# goes from 0 -> 2.5, the other 2.5 wlil come from catching the fish portion
# at level 0, you can randomly go from 0->0.5, max level is 2 -> 2.5. this means youre responsible for 2.0 of the whole score
#however, the  random .5 is heavily weighted to be the max value, 20% of the time. 
# we can change this weight based on some upgrades later on (probably rod)
# weights are the following: 
# rod (6) + reel (2) + line (1) + bait (1)
func get_base_quality() -> float:
	var rod_level := get_upgrade_level(Upgrade.UpgradeType.ROD)
	var reel_level := get_upgrade_level(Upgrade.UpgradeType.REEL)
	var line_level := get_upgrade_level(Upgrade.UpgradeType.LINE)
	var bait_level := get_upgrade_level(Upgrade.UpgradeType.BAIT)
	var weighted_sum := (float(rod_level) / 4) * 6 \
					  + (float(reel_level) / 4) * 2 \
					  + (float(line_level) / 4) \
					  + (float(bait_level) / 4)
	#currently dividing by 4 as a predetermined "max level". we might want todefined a max level per upgrade
	var bonus := 0.5 if randf() < 0.2 else randf_range(0.0, 0.5) 
	return weighted_sum * (2.0 / 10.0) + bonus

#we convert the raw amounts of perf/good/bad/miss into a number that we can easily use. this number is pit against
# the total possible max, which is perf * numbubbles in pattern. based on that, we
# determine if the fish is caught, as well as what score the player got.
func _get_raw_score(score_data: Dictionary) -> float:
	return score_data["perfects"] * PERFECT_POINTS \
		+ score_data["goods"] * GOOD_POINTS \
		+ score_data["bads"] * BAD_POINTS \
		+ score_data["misses"] * MISS_POINTS

func did_catch_fish(score_data: Dictionary) -> bool:
	var total: int = score_data["total"]
	if total <= 0:
		return true
	if score_data["misses"] >= ceili(total / 2.0):
		return false
	var max_possible := total * PERFECT_POINTS
	return _get_raw_score(score_data) >= max_possible * MISS_THRESHOLD_RATIO

func get_minigame_quality(score_data: Dictionary) -> float:
	var max_possible: float = score_data["total"] * PERFECT_POINTS
	if max_possible <= 0.0:
		return 0.0
	var clamped := maxf(_get_raw_score(score_data), 0.0)
	return (clamped / max_possible) * 2.5

func calculate_total_quality(score_data: Dictionary) -> int:
	var combined := get_base_quality() + get_minigame_quality(score_data)
	return clampi(roundi((combined / 5.0) * 100.0), 0, 100)

func get_upgrade_level(type: Upgrade.UpgradeType) -> int:
	return data.upgrades.get(type, 0) #i mean, do we need this? or can we just do data.upgrades.get from the consumer. maybe we keep this just in case for calcs later, safest option

func set_upgrade_level(type: Upgrade.UpgradeType, level: int) -> void:
	data.upgrades[type] = level
	upgrade_changed.emit(type, level)
	
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

extends Node

# upgrades should start at level 0 so that they match their array index and allows for easy indexing
@export var rod_upgrades: Array[Upgrade]
@export var reel_upgrades: Array[Upgrade]
@export var bait_upgrades: Array[Upgrade]
@export var line_upgrades: Array[Upgrade]
@export var shop_upgrades: Array[Upgrade]
@export var advertising_upgrades: Array[Upgrade]
@export var pollution_upgrades: Array[Upgrade]

var upgrades_dictionary

func _ready():
	upgrades_dictionary = {
		Upgrade.UpgradeType.ROD: rod_upgrades,
		Upgrade.UpgradeType.REEL: reel_upgrades,
		Upgrade.UpgradeType.BAIT: bait_upgrades,
		Upgrade.UpgradeType.LINE: line_upgrades,
		Upgrade.UpgradeType.SHOP_LEVEL: shop_upgrades,
		Upgrade.UpgradeType.ADVERTISING: advertising_upgrades,
		Upgrade.UpgradeType.POLLUTION: pollution_upgrades
	}

# the effect magnitude for the player's current level of upgrade
# need a helper method cuz we just have the level and we use this a lot in the fishing rules so it's nice to get the value out of upgrade 
func get_value(type: Upgrade.UpgradeType) -> float:
	var level := PlayerManager.get_upgrade_level(type)
	var list: Array = upgrades_dictionary.get(type, [])
	if level < 0 or level >= list.size():
		return 0.0
	return list[level].value

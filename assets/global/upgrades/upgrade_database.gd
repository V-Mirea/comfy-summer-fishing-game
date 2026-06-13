extends Node

# upgrades should start at level 0 so that they match their array index and allows for easy indexing
@export var rod_upgrades: Array[Upgrade]
@export var reel_upgrades: Array[Upgrade]
@export var bait_upgrades: Array[Upgrade]
@export var line_upgrades: Array[Upgrade]
@export var shop_upgrades: Array[Upgrade]
@export var advertising_upgrades: Array[Upgrade]

var upgrades_dictionary

func _ready():
	upgrades_dictionary = {
		Upgrade.UpgradeType.ROD: rod_upgrades,
		Upgrade.UpgradeType.REEL: reel_upgrades,
		Upgrade.UpgradeType.BAIT: bait_upgrades,
		Upgrade.UpgradeType.LINE: line_upgrades,
		Upgrade.UpgradeType.SHOP_LEVEL: shop_upgrades,
		Upgrade.UpgradeType.ADVERTISING: advertising_upgrades
	}

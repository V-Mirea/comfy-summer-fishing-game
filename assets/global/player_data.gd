extends Resource

class_name PlayerData

@export var fish_inventory: Array[Fish] = []
@export var money: int = 0
@export var upgrades: Dictionary = {
	Upgrade.UpgradeType.ROD: 0,
	Upgrade.UpgradeType.REEL: 0,
	Upgrade.UpgradeType.LINE: 0,
	Upgrade.UpgradeType.BAIT: 0,
	Upgrade.UpgradeType.SHOP_LEVEL: 0,
	Upgrade.UpgradeType.ADVERTISING: 0,
	Upgrade.UpgradeType.POLLUTION: 0,
	Upgrade.UpgradeType.CONSERVATION: 0
}
@export var day: int = 1

extends Resource

class_name PlayerData

enum GameEvent { 
	MET_LOUIS, 
	FOUND_POLLUTED_FISH, 
	GAVE_POLLUTED_FISH,
	FOUND_MAGIC_FISH,
	GAVE_MAGIC_FISH,
	BOUGHT_UPGRADE, ## test event,
	GOT_MONEY_FROM_LOUIS ## test event
}

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
@export var events_triggered: Dictionary = {}

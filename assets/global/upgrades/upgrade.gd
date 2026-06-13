extends Resource
class_name Upgrade

enum UpgradeType { ROD, REEL, LINE, BAIT, SHOP_LEVEL, ADVERTISING, POLLUTION, CONSERVATION }

@export var type: UpgradeType
@export_range(0, 10) var level: int
@export_range(0, 1000, 1, "or_greater") var price: int

# magnitude of upgrade level's effect, calculated in fishingrules
@export var value: float = 0.0

@export var name: String
@export var description: String
@export var sprite: Texture2D

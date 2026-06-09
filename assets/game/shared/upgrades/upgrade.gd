extends Resource
class_name Upgrade

enum UpgradeType { ROD, REEL, LINE, BAIT, SHOP_LEVEL, ADVERTISING }

var type: UpgradeType
var level: int
var price: int

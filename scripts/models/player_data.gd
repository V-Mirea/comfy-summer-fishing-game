extends Resource

class_name PlayerData

@export var money: int = 0
@export var fish_inventory: Array[Fish] = []
@export var upgrades: Dictionary = {
	"rod": 0,
	"reel": 0,
	"line": 0,
	"bait": 0,
	"shop_size": 0,
	"advertising": 0,
}
@export var day: int = 1

extends Resource
class_name DialogueCondition

enum ConditionType {
	HAS_FISH,
	DAYS_PASSED,
}

@export var type: ConditionType
@export var fish_specie: FishSpecies		# used by HAS_ITEM
@export var day: int						# used by IS_DAY

func evaluate() -> bool:
	match type:
		ConditionType.HAS_FISH:
			return PlayerManager.data.fish_inventory.any((func(fish: Fish): return fish.species == fish_specie))
		ConditionType.DAYS_PASSED:
			return PlayerManager.data.day >= day
	return true

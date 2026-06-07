extends Node

# assigned in the inspector on the FishDatabase autoload scene.
@export var species: Array[FishSpecies] = []

func get_random() -> FishSpecies:
	if species.is_empty():
		push_error("no species configured, should never get here.")
		return null
	return species.pick_random()

extends Node

# assigned in the inspector on the FishDatabase autoload scene.
@export var species: Array[FishSpecies] = []

func get_random(rod_level: int) -> FishSpecies:
	if species.is_empty():
		push_error("no species configured, should never get here.")
		return null

	var eligible: Array[FishSpecies] = []
	for s in species:
		if s.minimum_rod_level <= rod_level:
			eligible.append(s)

	if eligible.is_empty():
		#shouuldn't happen, but will fallback to bluegill
		return species[0]

	var total_weight: int = 0
	for s in eligible:
		total_weight += s.catch_weight

	if total_weight == 0:
		return eligible.pick_random()

	var roll: int = randi() % total_weight
	var cumulative: int = 0
	for s in eligible:
		cumulative += s.catch_weight
		if roll < cumulative:
			return s

	return eligible.back()

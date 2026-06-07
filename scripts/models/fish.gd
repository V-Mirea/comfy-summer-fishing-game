extends RefCounted

#we'll use this to represent a CAUGHT fish
class_name Fish

var species: FishSpecies
var quality: int #0 - 100

func _init(species: FishSpecies, quality: int = 0) -> void:
	self.species = species
	self.quality = quality

#we can be more specific later, but for now we'll band the price from 80%->120%
var price: int:
	get:
		var factor := 0.8 + (quality / 100.0) * 0.4
		return roundi(species.base_price * factor)

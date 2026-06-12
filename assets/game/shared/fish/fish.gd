extends Resource
# made resource to serialize it

#we'll use this to represent a CAUGHT fish
class_name Fish

@export var species: FishSpecies
@export var quality: int = 0 #0 - 100

func _init(newSpecies: FishSpecies = null, newQuality: int = 0) -> void:
	self.species = newSpecies
	self.quality = newQuality

#we can be more specific later, but for now we'll band the price from 80%->120%
var price: int:
	get:
		if species == null:
			return 0
		var factor := 0.8 + (quality / 100.0) * 0.4
		return roundi(species.base_price * factor)
		
var max_counter_offer: int:
	get:
		return price * 1.5

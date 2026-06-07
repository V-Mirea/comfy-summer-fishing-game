extends Node

const SPECIES_DIR := 'res://resources/fish'
static var _species: Array[FishSpecies] = []

#_species = go through the folder
#load in all the fish on load
func _init():
	var files = DirAccess.get_files_at(SPECIES_DIR)
	for file_name in files:
		_species.append(load(SPECIES_DIR.path_join(file_name)))
	
static func get_random() -> FishSpecies:
	return _species.pick_random()

extends Resource

#the base fish, we'll be using to pull data from
class_name FishSpecies

@export var display_name: String = ""
@export var base_price: int = 0
@export var bubble_lifetime: float = 1.0
@export var pattern: Array[BubbleStep] = []

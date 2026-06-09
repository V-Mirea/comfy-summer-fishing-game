extends Resource

#one step in a fish's bubble pattern:
#this lets us still access the data easily from the manager while still letting us edit via ui
class_name BubbleStep

@export var position: Vector2 = Vector2.ZERO
@export var delay: float = 0.0

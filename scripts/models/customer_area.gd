extends RefCounted
class_name CustomerArea

var index: int
var boundary: Rect2
var center: Vector2
var is_occupied: bool

func _init(index: int, boundary: Rect2):
	self.index = index
	self.boundary = boundary
	center = calculate_center()
	is_occupied = false
	
func calculate_center() -> Vector2:
	return Vector2(boundary.position.x + (boundary.size.x / 2), boundary.position.y + (boundary.size.y / 2))

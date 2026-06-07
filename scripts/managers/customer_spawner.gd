extends Node
class_name CustomerSpawner

@export var customer_area: Control
@export var customer_scene: PackedScene

signal request_spawn_customer(customer: Node2D)

# these variables will be calculated eventually based on upgrades
var delay_time: int = 5 # time in seconds after a customer spawns that no new customers can spawn
var spawn_chance: int = 100 # 0-100 % chance for a customer to spawn when rolled
var spawn_timer: int = 2 # time in seconds that it should wait between unsuccessful spawn attempts

var customer_slots: int = 6
var customer_areas: Array[CustomerArea]

var time_since_last_spawn: float = 0

func _ready():
	calculate_customer_areas()
	pass
	
func _process(delta):
	time_since_last_spawn += delta
	if time_since_last_spawn > spawn_timer:
		var empty_slots = get_empty_customer_slots()
		# if there are empty customer slots, roll a chance to spawn a customer
		if empty_slots.size() > 0 and randi() % 100 < spawn_chance:
			var random_slot = empty_slots[randi() % empty_slots.size()]
			spawn_customer(random_slot.center)
			random_slot.is_occupied = true
			time_since_last_spawn = -delay_time
		else:
			time_since_last_spawn = 0
	
func calculate_customer_areas():
	var customer_rect = customer_area.get_rect()
	var individual_width = customer_rect.size.x / customer_slots
	
	for i in range(customer_slots):
		var individual_rect = Rect2(customer_rect.position.x + (i * individual_width), customer_rect.position.y, individual_width, customer_rect.size.y)
		customer_areas.append(CustomerArea.new(i, individual_rect))

func get_empty_customer_slots() -> Array[CustomerArea]:
	var empty_slots: Array[CustomerArea]
	
	for area in customer_areas:
		if area.is_occupied == false:
			empty_slots.append(area)
	
	return empty_slots

func spawn_customer(position: Vector2):
	var customer: Node2D = customer_scene.instantiate();
	customer.position = position
	
	request_spawn_customer.emit(customer)
	

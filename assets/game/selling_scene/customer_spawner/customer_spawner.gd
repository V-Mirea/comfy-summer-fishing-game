extends Node
class_name CustomerSpawner

@export var customer_area: Control
@export var customer_scene: PackedScene

signal request_spawn_customer(customer: Node2D)

# these variables will be calculated eventually based on upgrades
var delay_time: int = 5 # time in seconds after a customer spawns that no new customers can spawn
var spawn_chance: int = 100 # 0-100 % chance for a customer to spawn when rolled
var spawn_timer: int = 2 # time in seconds that it should wait between unsuccessful spawn attempts

var customer_slots: int
var customer_areas: Array[CustomerArea]

var time_since_last_spawn: float = 0

func _ready():
	match PlayerManager.data.upgrades[Upgrade.UpgradeType.SHOP_LEVEL]:
		0:
			customer_slots = 3
		1:
			customer_slots = 4
		2: 
			customer_slots = 6
		3: 
			customer_slots = 8
	calculate_customer_areas()
	
func _process(delta):
	time_since_last_spawn += delta
	if time_since_last_spawn > spawn_timer:
		var empty_slots = get_empty_customer_slots()
		# if there are empty customer slots and fish to sell, roll a chance to spawn a customer
		if empty_slots.size() > 0 and PlayerManager.fish_to_sell.size() > 0 and randi() % 100 < spawn_chance:
			var random_slot = empty_slots[randi() % empty_slots.size()]
			spawn_customer(random_slot)
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

func spawn_customer(spawn_slot: CustomerArea):
	var customer: Customer = customer_scene.instantiate();
	customer.slot_position = spawn_slot.center
	customer.enter_exit_postition = Vector2(spawn_slot.center.x, get_viewport().get_visible_rect().size.y) # position at bottom of screen below assigned slot
	customer.position = customer.enter_exit_postition
	customer.slot_index = spawn_slot.index
	customer.fish_wanted = PlayerManager.fish_to_sell[randi() % PlayerManager.fish_to_sell.size()]
	customer.leaving_shop.connect(_on_customer_leaving)
	
	request_spawn_customer.emit(customer)
	
func _on_customer_leaving(customer: Customer):
	customer.queue_free()
	customer_areas[customer.slot_index].is_occupied = false
	

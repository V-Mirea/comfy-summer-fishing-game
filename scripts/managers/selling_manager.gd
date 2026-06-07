extends Node2D

@export var customer_area: Control

signal transition_requested(state: Global.State) 

var customer_areas: Array[Rect2]

# these variables will be calculated eventually based on upgrades
var delay_time: int # time in seconds after a customer spawns that no new customers can spawn
var spawn_chance: float # 0-1 (0%-100%) chance for a customer to spawn when rolled
var spawn_timer: int # time in seconds that it should wait between unsuccessful spawn attempts

var customer_slots: int = 3

# Called when the node enters the scene tree for the first time.
func _ready():
	calculate_customer_areas()
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_button_menu_pressed():
	transition_requested.emit(Global.State.MAIN_MENU)


func _on_button_buy_pressed():
	transition_requested.emit(Global.State.BUYING)

func calculate_customer_areas():
	var customer_rect = customer_area.get_rect()
	var individual_width = customer_rect.size.x / customer_slots
	
	for i in range(customer_slots):
		var individual_rect = Rect2(customer_rect.position.x + (i * individual_width), customer_rect.position.y, individual_width, customer_rect.size.y)
		customer_areas.append(individual_rect)

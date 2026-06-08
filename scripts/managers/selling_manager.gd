extends Node2D

signal transition_requested(state: Global.State)
signal bartering_started(customer: Customer)
signal fish_sold(fish: Fish)

@export var pause_button: Button
@export var haggle_ui: HaggleControl

var fish_for_sale: Array[Fish]

# Called when the node enters the scene tree for the first time.
func _ready():
	PlayerManager.selling_fish_changed.emit(PlayerManager.fish_to_sell)
	haggle_ui.offer_accepted.connect(_on_offer_accepted)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _on_button_menu_pressed():
	transition_requested.emit(Global.State.MAIN_MENU)

func _on_button_buy_pressed():
	transition_requested.emit(Global.State.BUYING)

func _on_request_spawn_customer(customer: Customer):
	add_child(customer)
	customer.selected.connect(_on_customer_selected)
	bartering_started.connect(customer._on_some_customer_bartering)
	fish_sold.connect(customer._on_fish_sold)
	haggle_ui.offer_declined.connect(customer._on_offer_declined)

<<<<<<< HEAD
func _on_pause_button_pressed() -> void:
	PauseMenu.toggle()
=======
func _on_pause_button_pressed():
	PauseMenu.toggle()
	
func _on_customer_selected(customer: Customer, toggled_on: bool):
	haggle_ui.visible = toggled_on
	if toggled_on:
		bartering_started.emit(customer)

func _on_offer_accepted(customer: Customer, price: int):
	PlayerManager.sell_fish(customer.fish_wanted, price)
	fish_sold.emit(customer.fish_wanted)
	customer.leave_shop()
>>>>>>> develop

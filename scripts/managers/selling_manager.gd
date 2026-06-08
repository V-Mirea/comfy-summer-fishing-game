extends Node2D

signal transition_requested(state: Global.State)

@export var pause_button: Button

# Called when the node enters the scene tree for the first time.
func _ready():
	var fish_for_sale = PlayerManager.fish_to_sell

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _on_button_menu_pressed():
	transition_requested.emit(Global.State.MAIN_MENU)


func _on_button_buy_pressed():
	transition_requested.emit(Global.State.BUYING)

func _on_request_spawn_customer(customer: Customer):
	add_child(customer)

func _on_pause_button_pressed() -> void:
	PauseMenu.toggle()

extends Node

class_name Customer

signal leaving_shop(customer: Customer)
signal patience_changed(patience: int)
signal selected(customer: Customer, toggled_on: bool)

@export var offer_label: Label
@export var clickbox: Button

enum State { ENTERING, SHOPPING, LEAVING }
var state_machine: StateMachine

var patience_interval: float = 0.3 # Time in seconds it takes the patience meter to go down 1%

var patience: int = 100 # 0-100. Customer leaves at 0

var slot_index: int
var fish_wanted: Fish
var timer: Timer

func _ready():
	var valid_transitions = {
		State.ENTERING: [State.SHOPPING],
		State.SHOPPING: [State.LEAVING],
		State.LEAVING: []
	}
	
	state_machine = StateMachine.new(valid_transitions)
	state_machine.change_state(State.ENTERING)
	
	offer_label.text = "%s (%d) - $%d" % [fish_wanted.species.display_name, fish_wanted.quality, fish_wanted.price]
	
	timer = Timer.new()
	add_child(timer)
	timer.start(patience_interval)
	timer.timeout.connect(_patience_timer_triggered)

func leave_shop():
	leaving_shop.emit(self)
	if clickbox.button_pressed:
		selected.emit(self, false)
	
func _patience_timer_triggered():
	patience -= 1
	patience_changed.emit(patience)
	
	if patience <= 0:
		leave_shop()
	
func _on_clickbox_toggled(toggled_on):
	selected.emit(self, toggled_on)
	
func _on_some_customer_bartering(customer: Customer):
	if customer != self:
		clickbox.set_pressed_no_signal(false)

func _on_fish_sold(fish: Fish):
	if fish == fish_wanted:
		leave_shop()

func _on_offer_declined(customer: Customer):
	if customer == self:
		leave_shop()

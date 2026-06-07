extends Node

class_name Customer

signal leaving_shop(customer: Customer)
signal patience_changed(patience: int)

enum State { ENTERING, SHOPPING, LEAVING }
var state_machine: StateMachine

var patience_interval: float = 0.3 # Time in seconds it takes the patience meter to go down 1%

var patience: int = 100 # 0-100. Customer leaves at 0

var slot_index: int
var timer: Timer

func _ready():
	var valid_transitions = {
		State.ENTERING: [State.SHOPPING],
		State.SHOPPING: [State.LEAVING],
		State.LEAVING: []
	}
	
	state_machine = StateMachine.new(valid_transitions)
	state_machine.change_state(State.ENTERING)
	
	timer = Timer.new()
	add_child(timer)
	timer.start(patience_interval)
	timer.timeout.connect(_patience_timer_triggered)
	
func _patience_timer_triggered():
	patience -= 1
	patience_changed.emit(patience)
	
	if patience <= 0:
		leaving_shop.emit(self)
	

extends Node

class_name Customer

enum State { ENTERING, SHOPPING, LEAVING }

var state_machine: StateMachine

func _ready():
	var valid_transitions = {
		State.ENTERING: [State.SHOPPING],
		State.SHOPPING: [State.LEAVING],
		State.LEAVING: []
	}
	
	state_machine = StateMachine.new(valid_transitions)
	state_machine.change_state(State.ENTERING)
	

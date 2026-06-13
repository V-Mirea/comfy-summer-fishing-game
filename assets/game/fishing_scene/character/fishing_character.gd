extends Node2D
class_name FishingCharacter

signal state_changed(state: State)
signal walk_in_finished

enum State { WALKING_IN, IDLE, CASTING, FISHING, RESULT }

@export var dock_position: Vector2 # where she stops on the dock: adjustable from the scene itself clicking on character
@export var speed: int = 220

var state_machine: StateMachine

func _ready():
	var valid_transitions = {
		State.WALKING_IN: [State.IDLE],
		State.IDLE: [State.CASTING],
		State.CASTING: [State.FISHING, State.RESULT, State.IDLE],
		State.FISHING: [State.RESULT, State.IDLE],
		State.RESULT: [State.IDLE]
	}
	state_machine = StateMachine.new(valid_transitions)
	state_machine.state_changed.connect(_on_state_changed)
	state_machine.change_state(State.WALKING_IN)

func _process(delta):
	if state_machine.current_state == State.WALKING_IN:
		position = position.move_toward(dock_position, delta * speed)
		if position == dock_position:
			state_machine.change_state(State.IDLE)
			walk_in_finished.emit()

func _on_state_changed(_from: State, to: State, _context):
	# forward the event to the AnimatedSprite child n the .tscn
	state_changed.emit(to)

# called by fishing_manager to mirror the fishing phase
func cast():
	state_machine.change_state(State.CASTING)

func fish():
	state_machine.change_state(State.FISHING)

func resolve(): # catch or miss? seems normal enough when playing 
	state_machine.change_state(State.RESULT)

func to_idle():
	# important to ignore while walking in
	if state_machine.current_state == State.WALKING_IN:
		return
	state_machine.change_state(State.IDLE)

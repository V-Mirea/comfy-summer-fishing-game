extends Node

@export var mainMenuScene: PackedScene
@export var fishingScene: PackedScene
@export var sellingScene: PackedScene
@export var buyingScene: PackedScene

enum State {MAIN_MENU, FISHING, SELLING, BUYING}
var current_state = State.MAIN_MENU
var state_machine: StateMachine

# Called when the node enters the scene tree for the first time.
func _ready():
	var valid_transitions = {
		State.MAIN_MENU: [State.FISHING],
		State.FISHING: [State.SELLING, State.MAIN_MENU],
		State.SELLING: [State.BUYING, State.MAIN_MENU],
		State.BUYING: [State.FISHING, State.MAIN_MENU]
	}
	state_machine = StateMachine.new(valid_transitions)
	state_machine.state_changed.connect(_on_state_changed)
	state_machine.change_state(current_state)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_state_changed(from: int, to: int, context: Dictionary) -> void:
	pass

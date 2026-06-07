extends Node

@export var mainMenuScene: PackedScene
@export var fishingScene: PackedScene
@export var sellingScene: PackedScene
@export var buyingScene: PackedScene

var initial_state = Global.State.MAIN_MENU
var current_screen: Node
var state_machine: StateMachine

var valid_transitions = {
	Global.State.MAIN_MENU: [Global.State.FISHING],
	Global.State.FISHING: [Global.State.SELLING, Global.State.MAIN_MENU],
	Global.State.SELLING: [Global.State.BUYING, Global.State.MAIN_MENU],
	Global.State.BUYING: [Global.State.FISHING, Global.State.MAIN_MENU]
}
	
var state_scenes: Dictionary

# Called when the node enters the scene tree for the first time.
func _ready():
	state_scenes = {
		Global.State.MAIN_MENU: mainMenuScene,
		Global.State.FISHING: fishingScene,
		Global.State.SELLING: sellingScene,
		Global.State.BUYING: buyingScene
	}

	state_machine = StateMachine.new(valid_transitions)
	state_machine.state_changed.connect(_on_state_changed)
	state_machine.change_state(initial_state)

# The screens are responsible for emitting the signal connected to this method to specify when to
# switch screens and to which screen to switch
func _on_transition_requested(state: Global.State):
	state_machine.change_state(state)	

# Once the state machine has verified the transition is valid, it will emit the signal connected to
# this method to signal to the game manager to make the switch
func _on_state_changed(from: int, to: int, context: Dictionary) -> void:
	change_screen(to)	
			
func change_screen(state: int):
	if current_screen:
		current_screen.queue_free()
	
	current_screen = state_scenes[state].instantiate()
	add_child(current_screen)
	
	current_screen.transition_requested.connect(_on_transition_requested)

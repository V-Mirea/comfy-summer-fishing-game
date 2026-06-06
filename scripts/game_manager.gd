extends Node

@export var mainMenuScene: PackedScene
@export var fishingScene: PackedScene
@export var sellingScene: PackedScene
@export var buyingScene: PackedScene

enum State {MAIN_MENU, FISHING, SELLING, BUYING}
var initial_state = State.MAIN_MENU
var current_screen: Node
var state_machine: StateMachine

var valid_transitions = {
	State.MAIN_MENU: [State.FISHING],
	State.FISHING: [State.SELLING, State.MAIN_MENU],
	State.SELLING: [State.BUYING, State.MAIN_MENU],
	State.BUYING: [State.FISHING, State.MAIN_MENU]
}
	
var state_scenes: Dictionary

# Called when the node enters the scene tree for the first time.
func _ready():
	state_scenes = {
		State.MAIN_MENU: mainMenuScene,
		State.FISHING: fishingScene,
		State.SELLING: sellingScene,
		State.BUYING: buyingScene
	}

	state_machine = StateMachine.new(valid_transitions)
	state_machine.state_changed.connect(_on_state_changed)
	state_machine.change_state(initial_state)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_state_changed(from: int, to: int, context: Dictionary) -> void:
	change_screen(to)
	
func _on_action_requested(action: String):
	match action:
		"play":
			state_machine.change_state(State.FISHING)
		"main_menu":
			state_machine.change_state(State.MAIN_MENU)			
			
func change_screen(state: int):
	if current_screen:
		current_screen.queue_free()
	
	current_screen = state_scenes[state].instantiate()
	add_child(current_screen)
	
	current_screen.action_requested.connect(_on_action_requested)

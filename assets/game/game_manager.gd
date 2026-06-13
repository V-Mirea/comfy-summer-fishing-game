extends Node

@export var mainMenuScene: PackedScene
@export var fishingScene: PackedScene
@export var selectSellingScene: PackedScene
@export var sellingScene: PackedScene
@export var buyingScene: PackedScene
@export var gameplay_music: AudioStream
@export var mainmenu_music: AudioStream
@export var buying_music: AudioStream

signal toggle_global_controls

var initial_state = Global.State.MAIN_MENU
var current_screen: Node
var state_machine: StateMachine

var valid_transitions = {
	Global.State.MAIN_MENU: [Global.State.FISHING],
	Global.State.FISHING: [Global.State.SELECT_SELLING, Global.State.MAIN_MENU],
	Global.State.SELECT_SELLING: [Global.State.SELLING, Global.State.MAIN_MENU],
	Global.State.SELLING: [Global.State.BUYING, Global.State.MAIN_MENU],
	Global.State.BUYING: [Global.State.FISHING, Global.State.MAIN_MENU]
}
	
var state_scenes: Dictionary
var state_music: Dictionary

# Called when the node enters the scene tree for the first time.
func _ready():
	state_scenes = {
		Global.State.MAIN_MENU: mainMenuScene,
		Global.State.FISHING: fishingScene,
		Global.State.SELECT_SELLING: selectSellingScene,
		Global.State.SELLING: sellingScene,
		Global.State.BUYING: buyingScene
	}

	state_music = {
		Global.State.MAIN_MENU: mainmenu_music,
		Global.State.FISHING: gameplay_music,
		Global.State.SELECT_SELLING: gameplay_music,
		Global.State.SELLING: gameplay_music,
		Global.State.BUYING: buying_music
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
	AudioManager.play_music(state_music[to])

	if from == Global.State.MAIN_MENU or to == Global.State.MAIN_MENU:
		toggle_global_controls.emit()
			
func change_screen(state: int):
	if current_screen:
		current_screen.queue_free()
	
	current_screen = state_scenes[state].instantiate()
	add_child(current_screen)
	
	current_screen.transition_requested.connect(_on_transition_requested)

func _on_pause_button_pressed():
	PauseMenu.toggle()

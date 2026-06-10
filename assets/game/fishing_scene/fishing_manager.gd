extends Node2D

signal transition_requested(state: Global.State)

enum State { IDLE, WAITING_FOR_BITE, MISSED_BITE, CONFIRM_BITE, MINIGAME, RESOLVED, MISSED_FISH }
var state: State = State.IDLE
var time_since_last_roll: float = 0.0
var time_since_bite: float = 0.0
var state_machine: StateMachine
var hooked_fish: Fish
var bite_window: float = 1.0

const ROLL_INTERVAL: float = 0.5 #change later per rod, or other stuff

@export var status_label: Label
@export var money_label: Label
@export var pause_button: Button
@export var bubble_manager: BubbleManager

# Called when the node enters the scene tree for the first time.
func _ready():
	var valid_transitions = {
		State.IDLE: [State.WAITING_FOR_BITE],
		State.WAITING_FOR_BITE: [State.IDLE, State.CONFIRM_BITE],
		State.MISSED_BITE: [State.IDLE],
		State.CONFIRM_BITE: [State.MINIGAME, State.WAITING_FOR_BITE, State.MISSED_BITE, State.IDLE],
		State.MINIGAME: [State.RESOLVED, State.MISSED_FISH],
		State.MISSED_FISH: [State.IDLE],
		State.RESOLVED: [State.IDLE]
	}
	state_machine = StateMachine.new(valid_transitions)
	state_machine.state_changed.connect(_on_state_changed)
	state_machine.change_state(State.IDLE)
	bubble_manager.pattern_complete.connect(_on_pattern_complete)

	## test code to avoid skip having to fish ##
	for i in 10:
		var fish: Fish = Fish.new()
		fish.quality = randi() % 100
		fish.species = FishDatabase.get_random()
		PlayerManager.add_fish(fish)
	###


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	match state_machine.current_state:
		State.IDLE:
			if Input.is_action_just_pressed("set_hook"):
				state_machine.change_state(State.WAITING_FOR_BITE)
		State.WAITING_FOR_BITE:
			_process_waiting_for_bite(delta)
		State.CONFIRM_BITE:
			_process_confirm_bite(delta)


func _process_waiting_for_bite(delta: float) -> void:
	time_since_last_roll += delta
	if Input.is_action_just_pressed("set_hook"):
		state_machine.change_state(State.IDLE)
		return
	if time_since_last_roll >= ROLL_INTERVAL:
		time_since_last_roll = 0.0
		_roll_fish()

func _roll_fish() -> void:
	if randf() >= PlayerManager.get_fishing_roll_chance():
		return  # no fish this roll

	var species: FishSpecies = FishDatabase.get_random() #TODO calc this in player manager too 
	if species == null:
		push_error("No fish species available, shouldn't be possible")
		return

	hooked_fish = Fish.new(species)
	state_machine.change_state(State.CONFIRM_BITE)

func _process_confirm_bite(delta: float) -> void:
	time_since_bite += delta
	if Input.is_action_just_pressed("set_hook"):
		state_machine.change_state(State.MINIGAME)
	elif time_since_bite >= bite_window:
		state_machine.change_state(State.MISSED_BITE)

func _on_state_changed(from: int, to: int, context: Dictionary) -> void:
	_update_ui(to, context)
	match to:
		State.IDLE:
			time_since_last_roll = 0.0
			hooked_fish = null
		State.WAITING_FOR_BITE:
			pass
		State.MISSED_BITE:
			await get_tree().create_timer(2.0).timeout
			if state_machine.current_state == State.MISSED_BITE:
				state_machine.change_state(State.IDLE)
		State.CONFIRM_BITE:
			time_since_bite = 0
		State.MINIGAME:
			await get_tree().create_timer(0.5).timeout
			bubble_manager.start_pattern(hooked_fish.species.pattern, hooked_fish.species.bubble_lifetime)
		State.MISSED_FISH:
			await get_tree().create_timer(2.0).timeout
			if state_machine.current_state == State.MISSED_FISH:
				state_machine.change_state(State.IDLE)
		State.RESOLVED:
			state_machine.change_state(State.IDLE)

func _update_ui(state: State, context: Dictionary):
	status_label.text = _get_status_text_for_state(state, context)

func _get_status_text_for_state(state: State, context: Dictionary) -> String:
	match state:
		State.IDLE:
			return "Ready to cast"
		State.WAITING_FOR_BITE:
			return "Waiting for bite..."
		State.MISSED_BITE:
			return "Darn it, too slow!"
		State.CONFIRM_BITE:
			return "There's a bite! Press SPACE to set the hook!"
		State.MINIGAME:
			return "Hooooo weee, fish on!"
		State.MISSED_FISH:
			return "The fish got away!"
		State.RESOLVED:
			return "Caught a %s!" % hooked_fish.species.display_name
		_:
			return ""

func _on_pattern_complete(score_data: Dictionary) -> void:
	if not PlayerManager.did_catch_fish(score_data):
		state_machine.change_state(State.MISSED_FISH)
		return
	hooked_fish.quality = PlayerManager.calculate_total_quality(score_data)
	PlayerManager.add_fish(hooked_fish)
	FishCaughtScreen.open(hooked_fish)
	await FishCaughtScreen.closed
	state_machine.change_state(State.RESOLVED)

func _on_button_menu_pressed():
	transition_requested.emit(Global.State.MAIN_MENU)

func _on_button_sell_pressed():
	transition_requested.emit(Global.State.SELECT_SELLING)

func _on_pause_button_pressed() -> void:
	PauseMenu.toggle()

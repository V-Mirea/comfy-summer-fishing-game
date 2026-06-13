extends Node2D

class_name Customer

signal leaving_shop(customer: Customer)
signal patience_changed(patience: int)
signal selected(customer: Customer, toggled_on: bool)
signal toggle_outline(toggled_on: bool)
signal state_changed(state: State)

@export var offer_label: Label
@export var clickbox: Button

@export var accept_sprite: Sprite2D
@export var angry_sprite: Sprite2D
@export var decline_sprite: Sprite2D

enum State { ENTERING, SHOPPING, LEAVING }
var state_machine: StateMachine

enum Reaction { ACCEPT, DECLINE, ANGRY }

var patience_interval: float = 0.3 # Time in seconds it takes the patience meter to go down 1%
var minimum_accept_chance: float = 0.2 # 0-1 chance customer accepts at the max possible counter offer
var max_angry_chance: float = 0.6 # 0-1 chance after they dont accept that customer leaves at the max possible counter offer

var patience: int = 100 # 0-100. Customer leaves at 0
var speed: int = 200

var enter_exit_postition: Vector2 # where the customer spawns/despawns
var slot_position: Vector2 # where the customer should end up after walking in
var slot_index: int
var fish_wanted: Fish
var patience_timer: Timer

var chat_bubble_duration: int = 3
var chat_bubble_timer: Timer

func _ready():
	var valid_transitions = {
		State.ENTERING: [State.SHOPPING, State.LEAVING],
		State.SHOPPING: [State.LEAVING],
		State.LEAVING: []
	}
	
	state_machine = StateMachine.new(valid_transitions)
	state_machine.state_changed.connect(_on_state_changed)
	state_machine.change_state(State.ENTERING)
	
	offer_label.text = "%s (%d) - $%d" % [fish_wanted.species.display_name, fish_wanted.quality, fish_wanted.price]
	
	patience_timer = Timer.new()
	add_child(patience_timer)
	patience_timer.start(patience_interval)
	patience_timer.timeout.connect(_patience_timer_triggered)

func _process(delta):
	if state_machine.current_state == State.ENTERING:
		position = position.move_toward(slot_position, delta * speed)		
		if position == slot_position:
			state_machine.change_state(State.SHOPPING)
	elif state_machine.current_state == State.LEAVING:
		position = position.move_toward(enter_exit_postition, delta * speed)
		if position == enter_exit_postition:
			leave_shop()

# takes a counter offer from the player and accepts it, declines, or walks away
func consider_offer(offer_price: int, max_price: int) -> Reaction:
	var price_increase: int = offer_price - fish_wanted.price
	var price_range: float = max_price - fish_wanted.price
	var price_increase_ratio: float = float(price_increase) / price_range

	var accept_chance_range: float = 1.0 - minimum_accept_chance
	var offer_similarity_ratio: float = 1.0 - price_increase_ratio
	var accept_chance: float = (offer_similarity_ratio * accept_chance_range) + minimum_accept_chance
	
	if randf() <= accept_chance:
		accept_sprite.visible = true
		return Reaction.ACCEPT
	else:
		var angry_chance: float = price_increase_ratio * max_angry_chance
		if randf() <= angry_chance:
			angry_sprite.visible = true
			return Reaction.ANGRY
		else:
			show_decline_bubble()
			return Reaction.DECLINE

func show_decline_bubble():
	decline_sprite.visible = true
	
	if chat_bubble_timer != null:
		chat_bubble_timer.queue_free()
		
	chat_bubble_timer = Timer.new()
	add_child(chat_bubble_timer)
	chat_bubble_timer.one_shot = true
	chat_bubble_timer.start(chat_bubble_duration)
	chat_bubble_timer.timeout.connect(_chat_bubble_timer_triggered)

func _chat_bubble_timer_triggered():
	chat_bubble_timer.queue_free()
	chat_bubble_timer = null
	
	decline_sprite.visible = false

func start_leaving():
	# changes state so that customer starts walking to leave
	state_machine.change_state(State.LEAVING)
	if clickbox.button_pressed:
		selected.emit(self, false)
		toggle_outline.emit(false)

func leave_shop():
	leaving_shop.emit(self) #connected to customer spawner to free the node and spawn slot
	
func _patience_timer_triggered():
	if state_machine.current_state == State.SHOPPING:
		patience -= 1
		patience_changed.emit(patience)
		
		if patience <= 0:
			start_leaving()
	
func _on_clickbox_toggled(toggled_on):
	if state_machine.current_state == State.SHOPPING:
		selected.emit(self, toggled_on) # connected to selling manager to toggle haggle control and unselect other customers
		toggle_outline.emit(toggled_on) # connected to the VariantSprite to tell it to turn the outline on/off
	
func _on_some_customer_bartering(customer: Customer):
	if customer != self:
		clickbox.set_pressed_no_signal(false)
		toggle_outline.emit(false)

func _on_fish_sold(fish: Fish):
	if state_machine.current_state != State.LEAVING and fish == fish_wanted:
		start_leaving()
		
func _on_state_changed(from: State, to: State, context):
	# forward the event to the VariationSprite child
	state_changed.emit(to) 

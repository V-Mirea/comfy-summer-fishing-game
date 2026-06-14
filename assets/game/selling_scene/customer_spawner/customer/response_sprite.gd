extends Sprite2D
class_name ResponseSprite

@export var accept_sprite: Texture2D
@export var decline_sprite: Texture2D
@export var angry_sprite: Texture2D

var chat_bubble_duration: int = 3 # time in seconds to show decline response
var chat_bubble_timer: Timer

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func show_accept_sprite():
	# we can show this and just leave it because customer will walk off the screen after and just disappear
	texture = accept_sprite

func show_decline_sprite():
	texture = decline_sprite
	
	if chat_bubble_timer != null:
		chat_bubble_timer.queue_free()
		
	chat_bubble_timer = Timer.new()
	add_child(chat_bubble_timer)
	chat_bubble_timer.one_shot = true
	chat_bubble_timer.start(chat_bubble_duration)
	chat_bubble_timer.timeout.connect(_chat_bubble_timer_triggered)

func show_angry_sprite():
	# we can show this and just leave it because customer will walk off the screen after and just disappear
	texture = angry_sprite
	
func _chat_bubble_timer_triggered():
	chat_bubble_timer.queue_free()
	chat_bubble_timer = null
	
	texture = null

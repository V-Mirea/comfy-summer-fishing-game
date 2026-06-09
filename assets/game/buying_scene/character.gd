extends CharacterBody2D

@export var speed : float = 100
@export var joystick_left : VirtualJoystick

const SPEED = 300.0

var move_vector := Vector2.ZERO

func _process(delta: float) -> void:
	# Movement using Input functions:
	move_vector = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	position += move_vector * speed * delta

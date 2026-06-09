extends CharacterBody2D

@export var speed : float = 200
@export var joystick_left : VirtualJoystick

const SPEED = 300.0
	
func _physics_process(delta):
	velocity = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down") * speed
	move_and_slide()

extends CharacterBody2D

@export var speed : float = 200
@export var joystick_left : VirtualJoystick

@export var sprite_node: AnimatedSprite2D

const SPEED = 300.0
	
func _physics_process(delta):
	velocity = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down") * speed
	move_and_slide()

func _process(delta):
	if velocity == Vector2.ZERO:
		match sprite_node.animation:
			"walk_right":
				sprite_node.play("idle_right")
			"walk_left":
				sprite_node.play("idle_left")
			"walk_down":
				sprite_node.play("idle_down")
			"walk_up":
				sprite_node.play("idle_up")	
	elif abs(velocity.x) > abs(velocity.y):
		if velocity.x > 0:
			sprite_node.play("walk_right")
		else:
			sprite_node.play("walk_left")
	else:
		if velocity.y > 0:
			sprite_node.play("walk_down")
		else:
			sprite_node.play("walk_up")

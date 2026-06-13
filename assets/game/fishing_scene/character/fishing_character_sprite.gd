extends AnimatedSprite2D
class_name FishingCharacterSprite

# Feet anchors differ between the two sheets (wide asf on fishing animation one), so anchor on the feet 
# and apply a per-animation offset to keep them locked across animations.
const WALK_OFFSET := Vector2(-24, -57)
const FISHING_OFFSET := Vector2(-63, -61)

func _ready():
	centered = false
	offset = WALK_OFFSET # initial animation is walk_in

#just have a helper func to handle adjusting feet
func _play(anim: String):
	offset = WALK_OFFSET if anim == "walk_in" else FISHING_OFFSET
	play(anim)

func _on_state_changed(state: FishingCharacter.State):
	match state:
		FishingCharacter.State.WALKING_IN:
			_play("walk_in")
		FishingCharacter.State.IDLE:
			_play("walk_in") # hold on the first walk frame as a neutral standing pose
			frame = 0
			pause()
		FishingCharacter.State.CASTING:
			_play("cast") 
		FishingCharacter.State.FISHING:
			_play("fishing_loop") 
		FishingCharacter.State.RESULT:
			_play("result")

func _on_animation_finished():
	# the cast leads straight into the looping fishing animation?
	if animation == "cast":
		_play("fishing_loop")

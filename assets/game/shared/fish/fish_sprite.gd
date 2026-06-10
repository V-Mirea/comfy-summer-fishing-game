extends Node2D

class_name FishSprite

@export var sprite: AnimatedSprite2D

func set_species(species: FishSpecies) -> void:
	var sheet := species.sprite_sheet
	if sheet == null:
		visible = false
		return
	visible = true
	var frames := SpriteFrames.new()
	frames.add_animation("idle")
	frames.set_animation_loop("idle", true)
	frames.set_animation_speed("idle", 8.0)
	var frame_size := Vector2(45, 45)
	for row in 3:
		for col in 3:
			var atlas := AtlasTexture.new()
			atlas.atlas = sheet
			atlas.region = Rect2(col * frame_size.x, row * frame_size.y, frame_size.x, frame_size.y)
			frames.add_frame("idle", atlas)
	if frames.has_animation("default"):
		frames.remove_animation("default")
	sprite.sprite_frames = frames
	sprite.play("idle")

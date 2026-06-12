extends CanvasLayer

signal closed

@export var fish_name_label: Label
@export var fish_icon: FishSprite
@export var stars_container: HBoxContainer
@export var next_button: Button
@export var fish_caught_sfx: SfxEvent

var was_paused: bool = false

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	visible = false

func open(fish: Fish) -> void:
	AudioManager.play_sfx(fish_caught_sfx)
	was_paused = get_tree().paused
	get_tree().paused = true
	fish_name_label.text = fish.species.display_name
	fish_icon.set_species(fish.species)
	_update_stars(fish.quality)
	visible = true
	# wait for layout to resolve, then center the sprite otherwise it's strangely off center?
	await get_tree().process_frame
	var container := fish_icon.get_parent() as Control
	fish_icon.position = container.size / 2.0

func close() -> void:
	visible = false
	get_tree().paused = was_paused #potentially possible to reach this screen from other screens (pause screens maybe? so gotta check for pause)
	closed.emit()

func _update_stars(quality: int) -> void:
	#it's possible later on we extract this into its own scene if we think we'll use ratings elsewhere? doubtful though
	var star_value := quality / 20.0
	for i in stars_container.get_child_count():
		var star: QualityStar  = stars_container.get_child(i)
		var fill_amount := clampf(star_value - i, 0.0, 1.0)
		var clip: Control = star.clip_container
		clip.size.x = star.size.x * fill_amount

func _on_next_button_pressed() -> void:
	close()

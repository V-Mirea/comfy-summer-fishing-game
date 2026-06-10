extends CanvasLayer

@export var money_label: Label
@export var upgrades_list: VBoxContainer
@export var fish_list: VBoxContainer
@export var resume_button: Button

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	visible = false

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		toggle()
		get_viewport().set_input_as_handled()

func toggle() -> void:
	if not visible:
		open()
	else:
		close()

func open() -> void:
	_refresh()
	visible = true
	get_tree().paused = true

func close() -> void:
	visible = false
	get_tree().paused = false

func _refresh() -> void:
	money_label.text = "Money: %d" % PlayerManager.data.money

	#clear and rebuild upgrades, iterating from the player manager data. we could make it reactive, but note that 
	# on first opening from save data, we would need to rebuild anyways. so i believe most things in the pause menu should be 
	# not reactive
	for child in upgrades_list.get_children():
		child.queue_free()
	for upgrade_type in PlayerManager.data.upgrades:
		#hide the 'behind the scenes' stuff?
		if upgrade_type == Upgrade.UpgradeType.POLLUTION or upgrade_type == Upgrade.UpgradeType.CONSERVATION:
			continue
		var label := Label.new()
		label.text = "%s: Lv %d" % [Upgrade.UpgradeType.keys()[upgrade_type].capitalize(), PlayerManager.get_upgrade_level(upgrade_type)]
		upgrades_list.add_child(label)

	#same goes for fish
	for child in fish_list.get_children():
		child.queue_free()
	var fish_inventory := PlayerManager.get_all_fish()
	if fish_inventory.is_empty():
		var label := Label.new()
		label.text = "No fish"
		fish_list.add_child(label)
	else:
		for fish in fish_inventory:
			var label := Label.new()
			label.text = "%s (Quality: %d)" % [fish.species.display_name, fish.quality]
			fish_list.add_child(label)

func _on_resume_button_pressed() -> void:
	toggle()

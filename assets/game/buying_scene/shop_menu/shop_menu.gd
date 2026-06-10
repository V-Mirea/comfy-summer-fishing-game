extends CanvasLayer

@export var items_container: GridContainer
@export var description_label: Label
@export var purchase_button: Button
@export var upgrade_button_scene: PackedScene

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

func populate_shop(upgrades_sold: Upgrade.UpgradeType):
	var button_group: ButtonGroup = ButtonGroup.new()
	for upgrade: Upgrade in UpgradeDatabase.upgrades_dictionary[upgrades_sold]:
		var upgrade_button: UpgradeButton = upgrade_button_scene.instantiate() as UpgradeButton
		upgrade_button.setup(upgrade, button_group)
		upgrade_button.upgrade_selected.connect(_on_upgrade_selected)
		items_container.add_child(upgrade_button)

func _on_shop_opened(upgrades_sold: Upgrade.UpgradeType):
	get_tree().paused = true
	visible = true
	
	populate_shop(upgrades_sold)
	
func _on_upgrade_selected(selected_upgrade: Upgrade):
	description_label.text = selected_upgrade.description
	
	var player_upgrade_level = PlayerManager.get_upgrade_level(selected_upgrade.type)
	if player_upgrade_level > selected_upgrade.level - 1:
		purchase_button.disabled = true
		purchase_button.text = "Owned"
	elif player_upgrade_level < selected_upgrade.level - 1:
		purchase_button.disabled = true
		purchase_button.text = "Locked"
	else:
		purchase_button.disabled = false
		purchase_button.text = "Purchase"

func _on_purchase_button_pressed():
	pass

func _on_exit_button_pressed():
	get_tree().paused = false
	visible = false
	
	# remove all items from the shop since we will repopulate on open
	for child in items_container.get_children():
		child.queue_free()

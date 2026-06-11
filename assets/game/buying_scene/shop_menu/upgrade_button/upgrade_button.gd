extends CenterContainer
class_name UpgradeButton

signal upgrade_selected(upgrade: Upgrade)

var button: Button
var upgrade: Upgrade

func setup(upgrade: Upgrade, button_group: ButtonGroup):
	self.upgrade = upgrade
	
	button = $Button
	button.icon = upgrade.sprite
	button.text = "%s - $%d" % [upgrade.name, upgrade.price]
	button.button_group = button_group


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_button_toggled(toggled_on):
	upgrade_selected.emit(upgrade)
